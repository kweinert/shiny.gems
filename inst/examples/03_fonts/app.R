# sudo apt-get install libfreetype6-dev
# shiny::runApp(system.file("examples/03_fonts", package="shiny.gems"))

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
	heading_font = sass::font_google("DM Serif Display"),
	font_scale = 1
  ),  # Bootstrap 5 Theme
  title = "Fonts",
  bslib::nav_panel(
	"Base R",
	bslib::card(
	  bslib::card_header("Default Resolution"),
	  shiny::plotOutput("base_plot")
	)
  )
)

# Server Logic
server <- function(input, output, session) {
  
  titanic_dat <- shiny::reactive(titanic::titanic_train)
  titanic_cnt <- shiny::reactive(xtabs(~ Survived + Pclass, data = titanic_dat()))
  
  # base r example
  output$base_plot <- renderPlot({
	par(family = "Lexend", cex=2) 
	barplot(titanic_cnt(), beside = TRUE, 
        xlab = "Passagierklasse", ylab = "Anzahl Passagiere",
        col = c("blue", "red"),
        legend.text = c("Not Survived", "Survived"),
        args.legend = list(x = "topleft", bty = "n"))
  }) 
  

}

# Run the app
shinyApp(ui = ui, server = server)
