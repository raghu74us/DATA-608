library(shiny)
library(ggplot2)
library(dplyr)
library(plyr)
library(data.table)


server <- function(input, output) {

  output$StateOutput <- renderUI({
    selectInput("StateInput", "State", sort(unique(mor$State)), selected = "AL")  })

  output$diseaseOutput <- renderUI({
    selectInput("diseaseInput", "Disease", sort(unique(mor$ICD.Chapter)), selected = "Certain infectious and parasitic diseases")  })

  filtered <- reactive({
    if (is.null(input$StateInput)) {return(NULL) }    
    if (is.null(input$diseaseInput)) {return(NULL) }    
    
    mor %>%
      filter(
             State == input$StateInput, ICD.Chapter == input$diseaseInput
            )
           })

  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    
    ggplot(filtered(), aes(x=(Year), y=NatAvg)) + 
      geom_bar(stat="identity", aes(fill=NatAvg)) 
 
  })
  
  output$results <- renderTable({  filtered() })
  
}
