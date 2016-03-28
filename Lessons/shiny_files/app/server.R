# server.R
source("dependencies.R")
# Read in data

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
      addMarkers(lng = -76.505206, lat = 38.9767231, popup = "sesync") %>%
      addPolygons(fill = FALSE) %>%
      addRasterImage(mask(nlcd, nlcd == 41, maskvalue = FALSE), opacity = 0.5, group = "Deciduous Forest", colors = "green") %>%
      addRasterImage(mask(nlcd, nlcd == 81, maskvalue = FALSE), opacity = 0.5, group = "Pasture", colors = "yellow") %>%
      addLayersControl(baseGroups=c("Deciduous Forest", "Pasture"))
  })
  
  # observe({
  #   leafletProxy("sesync_map") %>%
  #     clearShapes() %>%
  #     addRasterImage(mask(nlcd, nlcd == 41, maskvalue = FALSE), opacity = input$opacity_slider, group = "Deciduous Forest", colors = "green")
  #     })

}