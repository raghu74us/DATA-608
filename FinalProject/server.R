###############################################################load library
library(shiny)
library(leaflet)
library(data.table)
library(choroplethr)
library(devtools)
library(MASS)
library(vcd)
################################################################load data for crime map
crime_data<-fread('crime_data_1.csv')
for(i in 2:20)
{
  input_data<-fread(paste('crime_data_',
                          as.character(i),'.csv',sep=''))
  crime_data<-rbind(crime_data,input_data)
}
names(crime_data)[names(crime_data)=='latitude']<-'lat'
names(crime_data)[names(crime_data)=='longitude']<-'lng'

#########################################################################################################load data for Time series analysis
dat <- read.csv('preddata.csv')
rownames(dat) <- seq.Date(as.Date("2006-01-01"), as.Date("2015-12-31"), "days")
data <- dat[,3:9]
colnames(data) <- c("GRAND LARCENY", "FELONY ASSAULT", "ROBBERY", 
                    "BURGLARY", "GRAND LARCENY OF MOTOR VEHICLE",
                    "RAPE", "MURDER")
data.ts <- cbind(data, Date = dat$Date)
data.xts <- as.xts(data)
data.mon <- apply.monthly(data.xts, mean)
data.mon.sum <- apply(data.mon, 1, sum)

dsheatmap <- tbl_df(expand.grid(seq(12) - 1, seq(10) - 1)) %>% 
  mutate(value = data.mon.sum) %>% 
  list_parse2()

stops <- data.frame(q = 0:4/4,
                    c = rev(substring(heat.colors(4 + 1), 0, 7)),
                    stringsAsFactors = FALSE)
stops <- list_parse2(stops)

################################################################main function begin
function(input, output) {
  #### Map ######################################################################  
  #read and update the input data
  start_date<-eventReactive(input$button, {
    start_date<-input$Date_Range[1]
  })
  end_date<-eventReactive(input$button, {
    input$button
    end_date<-input$Date_Range[2]
  })
  crime_type<-eventReactive(input$button, {
    input$button
    crime_type<-input$Crime_Type
  })
  start_hour<-eventReactive(input$button, {
    start_hour<-input$IntHour
  })
  end_hour<-eventReactive(input$button, {
    end_hour<-input$EndHour
  })
  # subsets the crime data depending on user input in the Shiny app
  filtered_crime_data <- eventReactive(input$button, {
    #filter by crime type,date range,hour
    filtered_crime_data<-crime_data %>% 
      filter(as.Date(crime_data$date_time,origin = "1970-01-01") >= start_date() & 
               as.Date(crime_data$date_time,origin = "1970-01-01") <= end_date())       %>%
      filter(Offense %in% crime_type()) %>%
      filter(Occurrence_Hour >= start_hour() & 
               Occurrence_Hour <= end_hour())
  })
  #set color
  col=c('darkred','yellow','cyan','deepskyblue','lightgreen','red','purple')
  #legend
  var=c( "BURGLARY", "FELONY ASSAULT", "GRAND LARCENY",
         "GRAND LARCENY OF MOTOR VEHICLE", "RAPE", "ROBBERY")
  
  #color palette
  pal <- colorFactor(col, domain = var)
  #out map
  output$map <- renderLeaflet({
    leaflet(data = filtered_crime_data()) %>% 
      addProviderTiles('Stamen.TonerLite') %>% 
      setView(lng = -73.971035, lat = 40.775659, zoom = 12) %>% 
      addCircles(lng=~lng, lat=~lat, radius=40, 
                 stroke=FALSE, fillOpacity=0.4,color=~pal(Offense),
                 popup=~as.character(paste("Crime Type: ",Offense,
                                           "Precinct: ",  Precinct 
                 ))) %>%
      leaflet::addLegend("bottomleft", pal = pal, values = ~Offense,
                title = "Crime Type",
                opacity = 1 )%>% 
      addMarkers(
        clusterOptions = markerClusterOptions())
  })

  ################################################################################  
  #### Theme #####################################################################

  hcbase <- reactive({
    hc <- highchart() 
    if (input$theme != FALSE) {
      theme <- switch(input$theme,
                      null = hc_theme_null(),
                      economist = hc_theme_economist(),
                      dotabuff = hc_theme_db(),
                      fivethirtyeight = hc_theme_538()
      )
      hc <- hc %>% hc_add_theme(hc_theme_null())
    }
    hc
  })
  ################################################################################  
  crime <- reactiveValues(type = c("GRAND LARCENY", "FELONY ASSAULT", "ROBBERY", 
                                      "BURGLARY", "GRAND LARCENY OF MOTOR VEHICLE",
                                      "RAPE", "MURDER"))
  observeEvent(input$button2, {
    crime$type <- input$Crimetype
  })
  output$highstock <- renderHighchart({
    filtered_preddata <- data.xts[,crime$type]
    plot_object <- hcbase() %>% hc_title(text = "Crime Time Series By Crime Type")
    if (length(crime$type)==2){
      plot_object <- plot_object %>% 
        hc_yAxis_multiples(
          list(title = list(text = crime$type[1])), 
          list(title = list(text = crime$type[2]))
        ) %>%
        hc_add_series_xts(filtered_preddata[,1], name = crime$type[1]) %>%
        hc_add_series_xts(filtered_preddata[,2], name = crime$type[2], yAxis = 1)
    } else {
      for(i in 1: ncol(filtered_preddata)){
        plot_object <- plot_object %>% 
          hc_add_series_xts(filtered_preddata[,i], name = crime$type[i]) 
      }
    }
    plot_object
  })
  output$highheatmap <- renderHighchart({
    dsheatmap <- lapply(dsheatmap, sapply,round)
    hcbase() %>% 
      hc_title(text = "Monthly Total Crime Number") %>%
      hc_chart(type = "heatmap") %>% 
      hc_xAxis(categories = month.abb) %>% 
      hc_yAxis(categories = seq(2006, 2015, by = 1)) %>% 
      hc_add_series(name = "Crime", data = dsheatmap) %>% 
      hc_colorAxis(stops = stops, min = 200, max = 400)  
  })
  }