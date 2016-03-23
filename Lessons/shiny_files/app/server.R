# server.R
library(dplyr)
library(shiny)
# Read in data
plots <- read.csv("Data/plots.csv", stringsAsFactors = FALSE)
species <- read.csv("Data/species.csv", stringsAsFactors = FALSE)
surveys <- read.csv("Data/surveys.csv", na.strings = "", stringsAsFactors = FALSE)
huc_md <- readRDS("/nfs/public-data/ci-spring2016/Geodata/huc_md.RData")


function(input, output){
  
  surveys_subset <- reactive({
    taxa_subset <- filter(species, taxa == input$pick_taxa)$species_id
    # taxa_subset <- subset(species, taxa == input$pick_taxa, select = species_id) # if dplyr not loaded
    surveys_subset <- filter(surveys, species_id %in% taxa_subset & month %in% input$pick_months[1]:input$pick_months[2])
    return(surveys_subset)
  })
  
  output$taxa_plot <- renderPlot({
    barplot(table(surveys_subset()$year))
  })
  
  output$title_text <- renderText({
    paste0("Total number of ", input$pick_taxa, "s observed by year in months ", input$pick_months[1], " through ", input$pick_months[2])
  })
  
  output$max_year_text <- renderText({
    max_year <- names(tail(sort(table(surveys_subset()$year)),1))
    paste0("The most ", input$pick_taxa, "s were recorded in ",max_year)
  })
  
  output$max_year_text_print <- renderPrint({
    max_year <- names(tail(sort(table(surveys_subset()$year)),1))
    paste0("The most ", input$pick_taxa, "s were recorded in ",max_year)
  })
  
  output$surveys_data <- renderDataTable({
    surveys_subset()
  })
  
  # output$download_data <- downloadHandler(
  #   filename = "portals_subset.csv",
  #   content = function(file) {
  #     write.csv(surveys_subset(), file)
  #   }
  # )
  
  output$download_data <- downloadHandler(
    filename = function() { 
      paste("portals_", input$pick_taxa, ".csv", sep="") 
    },
    content = function(file) {
      write.csv(surveys_subset(), file)
    }
  )
  
  output$sesync_map <- renderLeaflet({
    leaflet(counties_md) %>% 
      setView(lng = -76.505206, lat = 38.9767231, zoom = 14) %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addMarkers(lng = -76.505206, lat = 38.9767231, popup = "SESYNC") %>%
      addPolygons(fill = FALSE)   %>%
      addRasterImage(mask(nlcd, nlcd == 41, maskvalue = FALSE), opacity = 0.5)
  })

}