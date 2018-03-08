library(shiny)
library(dplyr)

mor <- read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv", stringsAsFactors = FALSE)


ui <- fluidPage(

  titlePanel("Mortality Rates"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("YearOutput"),
      uiOutput("diseaseOutput")
                ),

mainPanel(
  tabsetPanel(
    tabPanel("Plot", plotOutput("coolplot")),
 #   tabPanel("Summary", verbatimTextOutput("summary")),
    tabPanel("Table", tableOutput("results"))
  )
)

  )
  )

