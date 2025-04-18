#' fonts_ui/srv is a shiny module for managing fonts and fonts size
#'
#' The server follows the "petite r" approach. It expects a reactiveValues parameter r. It modifies the "fonts" entries.
#'
#' To save preferences across sessions, the lstore module is used if it is available.
#'
#' The module follows a singleton design pattern, hence the id is preset to "fonts". It is strongly recommended to keep that id.
#'
#' Run shiny::runApp(system.file("examples/03_fonts", package="shiny.gems")) to see the module in action.
#'
#' @param id character, shiny id. Default "colormode"
#' @param r shiny::reactiveValues object
#' @param verbose logical, diagnostic message, default FALSE
#' @return used for its side effects (in particular r)
#' @export
fonts_srv <- function(id="fonts", r, verbose=TRUE) {
  shiny::moduleServer(id=id, function(input, output, session) {
  
    # try to read saved preferences
	shiny::observeEvent(r$lstore, {
		if(verbose) message("fonts_srv: observeEvent(r$lstore)")
		shiny::req(shiny::isTruthy(r$lstore[["fonts"]]))
		shiny::updateRadioButtons(session=session, inputId="pref", selected=r$lstore[["fonts"]])
	})
	
	# try to save preferences
	# set the font_scale variable affects all of the UI elements (headers, navbar, inputs) except the plots.
	shiny::observeEvent(input$pref, {
		if(verbose) message("fonts_srv: observeEvent(input$pref)")
		#scale <- text_scale()
		#if(verbose) message("  scale: ", scale)
		#the_theme <- bslib::bs_current_theme()
		#the_theme <- bslib::bs_theme_update(the_theme, font_scale=scale)
		#bslib::bs_global_set(theme = the_theme)
		shiny::req(r$lstore)
		r$lstore[["fonts"]] <- input$pref
	})
	
	# Reactive text scale for UI and plot
	text_scale <- shiny::reactive({
		shiny::req(input$pref)
		switch(input$pref,
           "small" = 0.8,
           "standard" = 1.0,
           "large" = 1.2)
	})

	# https://stackoverflow.com/questions/79570749/dynamically-change-font-scale-of-bslib-shiny-app
	currentScale <- 1
	shiny::observeEvent(input$pref, {
		scale <- text_scale()
		the_theme <- bslib::bs_current_theme()
		the_theme <- bslib::bs_theme_update(the_theme, font_scale = scale / currentScale)
		session$setCurrentTheme(the_theme)
		currentScale <<- scale
	})
	
	# this reads window.devicePixelRatio
	res_sf <- shiny::reactive({
		shiny::req(input$devicePixelRatio)  
		dpi_ratio <- input$devicePixelRatio
		min(dpi_ratio, 2)  # Linear scaling, cap to 2 to avoid excessive scaling on very high-DPI devices
	})
	
	# this reads the fonts that are set in bslib::bs_theme
	# use sysfonts::font_add_google() and showtext::showtext_auto()
	# to enable their use
	font_families <- shiny::reactive({
		bs_fonts()[c("font-family-base", "headings-font-family")]
	})
	
	# only once
	shiny::observe({
		r$fonts$base_font <- font_families()[["font-family-base"]]
		r$fonts$heading_font <- font_families()[["headings-font-family"]]
		r$fonts$res_sf <- res_sf()
		r$fonts$user_pref <- input$pref
	})

  })
}
