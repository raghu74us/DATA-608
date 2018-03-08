library(shiny)
library(ggplot2)
library(dplyr)
library(plyr)
library(data.table)

mor <- read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv", stringsAsFactors = FALSE)

agr <- aggregate(mor$Population, by=list(mor$ICD.Chapter,mor$Year), FUN=sum)
names(agr) <-c("ICD.Chapter","Year","NatPopulation")

mor <- inner_join(mor, agr)
mor$NatAvg <- (mor$Deaths/mor$NatPopulation)*100000

ui <- fluidPage(

  titlePanel("Mortality Rates"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("StateOutput"),
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

