# if not installed and we are not in a development setting, install the package
if(!requireNamespace("shiny.gems") && (!requireNamespace("pkgload") || !pkgload::is_dev_package("shiny.gems")))
	install.packages("shiny.gems", repos=c("https://kweinert.r-universe.dev", "https://cloud.r-project.org"))

# shiny::runApp(system.file("examples/01-persist", package="shiny.gems"))
ui <- bslib::page_navbar(
  title = "Color Mode Demo",
  theme = bslib::bs_theme(version=5),
  bslib::nav_panel(
	title = "Grid",
	bslib::card(
	  bslib::card_header("Titanic: Survival by Passenger Class"),
	  shiny::plotOutput("grid_mosaic")
	)
  ),
  bslib::nav_panel(
	title = "GGPlot2",
	bslib::card(
	  bslib::card_header("Titanic: Age vs. Fare"),
	  shiny::plotOutput("ggplot_scatter")
	)
  ),
  bslib::nav_panel(
	title="Colormode Vars",
	bslib::layout_columns(
		bslib::card(
			bslib::card_header("mode"),
			shiny::verbatimTextOutput("cm_mode"),
			min_height="102%"
		),
		bslib::card(
			bslib::card_header("pals"),
			shiny::verbatimTextOutput("cm_pals"),
			min_height="102%"
		),
		bslib::card(
			bslib::card_header("bs_pal"),
			shiny::verbatimTextOutput("cm_bspal"),
			min_height="102%"
		)
	)
  ),
  bslib::nav_spacer(),
  bslib::nav_panel(
	title="",
	icon=shiny::icon("cog", lib = "font-awesome"), 
	# colormode_ui(id="colormode")
	shiny.gems::colormode_ui()
  )
)

server <- function(input, output, session) {
	# this is currently the place to define the color palettes. Should this be moved and read from a config file or passed 
	# as an argument to the app?
	r <- shiny::reactiveValues(
		colormode=list(
			orig_pals=list(
				quali=paletteer::paletteer_d("wesanderson::GrandBudapest2") |> as.character()
			)
		)
	)
	# colormode_srv(id="colormode", r=r)
	shiny.gems::colormode_srv(r=r)
	
	# colormode tab
	output$cm_mode <- shiny::renderPrint(r$colormode$mode)
	output$cm_pals <- shiny::renderPrint(r$colormode$pals)
	output$cm_bspal <- shiny::renderPrint(r$colormode$bs_pal)
	
	# example data set, load only once
	titanic_dat <- shiny::reactive(titanic::titanic_train)
  
	# grid mosaic example
	output$grid_mosaic <- shiny::renderPlot({
		bg <- r$colormode$bs_pal[["body-bg"]]
		fg <- r$colormode$bs_pal[["body-color"]]
		clr <- r$colormode$pals$quali[1:2]

		# base mosaicplot does not allow changing the color of the variable names, so we use vcd::mosaic
		# vcd::mosaic does not allow changing the background color, so we use grid.rect
		# vcd::mosaic does not allow to change the title color, so we don't use the main argument
		grid::grid.newpage()
		grid::grid.rect(gp = grid::gpar(fill = bg, col = NA))  
		vcd::mosaic(
		  formula=as.formula("~ Survived + Pclass"),
		  data = titanic_dat(),
		  gp = grid::gpar(col = fg, fill=clr),
		  labeling_args = list(
			gp_labels = grid::gpar(col = fg),  
			gp_varnames = grid::gpar(col = fg) 
		  ),
		  newpage=FALSE # since we used grid.newpage() already
		)
	})
	
	# ggplot2 example
	output$ggplot_scatter <- shiny::renderPlot({
		clr <- r$colormode$pals$quali[1:2]
		pal <- r$colormode$bs_pal
		
		ggplot2::ggplot(titanic_dat(), ggplot2::aes(x = Age, y = Fare, color = factor(Survived))) +
		ggplot2::geom_point(alpha = 0.6, size = 3) +  
		ggplot2::scale_color_manual(values = c("0" = clr[1], "1" = clr[2]), labels = c("0" = "not survived", "1" = "survived")) +
		ggplot2::labs(
			title = NULL,
			x = "Age",
			y = "Fare",
			color = "Survived"
		) +
		ggplot2::theme_minimal() +
		ggplot2::theme(
			legend.position = "bottom",
			legend.title = ggplot2::element_blank(),
			plot.background = ggplot2::element_rect(fill = pal["body-bg"], color = pal["border-bg"]),  
			panel.background = ggplot2::element_rect(fill = pal["body-bg"], color = pal["border-bg"]),
			legend.background = ggplot2::element_rect(fill = pal["body-bg"], color = pal["border-bg"]),
			text = ggplot2::element_text(color = pal["body-color"]),  
			axis.text = ggplot2::element_text(color = pal["body-color"]),  
			axis.title = ggplot2::element_text(color = pal["body-color"]),  
			legend.text = ggplot2::element_text(color = pal["body-color"]),
			panel.grid.major = ggplot2::element_line(color = pal["border-color"]), 
			# panel.grid.minor = ggplot2::element_line(color = pal["border-color"]) # in case there is not -translucent
			panel.grid.minor = ggplot2::element_line(color = pal["border-color-translucent"])
		)   
  })
}

shiny::shinyApp(ui, server)

