#https://stackoverflow.com/questions/35065086/shinyrenderplot-cannot-set-resolution-reactive

library(shiny)
library(ggplot2)
library(data.table)

# UI Definition
ui <- fluidPage(
  tags$head(
    # JavaScript to detect screen info and send to Shiny
    tags$script(HTML('
      document.addEventListener("DOMContentLoaded", function() {
        var screenInfo = {
          width: window.screen.width,
          height: window.screen.height,
          dpi: window.devicePixelRatio
        };
        Shiny.setInputValue("screen_info", screenInfo);
      });
    '))
  ),
  titlePanel("Horizontal Bar Plots with Dynamic DPI"),
  fluidRow(
    column(6, 
           h3("Normal Label Sizes"),
           plotOutput("normal_plot", width = "400px", height = "400px")
    ),
    column(6, 
           h3("Large Label Sizes"),
           plotOutput("large_plot", width = "400px", height = "400px")
    )
  ),
  verbatimTextOutput("screen_debug")  # Display screen info for debugging
)

# Server Logic
server <- function(input, output, session) {
  
  # Sample dataset
  data <- data.table(
    category = rep(c("A", "B", "C"), each = 2),
    group = rep(c("Very Long Label 1", "Very Long Label 2"), times = 3),
    value = c(4, 6, 5, 7, 7, 9)
  )
  
  # Reactive value for DPI based on screen info
  plot_dpi <- reactive({
    screen_info <- input$screen_info
    if (is.null(screen_info)) return(96)  # Default DPI if no info yet
    
    width <- screen_info$width
    height <- screen_info$height
    dpi_ratio <- screen_info$dpi
    
    # Check for 4K (e.g., 3840x2160 or higher) or high-DPI display
    if (width >= 3840 && height >= 2160) {
      return(144)  # Higher DPI for 4K
    } else if (dpi_ratio > 1.5) {
      return(144)  # High-DPI (e.g., Retina, >150% scaling)
    } else {
      return(96)   # Standard DPI
    }
  })
  
  # Plot with normal label sizes
  output$normal_plot <- renderPlot({
    ggplot(data, aes(y = group, x = value, fill = group)) +
      geom_bar(stat = "identity") +
      facet_wrap(~ category) +
      labs(x = "Value", y = "Group Category") +
      theme(
        plot.margin = margin(20, 20, 20, 20, "pt"),
        strip.text = element_text(size = 12),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10),
        legend.position = "none"
      )
  }, res = isolate(plot_dpi()))
  
  # Plot with large label sizes
  output$large_plot <- renderPlot({
    ggplot(data, aes(y = group, x = value, fill = group)) +
      geom_bar(stat = "identity") +
      facet_wrap(~ category) +
      labs(x = "Value", y = "Group Category") +
      theme(
        plot.margin = margin(20, 20, 20, 20, "pt"),
        strip.text = element_text(size = 20),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 16),
        legend.position = "none"
      )
  }, res = isolate(plot_dpi()))
  
  # Debug output to display screen info
  output$screen_debug <- renderPrint({
    screen_info <- input$screen_info
    if (is.null(screen_info)) {
      "Waiting for screen info..."
    } else {
      paste("Screen Width:", screen_info$width, "px",
            "\nScreen Height:", screen_info$height, "px",
            "\nDevice Pixel Ratio:", screen_info$dpi,
            "\nSelected DPI:", plot_dpi())
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)