# ui.R

navbarPage("csi app",
  tabPanel("portals",
  
  # titlePanel("Hello Shiny!"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("pick_taxa", label = "Pick a taxa", choices = unique(species$taxa)),
      sliderInput("pick_months", "Select which months to include", min = 1, max = 12, value = c(1,12)),
      downloadButton("download_data", label = "Download")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot",
                 h3(strong(textOutput("title_text"))),
                 plotOutput("taxa_plot"),
                 textOutput("max_year_text"),
                 verbatimTextOutput("max_year_text_print")),
        tabPanel("Data", icon = icon("wrench", lib = "font-awesome"),
                 dataTableOutput("surveys_data"))
      )
    )
  )),
  tabPanel("map", 
           leafletOutput("sesync_map", height = "600px")
           )
  
)