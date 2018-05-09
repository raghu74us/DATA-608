#########################################################################################################load library
library("shiny")
library("shinydashboard")
library("highcharter")
library("dplyr")
library("viridisLite")
library("markdown")
library("quantmod")
library("tidyr")
library("treemap")
library("forecast")
library("DT")
library("shiny")
library("leaflet")
library("plotly")
library("wordcloud2")
library('scatterD3')

#########################################################################################################clear environment
rm(list = ls())

#########################################################################################################main page begin
dashboardPage(
  skin = "black",
  dashboardHeader(title = "Crime Analysis", disable = FALSE),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map-marker")),
	  menuItem("Time Series", tabName = "ts", icon = icon("line-chart"))
    )
  ),
  dashboardBody(
    tabItems(
      ################################################################################################ crime map
      tabItem(tabName = "map", 
              sidebarLayout(position = "right", 
                            sidebarPanel(
                              h4("Filter"),
                              
                              # widget for crime type
                              checkboxGroupInput("Crime_Type", label = "Crime_Type",
                                                 choices = c("BURGLARY", "FELONY ASSAULT", "GRAND LARCENY",
                                                             "GRAND LARCENY OF MOTOR VEHICLE", "RAPE", "ROBBERY",
                                                             "MURDER & NON-NEGL. MANSLAUGHTE"),
                                                 selected = c("BURGLARY", "FELONY ASSAULT", "GRAND LARCENY",
                                                              "GRAND LARCENY OF MOTOR VEHICLE", "RAPE","ROBBERY",
                                                              "MURDER & NON-NEGL. MANSLAUGHTE")),
                              #date range
                              dateRangeInput("Date_Range", "Choose a date range", 
                                             start = "2015-10-01", end = "2015-12-31", 
                                             min = "2000-01-01", max = "2015-12-31"),
                              #start and end hour
                              sliderInput("IntHour", "Start time", 0, 23, 0, step = 1),
                              sliderInput("EndHour", "End time", 0, 23, 23, step = 1),
                              h4("Click the Update button to see the map: "),
                              #update button
                              actionButton("button", "Update", 
                                           style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
                            ),                       
                            mainPanel(
                              leafletOutput("map", width = "100%", height = 650)
                            )
              )
      ), 
	     ################################################################################################   time series part           
      tabItem(tabName = "ts",
              fluidRow(
                column(4, selectInput("theme", label = "Theme",
                                      choices = c(FALSE, "fivethirtyeight", "economist", "dotabuff","null" 
                                                  )))
              ),
              box(width = 10, highchartOutput("highstock")),
              box(width = 2, title = "Filter",
                  checkboxGroupInput("Crimetype", label = "Crime Type: ",
                                     choices = c("GRAND LARCENY", "FELONY ASSAULT", "ROBBERY", 
                                                 "BURGLARY", "GRAND LARCENY OF MOTOR VEHICLE",
                                                 "RAPE", "MURDER"),
                                     selected =c("GRAND LARCENY", "FELONY ASSAULT", "ROBBERY", 
                                                 "BURGLARY", "GRAND LARCENY OF MOTOR VEHICLE",
                                                 "RAPE", "MURDER")), 

                  actionButton("button2", "Update", 
                               style="color: #fff; background-color: #337ab7; border-color: #2e6da4")), 
              box(width = 12, highchartOutput("highheatmap"))
              )
  )
  )
  )
  
  
  