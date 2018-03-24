"""
Created on Mon Mar 18 
Question 1
@author: Raghu

You're a civic hacker and kayak enthusiast who just came across this dataset.
Youd like to create an app that recommends launch sites to users. Ideally an app
like this will use live data to give current recommendations, but youre still in
the testing phase. Create a prototype that allows a user to pick a date, and will 
give its recommendations for that particular date.

Think about your recommendations . Youre given federal guidelines above, but
you may still need to make some assumptions about which sites to recommend. 
Consider your audience. Users will appreciate some information explaining why a 
particular site is flagged as unsafe, but theyre not scientists.
"""

import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import dash_table_experiments as dt
import json
import pandas as pd
import numpy as np
import plotly

app = dash.Dash()
app.scripts.config.serve_locally = True

# Grab and scrub the data 
df = pd.read_csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module4/Data/riverkeeper_data_2013.csv")

# convert date strings to datetime objects
df['Date'] = pd.to_datetime(df['Date'])


# replace strings of counts with numerics
df['EnteroCount'].replace(to_replace = "<10", value = 9, inplace = True)
df['EnteroCount'].replace(to_replace = "<1", value = 0, inplace = True)
df['EnteroCount'].replace(to_replace = ">24196", value = 24197, inplace = True)
df['EnteroCount'].replace(to_replace = ">2420", value = 2421, inplace = True)
df['EnteroCount'] = pd.to_numeric(df['EnteroCount'])


df.loc[0:20]

app.layout = html.Div([
    html.H4('Enterococcus levels Data Table'),
    dt.DataTable(
        rows=df.to_dict('records'),
        # optional - sets the order of columns
        columns=sorted(df.columns),
        row_selectable=True,
        filterable=True,
        sortable=True,
        selected_row_indices=[],
        id='datatable-df'
    ),

    html.Div(id='selected-indexes'),
    dcc.Graph(
        id='graph-df'
    ),
], className="container")


@app.callback(
    Output('datatable-df', 'selected_row_indices'),
    [Input('graph-df', 'clickData')],
    [State('datatable-df', 'selected_row_indices')])

def update_selected_row_indices(clickData, selected_row_indices):
    if clickData:
        for point in clickData['points']:
            if point['pointNumber'] in selected_row_indices:
                selected_row_indices.remove(point['pointNumber'])
            else:
                selected_row_indices.append(point['pointNumber'])
    return selected_row_indices


@app.callback(
    Output('graph-df', 'figure'),
    [Input('datatable-df', 'rows'),
     Input('datatable-df', 'selected_row_indices')])

def update_figure(rows, selected_row_indices):
    dff = pd.DataFrame(rows)
    fig = plotly.tools.make_subplots(
        rows=3, cols=1,
        subplot_titles=('EnteroCount', 'FourDayRainTotal', 'SampleCount',),
        shared_xaxes=True)
    marker = {'color': ['#0074D9']*len(dff)}
    for i in (selected_row_indices or []):
        marker['color'][i] = '#FF851B'
    fig.append_trace({
        'x': dff['Site'],
        'y': dff['EnteroCount'],
        'type': 'bar',
        'marker': marker
    }, 1, 1)
    fig.append_trace({
        'x': dff['Site'],
        'y': dff['FourDayRainTotal'],
        'type': 'bar',
        'marker': marker
    }, 2, 1)
    fig.append_trace({
        'x': dff['Site'],
        'y': dff['SampleCount'],
        'type': 'bar',
        'marker': marker
    }, 3, 1)

    fig['layout']['showlegend'] = False
    fig['layout']['height'] = 800
    fig['layout']['margin'] = {
        'l': 40,
        'r': 10,
        't': 60,
        'b': 200
    }

    fig['layout']['yaxis3']['type'] = 'log'
    return fig


app.css.append_css({
    "external_url": "https://codepen.io/chriddyp/pen/bWLwgP.css"
})



if __name__ == '__main__':
    app.run_server(debug=True)