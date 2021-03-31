# Shiny
library(shiny)
library(bslib)
library(plotly)


#1.0 User interface
ui <- navbarPage(
  title = "Google Trends Forecast",
  
  theme = bslib::bs_theme(version = 4, bootswatch = "pulse"),
  
  tabPanel(
    title = "Explore",
    
    sidebarLayout(
      
      sidebarPanel(
        width = 3,
       
        
        
        h4("Deeper Change Team 1"),
        p("Thomas Browne, Victoria Duffin, Haley Frade, John Rusenko, and Nadia Sanchez") ,
        
        div(class = "text-center"),
        hr(),
        h4("Choose a Region"),
        
        shiny::selectInput(
          inputId  = "region_choice",
          label = "Region",
          choices = c("United States","New York","New Jersey")
        )
      ),
      
      mainPanel(
        h3("Levels of Interest for 'therapy near me'"),
        plotlyOutput("forecastplot",height = 600,width=800)
      )
    )
  )
  
)
