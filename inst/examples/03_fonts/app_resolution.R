#https://stackoverflow.com/questions/35065086/shinyrenderplot-cannot-set-resolution-reactive

# shiny::runApp(system.file("examples/03_fontsize", package="shiny.gems"))

#https://stackoverflow.com/questions/35065086/shinyrenderplot-cannot-set-resolution-reactive

# shiny::runApp(system.file("examples/03_fontsize", package="shiny.gems"))

library(shiny)
library(bslib)
requireNamespace("titanic")
requireNamespace("ragg")
options(shiny.useragg = TRUE) # redundant, TRUE is the default

# UI Definition
ui <- bslib::page_navbar(
  theme = bslib::bs_theme(
	version = 5,
	base_font = font_google("Lexend"),
	heading_font = font_google("DM Serif Display")
  ),  # Bootstrap 5 Theme
  title = "Resolution",
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
		  shiny::plotOutput("default_plot")
		),
		bslib::card(
		  bslib::card_header("High Resolution"),
		  shiny::imageOutput("hires_plot")
		)
    ),
	shiny::verbatimTextOutput("screen_debug")  # Display screen info for debugging
  )
)

# Server Logic
server <- function(input, output, session) {
  
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
  
  # default resolution
  output$default_plot <- renderPlot({
	barplot(titanic_cnt(), beside = TRUE, 
        main = "Anzahl der Überlebenden nach Passagierklasse",
        xlab = "Passagierklasse", ylab = "Anzahl Passagiere",
        col = c("blue", "red"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n"))
  }) 
  
  output$hires_plot <- renderImage({
	plotinfo <- shiny::getCurrentOutputInfo()
    width <- plotinfo$width()
    height <- plotinfo$height()
    message("width=", width, ", height=", height)
    outfile <- tempfile(fileext = ".png")
    pixel_ratio <- 2.608696
    ragg::agg_png(
		file = outfile,
		width = width*pixel_ratio, 
		height = height*pixel_ratio, 
		bg = "white",  
		scaling = pixel_ratio,
		res = 72
	)
	barplot(titanic_cnt(), beside = TRUE, 
        main = "Anzahl der Überlebenden nach Passagierklasse",
        xlab = "Passagierklasse", ylab = "Anzahl Passagiere",
        col = c("blue", "red"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n")
	)
    dev.off()

    # Return a list containing information about the image
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)
  
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
