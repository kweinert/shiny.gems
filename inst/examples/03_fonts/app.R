# sudo apt-get install libfreetype6-dev
# http://www.identifont.com/differences?first=Lora&second=Playfair+Display&q=Go
# load_all("shiny.gems"); shiny::runApp(system.file("examples/03_fonts", package="shiny.gems"))

library(shiny)
library(bslib)
requireNamespace("titanic")
requireNamespace("sass") # font_google
requireNamespace("showtext")
requireNamespace("sysfonts")

# Google Fonts für Plots laden
sysfonts::font_add_google("Lexend", "Lexend")
showtext::showtext_auto()

# UI Definition
ui <- bslib::page_navbar(
  theme = bslib::bs_theme(
	version = 5,
	base_font = sass::font_google("Lexend"),
	heading_font = sass::font_google("Lora", wght = c(300, 400, 700)),
	font_scale = 1
  ) |> 
  bslib::bs_add_rules("
      $heading-margin-top: 1.5rem;
      $heading-margin-bottom: 0.5rem;

      h1, h2, h3, h4, h5, h6 {
        margin-top: $heading-margin-top;
        margin-bottom: $heading-margin-bottom;
      }
  "),
  title = "Fonts",
  fillable = FALSE,
  bslib::nav_panel(
	"Base R",
	bslib::card(
	  bslib::card_header("Default Resolution"),
	  shiny::plotOutput("base_plot"),
	  min_height=400
	),
	bslib::card(
	  shiny::verbatimTextOutput("screen_debug")  # Display screen info for debugging
    )
  ),
  bslib::nav_panel(
    "Shiny Inputs",
    bslib::layout_columns(
		col_widths = c(4, 4, 4),
		bslib::card(
			bslib::card_header("Button Inputs"),
			min_height=500,
			#shiny::submitButton("Submit Button"),
			shiny::actionButton("action_btn", "Action Button"),
			shiny::actionLink("action_link", "Action Link"),
			shiny::downloadButton("download_btn", "Download Button"),
			shiny::fileInput("file_input", "File Input")
		),
		bslib::card(
			bslib::card_header("Text and Numeric Inputs"),
			shiny::textInput("text_input", "Text Input", value = "Enter text"),
			shiny::passwordInput("password_input", "Password Input", value = "password"),
			shiny::textAreaInput("textarea_input", "Text Area Input", value = "Enter multiple lines", rows = 4),
			shiny::numericInput("numeric_input", "Numeric Input", value = 42, min = 0, max = 100, step = 1)
		),
		bslib::card(
			bslib::card_header("Selection Inputs"),
			shiny::selectInput("select_input", "Select Input", choices = c("Option 1", "Option 2", "Option 3"), selected = "Option 1"),
			shiny::selectInput("select_multi", "Select Input (Multiple)", choices = c("Option A", "Option B", "Option C"), multiple = TRUE),
			shiny::radioButtons("radio_buttons", "Radio Buttons", choices = c("Choice 1", "Choice 2", "Choice 3"), selected = "Choice 1"),
			shiny::checkboxInput("checkbox_single", "Checkbox (Single)", value = FALSE),
			shiny::checkboxGroupInput("checkbox_group", "Checkbox Group", choices = c("Item A", "Item B", "Item C"), selected = "Item A")
		),
		bslib::card(
			bslib::card_header("Date and Time Inputs"),
			shiny::dateInput("date_input", "Date Input", value = Sys.Date()),
			shiny::dateRangeInput("date_range_input", "Date Range Input", start = Sys.Date() - 7, end = Sys.Date())
		),
		bslib::card(
			bslib::card_header("Slider Inputs"),
			shiny::sliderInput("slider_single", "Slider (Single Value)", min = 0, max = 100, value = 50),
			shiny::sliderInput("slider_range", "Slider (Range)", min = 0, max = 100, value = c(25, 75))
		)
	)
  ),
  bslib::nav_panel(
	"Markdown",
	shiny::markdown(readLines(system.file("examples/03_fonts/sample_doc.md", package="shiny.gems")))
  ),
  bslib::nav_spacer(),
  bslib::nav_panel(
	title="",
	icon=shiny::icon("cog", lib = "font-awesome"), 
	shiny.gems::fonts_ui()
  )
)
 

# Server Logic
server <- function(input, output, session) {
	
  r <- shiny::reactiveValues(fonts=list())
  shiny.gems::fonts_srv(r=r)

  titanic_dat <- shiny::reactive(titanic::titanic_train)
  titanic_cnt <- shiny::reactive(xtabs(~ Survived + Pclass, data = titanic_dat()))
  
  # base r example
  output$base_plot <- shiny::renderPlot({
	shiny::req(r$fonts[["res_sf"]])
	
	plotinfo <- shiny::getCurrentOutputInfo()
    width <- plotinfo$width()
    
    base_cex <- r$fonts[["res_sf"]] * if (width < 450) 0.8 else if (width < 600) 0.9 else 1
    par(family = "Lexend", cex=base_cex)
    
	message("re-rendering @width=", width, ", cex=", base_cex)
	barplot(titanic_cnt(), beside = TRUE, 
        xlab = "Passenger Class", ylab = "Number of Passengers",
        col = c("darkgray", "white"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n"))
  }) 
  
  # Debug output to display screen info
  output$screen_debug <- shiny::renderPrint({
    cat("Resolution Scaling Factor: ", r$fonts[["res_sf"]], sep = "")
  })
  

}

# Run the app
shiny::shinyApp(ui = ui, server = server)
