# Shiny
library(shiny)
library(bslib)

# Modeling
library(modeldata)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(timetk)
library(parsnip)
library(rsample)
library(modeltime)
library(lubridate)

# Widgets
library(plotly)

# Core
library(tidyverse)

#Google Trends
library(gtrendsR)


#Load datasets
ustherapydata <- gtrends(keyword="therapy near me")
nytherapydata <- gtrends(keyword="therapy near me",geo="US-NY")
njtherapydata <- gtrends(keyword="therapy near me",geo="US-NJ")


#Extract interest over time
ustrends <- cbind(as.Date(decimal_date(ymd(ustherapydata$interest_over_time$date))),
                  ustherapydata$interest_over_time$hits)
usts <- ts(data=ustrends[,-1],start=ustrends[1,1],frequency = 52)

nytrends <- cbind(as.Date(decimal_date(ymd(nytherapydata$interest_over_time$date))),
                  nytherapydata$interest_over_time$hits)
nyts <- ts(data=nytrends[,-1],start=nytrends[1,1],frequency = 52)

njtrends <- cbind(as.Date(decimal_date(ymd(njtherapydata$interest_over_time$date))),
                  njtherapydata$interest_over_time$hits)
njts <- ts(data=njtrends[,-1],start=njtrends[1,1],frequency = 52)

#Data list
data_list <- list(
  "United States" = usts,
  "New York" = nyts,
  "New Jersey" = njts
)


# 2.0 Server
server = function(input,output) {
  rv = reactiveValues()
  
  observe({
    rv$data_set = data_list %>% pluck(input$region_choice)
    
  })
  
  # Run 1 forecast model on the input choice
  output$forecastplot <- renderPlotly ({
    #generate df
    
    df <- fortify(rv$data_set)
    df$Index <- date_decimal(df$Index)
    colnames(df)<- c("Date","Interest")
    
    
    #Split Data 80/20
    splits <- initial_time_split(df,prop=0.9)  
    
    
    
    # Model 1: AUTO_ARIMA
    
    model_fit_arima <- arima_reg() %>% 
      set_engine(engine = "auto_arima") %>% 
      fit(Interest ~ Date,data=training(splits)) 
    
    
    
    
    # Model Table
    
    models_tbl <- modeltime_table(
      model_fit_arima
    )
    
    # Testing Split and Actual Data
    
    models_tbl %>% 
      modeltime_calibrate(new_data = testing(splits)) %>%
      modeltime_forecast(
        new_data = testing(splits),
        actual_data = df)
    
    # Calibration Table
    
    calibration_tbl <- models_tbl %>%
      modeltime_calibrate(new_data = testing(splits))
    
    # Forecast based on new calibration
    
    calibration_tbl %>%
      modeltime_forecast(
        new_data    = testing(splits),
        actual_data = df)
    
    # Refit tables
    
    refit_tbl <- calibration_tbl %>%
      modeltime_refit(data = df)
    
    
    # Graph the results
    
    
    g <- refit_tbl %>%
      modeltime_forecast(h = "6 months", actual_data = df) %>%
      plot_modeltime_forecast(
        .legend_max_width = 25, # For mobile screens
        .interactive      = TRUE
      )
    plotly::ggplotly(g)
  })
  
  
}