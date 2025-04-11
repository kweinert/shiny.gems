#https://stackoverflow.com/questions/35065086/shinyrenderplot-cannot-set-resolution-reactive

# shiny::runApp(system.file("examples/03_fontsize", package="shiny.gems"))

#https://stackoverflow.com/questions/35065086/shinyrenderplot-cannot-set-resolution-reactive

# shiny::runApp(system.file("examples/03_fontsize", package="shiny.gems"))

library(shiny)
library(bslib)
library(ggplot2)
library(data.table)
requireNamespace("titanic")

# UI Definition
ui <- bslib::page_navbar(
  theme = bslib::bs_theme(version = 5),  # Bootstrap 5 Theme
  title = "Fontsize",
  tags$head(
    # JavaScript to detect screen info and send to Shiny
    tags$script(HTML('
      $(document).on("shiny:connected", function() {
        var screenInfo = {
          width: window.screen.width,
          height: window.screen.height,
          dpi: window.devicePixelRatio
        };
        console.log("Screen Info:", screenInfo); // Debugging im Browser
        Shiny.setInputValue("screen_info", screenInfo);
      });
    '))
  ),
  bslib::nav_panel(
	"Base R",
    bslib::layout_columns(
		bslib::card(
		  bslib::card_header("Default Resolution"),
		  shiny::plotOutput("default_plot", width = "400px", height = "400px")
		),
		bslib::card(
		  bslib::card_header("High Resolution"),
		  plotOutput("hires_plot", width = "400px", height = "400px")
		)
    ),
	verbatimTextOutput("screen_debug")  # Display screen info for debugging
  )
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
  
  titanic_dat <- shiny::reactive(titanic::titanic_train)
  titanic_cnt <- shiny::reactive(xtabs(~ Survived + Pclass, data = titanic_dat()))
  
  # Plot with normal label sizes
  output$default_plot <- renderPlot({
	barplot(titanic_cnt(), beside = TRUE, 
        main = "Anzahl der Überlebenden nach Passagierklasse",
        xlab = "Passagierklasse", ylab = "Anzahl Passagiere",
        col = c("blue", "red"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n"))
  }) #, res = 96)
  
  # Plot with large label sizes
  output$hires_plot <- renderPlot({
	barplot(titanic_cnt(), beside = TRUE, 
        main = "Anzahl der Überlebenden nach Passagierklasse",
        xlab = "Passagierklasse", ylab = "Anzahl Passagiere",
        col = c("blue", "red"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n"))
  }, res = 144)
    
  # Debug output to display screen info
  output$screen_debug <- renderPrint({
    screen_info <- input$screen_info
    if (is.null(screen_info)) {
      "Waiting for screen info..."
    } else {
      cat(
        "Screen Width: ", screen_info$width, "px\n",
        "Screen Height: ", screen_info$height, "px\n",
        "Device Pixel Ratio: ", screen_info$dpi, "\n",
        "Selected DPI: ", plot_dpi(), "\n",
        sep = ""
      )
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)
