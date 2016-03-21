# server.R

function(input, output){
  
  output$hist <- renderPlot({
    hist(rnorm(input$n))
  })
  
}
# 
# plots <- read.csv("../Data/plots.csv", stringsAsFactors = FALSE)
# species <- read.csv("../Data/species.csv", stringsAsFactors = FALSE)
# surveys <- read.csv("../Data/surveys.csv", na.strings = "", stringsAsFactors = FALSE)
# 
# # shiny app:
# 
# # input object to select the taxa with radio buttons or check boxes
# # use input to filter data and create a plot
# # plot how many total of that taxa in each year
# 
# bird_species <- filter(species, taxa == "Bird")$species_id #Bird is input$pick_taxa
# surveys_birds <- filter(surveys, species_id %in% bird_species)
# barplot(table(surveys_birds$year))
# 
# # Exercise: add an input feature to choose males, females, or both
# # hint: use either radio buttons or checkboxGroup input
# 
# # change layout so there are 2 plots displayed together
# 
# # make the filtered data set a reactive object to use in the plot and in another place
# 
# # add a tab with the data in a data table
# 
# # Add text that is a title for the graph with the appropriate selected taxa in it
# # Exercise: Below the graph, add text that says what year had the maximum number of that taxa recorded
# 
# # add a button to download a csv of the data or an image of the graph