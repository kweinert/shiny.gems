library(shiny)
library(bslib)
library(DiagrammeR)

shiny::addResourcePath("prognos_www", system.file("www", package="prognos.selfservice"))

pcolors <- prognos.selfservice::prognos_colors()

ui <- page_sidebar(
  title = "Mermaid Diagramm Generator",
  theme = bs_theme(version = 5),
  tags$head(
    tags$link(rel = "stylesheet", href = "/prognos_www/fonts.css"),
	shiny::tags$script(src = "https://cdn.jsdelivr.net/npm/mermaid@11.6.0/dist/mermaid.min.js")
  ),
  uiOutput("dynamic_css"), # fill_color
  sidebar = sidebar(
    textAreaInput(
      inputId = "mermaid_code",
      label = "Mermaid Code",
      value = "A(Franklin Gothic)-->B\n  A-->C\n  B-->D\n  C-->D",
      rows = 5
    ),
	input_switch(
      id = "direction",
      label = "Links nach rechts",
      value = TRUE
    ),
	selectInput(
      inputId = "fill_color",
      label = "Standard-Füllfarbe",
      choices = names(pcolors),
      selected = names(pcolors)[1]
    ),
    actionButton("render", "Diagramm rendern"),
	shiny::actionButton("copy_diagram", "Diagramm in Zwischenablage kopieren")
  ),
  card(
    card_header("Diagramm"),
    DiagrammeROutput("diagram")
  )
)

server <- function(input, output, session) {
  observeEvent(input$render, {
    output$diagram <- renderDiagrammeR({
      # Richtung basierend auf Switch
      direction <- if (input$direction) "LR" else "TB" 
	  text_color <- match_text_color(pcolors[input$fill_color])
	  theme <- paste0("%%{
		  init: {
			'theme': 'base',
			'themeVariables': {
			  'primaryColor': '", pcolors[input$fill_color], "',
			  'primaryTextColor': '", text_color, "',
			  'primaryBorderColor': '", pcolors[input$fill_color], "',
			  'lineColor': '#000000'
			}
		  }
		}%%
	  ")
      mermaid_code <- paste0(theme, "\n", "graph ", direction, "\n", input$mermaid_code)
      mermaid(mermaid_code)
    })
  })
  
  # Handler für Kopieren in die Zwischenablage
  shiny::observeEvent(input$copy_diagram, {
	  shiny::tags$script(shiny::HTML("
		try {
		  const svgElement = document.querySelector('.mermaid > svg');
		  if (!svgElement) {
			alert('Kein Diagramm gefunden. Bitte rendern Sie zuerst ein Diagramm.');
			return;
		  }
		  // SVG-Markup extrahieren und xmlns hinzufügen
		  const svgMarkup = new XMLSerializer().serializeToString(svgElement);
		  const svgWithNamespace = `<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">${svgMarkup}</svg>`;
		  // In Zwischenablage kopieren
		  navigator.clipboard.writeText(svgWithNamespace).then(() => {
			alert('Diagramm erfolgreich in die Zwischenablage kopiert!');
		  }).catch(err => {
			alert('Fehler beim Kopieren: ' + err);
		  });
		} catch (err) {
		  alert('Fehler: ' + err);
		}
	  "))
  })
  
}

shinyApp(ui, server)
