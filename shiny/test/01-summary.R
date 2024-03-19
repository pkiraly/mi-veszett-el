library(shiny)
library(tidyverse)

ui <- fluidPage(
  "Hello, world!",
  verbatimTextOutput("summary")
)

server <- function(input, output, session) {
  output$summary <- renderPrint({
    df <- read_tsv('data/rmny-1-5.tsv')
    summary(df)
  })
}

shinyApp(ui, server)