# load_all("shiny.gems"); shiny::runApp(system.file("examples/03a_fonts", package="shiny.gems"))

library(shiny)
library(bslib)

# UI
ui <- bslib::page_sidebar(
	title = "Font Size",
	fillable = FALSE,
	sidebar = bslib::sidebar(
		shiny::radioButtons(
			inputId="pref",
			label="Text Size:",
			selected = "standard",
			choiceNames = c("Small", "Standard", "Large"),
			choiceValues = c("small", "standard", "large")
		)
	),
	shiny::markdown(
		"## Sample Markdown\n\nThis is *italic* and **bold** text. The size changes with your selection."
	),
    uiOutput("dynamic_font_style")
)
	  
# Server
server <- function(input, output, session) {

  text_scale <- reactive({
	switch(input$pref,
		   "small" = 0.8,
		   "standard" = 1.0,
		   "large" = 1.2)
  })
  
  currentScale <- 1
  
  observeEvent(input$pref, {
    scale <- text_scale()
    the_theme <- bs_current_theme()
    the_theme <- bs_theme_update(the_theme, font_scale = scale / currentScale)
    session$setCurrentTheme(the_theme)
    currentScale <<- scale
  })

}

shinyApp(ui = ui, server = server)
