library(shiny)
library(ggplot2)
library(dplyr)

#mor <- read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv", stringsAsFactors = FALSE)


server <- function(input, output) {

  output$YearOutput <- renderUI({
    selectInput("YearInput", "Year", sort(unique(mor$Year)), selected = "AL")  })

  output$diseaseOutput <- renderUI({
    selectInput("diseaseInput", "Disease", sort(unique(mor$ICD.Chapter)), selected = "Certain infectious and parasitic diseases")  })

  filtered <- reactive({
    if (is.null(input$YearInput)) {return(NULL) }    
    if (is.null(input$diseaseInput)) {return(NULL) }    
    
    mor %>%
      filter(
             Year == input$YearInput, ICD.Chapter == input$diseaseInput
            )
           })

  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    
    ggplot(filtered(), aes(x=reorder(State,-Crude.Rate), y=Crude.Rate)) + 
      geom_bar(stat="identity", aes(fill=Crude.Rate)) 
 
  })
  
  output$results <- renderTable({  filtered() })
  
}
