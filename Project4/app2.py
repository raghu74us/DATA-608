"""
Created on Mon Mar 18 
Question 1
@author: Raghu

Question 2:  
 
This time you are building an app for scientists. You’re a public health researcher 
analyzing this data. You would like to know if there’s a relationship between the
amount of rain and water quality. Create an exploratory app that allows other 
researchers to pick different sites and compare this relationship.
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

app.layout = html.Div([
    html.H3('Application for Scientist'),
    dt.DataTable(
        rows=df.to_dict('records'),
        # optional - sets the order of columns
        columns=sorted(df.columns),
        row_selectable=True,
        filterable=True,
        sortable=True,
        selected_row_indices=[0, 5, 10],
        id='datatable-df'
    ),
    dcc.Graph(
        id='graph-df'
    ),
], className="container")

@app.callback(
    Output('graph-df', 'figure'),
    [Input('datatable-df', 'rows'),
     Input('datatable-df', 'selected_row_indices')])
def update_figure(rows, selected_row_indices):
    dff = pd.DataFrame(rows)
    return {
        'data': [{
            'y': dff['FourDayRainTotal'],
            'y': dff['EnteroCount'],
            'text': 'Date: ' + dff['Date'] +'Site: '+ dff['Site'] ,
            'mode': 'markers',
            'textposition': 'top center',
            'selectedpoints': selected_row_indices,
            'marker': {
                'size': 10
            },

            'selected': {
                'marker': {
                    'line': {
                        'width': 1,
                        'color': 'rgb(0, 41, 124)'
                    },
                    'color': 'rgba(0, 41, 124, 0.7)',
                }
            },

            'unselected': {
                'marker': {
                    'line': {
                        'width': 0.5,
                        'color': 'rgb(0, 116, 217)'
                    },
                    'color': 'rgba(0, 116, 217, 0.5)',
                },

            }

        }],
        'layout': {'margin': {        'l': 40,
        'r': 10,
        't': 60,
        'b': 200}}
    }

    return fig


app.css.append_css({
    "external_url": "https://codepen.io/chriddyp/pen/bWLwgP.css"
})

if __name__ == '__main__':
    app.run_server(debug=True)