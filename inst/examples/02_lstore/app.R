# if not installed and we are not in a development setting, install the package
if(!requireNamespace("shiny.gems") && (!requireNamespace("pkgload") || !pkgload::is_dev_package("shiny.gems")))
	install.packages("shiny.gems", repos=c("https://kweinert.r-universe.dev", "https://cloud.r-project.org"))

# shiny::runApp(system.file("examples/02_lstore", package="shiny.gems"))
ui <- bslib::page_navbar(
  title = "Settings Demo",
  theme = bslib::bs_theme(version=5),
  header = lstore_ui("ls_demo"), # invisible, use header argument to avoid bslib warning
  
  bslib::nav_panel(
	"MRE",
	shiny::textInput("mre_input", "Enter some text:"),
	shiny::actionButton("mre_save", "Save to LocalStorage"),
    shiny::tags$hr(),
    shiny::h4("Stored Value:"),
    shiny::verbatimTextOutput("mre_stored_value")
  ),
  
  bslib::nav_panel(
	"Color Mode",
	colormode_ui()
  )
)


server <- function(input, output, session) {
	r <- shiny::reactiveValues(lstore=list())
	
	lstore_srv(id="ls_demo", r=r)
	
	# MRE tab
	shiny::observeEvent(input$mre_save, {
		r$lstore$mre <- input$mre_input
	})
	output$mre_stored_value <- shiny::renderText({
		message("output$mre_stored_value")
		shiny::req(r$lstore)
  	    r$lstore[["mre"]]
	})
	
	# color mode tab
	colormode_srv(r=r)
}

shiny::shinyApp(ui, server)

