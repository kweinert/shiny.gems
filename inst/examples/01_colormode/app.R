
# if not installed and we are not in a development setting, install the package
if(!requireNamespace("shiny.gems") && (!requireNamespace("pkgload") || !pkgload::is_dev_package("shiny.gems")))
	install.packages("shiny.gems", repos=c("https://kweinert.r-universe.dev", "https://cloud.r-project.org"))

# shiny::runApp(system.file("examples/01_colormode", package="shiny.gems"))
ui <- bslib::page_navbar(
  title = "Color Mode Demo",
  theme = bslib::bs_theme(version=5),
  
  bslib::nav_panel(
    title="Base",
	bslib::card(
	  bslib::card_header("Titanic: Age Distribution"),
	  shiny::plotOutput("base_hist")
	)
  ),
  bslib::nav_panel(
	title = "Grid",
	bslib::card(
	  bslib::card_header("Titanic: Survival by Passenger Class"),
	  shiny::plotOutput("grid_mosaic")
	)
  ),
  bslib::nav_panel(
	title = "Plotly",
	bslib::card(
	  bslib::card_header("Titanic: Gender vs. Class vs. Survival"),
	  plotly::plotlyOutput("plotly_sankey")
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
	title= "Reactable",
	reactable::reactableOutput("table")
  ),
  bslib::nav_panel(
	title="ECharts4R",
	bslib::card(
		bslib::card_header("Titanic: Survivors"),		
		echarts4r::echarts4rOutput("gauge_chart")
	)
  ),
  bslib::nav_panel(
	title="Colormode Vars",
	shiny::h3("pals"),
	shiny::verbatimTextOutput("cm_pals"),
	shiny::h3("bs_pal"),
	shiny::verbatimTextOutput("cm_bspal")
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
	shiny.gems::colormode_srv(r=r)
	
	# colormode tab
	output$cm_pals <- shiny::renderPrint(r$colormode$pals)
	output$cm_bspal <- shiny::renderPrint(r$colormode$bs_pal)
	
	# example data set, load only once
	titanic_dat <- shiny::reactive(titanic::titanic_train)
	
	# base hist() example
	# bg is not passed on from hist(), so we have to use par(). 
	# The other params (col.main, col.lab, col.axis) could also be set within hist()
	# col and border can only be set in hist().
	output$base_hist <- shiny::renderPlot({
		bspal <- r$colormode$bs_pal
		par(
			bg=r$colormode$bs_pal[["body-bg"]], 
			col.main = bspal[["body-color"]], col.lab = bspal[["body-color"]], col.axis = bspal[["body-color"]], 
			col=bspal[["border-color"]] # for the axis
		)
		hist(
			x=titanic_dat()[["Age"]], 
			xlab="Age", main="",
			col = r$colormode$pals$quali[1], # for the bars
			border= bspal[["border-color"]],
			axes=FALSE
		)
		axis(1, col = bspal[["border-color"]], col.ticks = bspal[["border-color"]])
		axis(2, col = bspal[["border-color"]], col.ticks = bspal[["border-color"]])
	})
  
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
	
	# reactable example
    output$table <- reactable::renderReactable({

		pal <- r$colormode$bs_pal
		tbl_theme <- reactable::reactableTheme(
			backgroundColor = pal[["body-bg"]],
			color = pal[["body-color"]],
			borderColor = pal[["border-color"]],
			headerStyle = list(
			  backgroundColor = pal[["body-bg"]],
			  color = pal[["body-color"]]
			)
		)
		reactable::reactable(
			titanic_dat(),
			fullWidth=FALSE,
			width="99%", # avoid horizontal scrollbar
			defaultPageSize = 8,
			theme=tbl_theme
		)
	})
	
	# plotly example
	output$plotly_sankey <- plotly::renderPlotly({
		pal <- r$colormode$bs_pal
		clr <- r$colormode$pals$quali[1:2]
		
		nodes <- list(
			label = c("male", "female", "Class 1", "Class 2", "Class 3", "died", "survived"),
			color = rep(clr[[1]],7),
			pad = 15,
			thickness = 20,
			line = list(color = pal[["border-color"]], width = 0.5)
		)

		x <- titanic::titanic_train
		links1 <- xtabs(~Sex+Pclass, x) |> as.data.frame(stringsAsFactors=FALSE)
		colnames(links1) <- c("from", "to", "value")
		links1 <- transform(links1, to=paste("Class", to))
		links2 <- xtabs(~Pclass+Survived,x) |> as.data.frame(stringsAsFactors=FALSE)
		colnames(links2) <- c("from", "to", "value")
		links2 <- transform(links2, to=ifelse(to==0, "died", "survived"), from=paste("Class", from))
		links <- rbind(links1, links2) |>		
			transform(
				source = match(from, nodes[["label"]]) - 1,
				target = match(to, nodes[["label"]]) - 1,
				color = clr[[2]]
			)

		plotly::plot_ly(
			type = "sankey",
			orientation = "h",
			node=nodes,
			link=links,
			textfont=list(color=pal[["body-color"]]) # shadow="none" has no effect
		) |> 
		plotly::layout(
			plot_bgcolor = pal[["body-bg"]],  
			paper_bgcolor = pal[["body-bg"]]
		)
	})
	
	# echarts4r example
	# note the darkMode argument, new in version 5
	# there is also: echarts4r::e_color(background = background_color) 
    output$gauge_chart <- echarts4r::renderEcharts4r({
		pal <- r$colormode$bs_pal
		clr <- r$colormode$pals$quali[2]
        background_color <- pal[["body-bg"]]
        survival_rate <- (table(titanic_dat()[,"Survived"]) |> proportions())["1"] * 100 
		echarts4r::e_charts(darkMode=isTRUE(r$colormode[["current_mode"]]=="dark")) |>
		  echarts4r::e_gauge(
			value = round(unname(survival_rate), 1),  # Anteil Überlebende (gerundet)
			name = "Survival Rate",
			min = 0,
			max = 100,
			detail = list(formatter = "{value}%"),
			pointer = list(
			  itemStyle = list(
				color = clr
			  )
			),
			axisLine = list(
			  lineStyle = list(
				color = list(
				  list(1, clr)  # Farbe der Gauge
				)
			  )
			)
		  )
    })
}

shiny::shinyApp(ui, server)

