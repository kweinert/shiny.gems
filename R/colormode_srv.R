#' colormode_ui/srv is a shiny module for managing colors; in particular enabling dark mode.
#'
#' The server follows the "petite r" approach. It expects a reactiveValues parameter r. It modifies "colormode" entries
#'
#' To save preferences across sessions, the lstore module is used if it is available.
#'
#' The module follows a singleton design pattern, hence the id is preset to "colormode". It is strongly recommended to keep that id.
#'
#' See shiny::runApp(system.file("examples/01_colormode", package="shiny.gems"))
#' to see the module in action, see colormode_srv for implementation details.
#'
#' @param id character, shiny id. Default "colormode"
#' @param r shiny::reactiveValues object
#' @param verbose logical, diagnostic message, default FALSE
#' @return used for its side effects
#' @export
colormode_srv <- function(id="colormode", r, verbose=FALSE) {
  shiny::moduleServer(id=id, function(input, output, session) {
  
	shiny::observeEvent(r$lstore, {
		if(verbose) message("colormode_srv: observeEvent(r$lstore)")
		shiny::req(shiny::isTruthy(r$lstore[["colormode"]]))
		shiny::updateRadioButtons(session=session, inputId="pref", selected=r$lstore[["colormode"]])
	})
	
	shiny::observeEvent(input$pref, {
		if(verbose) message("colormode_srv: observeEvent(input$pref)")
		r$lstore[["colormode"]] <- input$pref
	})
	
	current_mode <- shiny::reactive({
		if(verbose)  message("colormode_srv: current_mode()")
		ans <- if(input$pref=="clock") 
			input[["colormode_time_status"]] # this variable is curated by JS; see colormode_ui
		else if(input$pref=="system") 
			if (isTRUE(input[["colormode_system_status"]])) "dark" else "light"
		else
			input$pref
		r$colormode[["current_mode"]] <- ans
		return(ans)
	})

	shiny::observeEvent(current_mode(), {
		if(verbose)  message("colormode_srv: observeEvent(current_mode())")
		bslib::toggle_dark_mode(mode=current_mode())
		r$colormode$pals = if(current_mode()=="dark") lapply(r$colormode$orig_pals, adjust_colors_to_darkmode) else r$colormode$orig_pals
		r$colormode$bs_pal = bs_pal(dark=current_mode()=="dark")
	})

  })
}
