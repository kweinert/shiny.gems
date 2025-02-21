#' colormode_ui/srv is a shiny module for managing colors; in particular enabling dark mode.
#'
#' The server follows the "petite r" approach. It expects a reactiveValues parameter r. It modifies entries of the "colormode
#'
#' Currently, it is not possible to save the setting across session. This would require a user management.
#'
#' The module follows a singleton design pattern, hence the id is preset to "colormode". It is strongly recommended to keep that id.
#'
#' See colormode_demo to see the module in action, see colormode_srv for implementation details.
#'
#' @param id character, shiny id. Default "colormode"
#' @param lang character, currently supported are "en" and "de". Default "en".
#' @param ... further arguments that are passed to shiny::radioButtons(). In particular, "width" and "inline" can be set this way.
#' @return the output of shiny::radioButtons() 
#' @export
colormode_srv <- function(id="colormode", r) {
  moduleServer(id=id, function(input, output, session) {
	
	current_mode <- shiny::reactive({
		# message("colormode_srv: current_mode()")
		ans <- if(input$pref=="auto") 
			input$auto_status # this variable is curated by JS; see colormode_ui
		else
			input$pref
		return(ans)
	})

	shiny::observeEvent(current_mode(), {
		# message("colormode_srv: observeEvent(current_mode())")
		bslib::toggle_dark_mode(mode=current_mode())
		r$colormode$mode = current_mode()
		r$colormode$pals = lapply(r$colormode$orig_pals, \(x) 
			colorspace::lighten(x, if(current_mode()=="dark") 0.15 else -0.15) 
		)
		r$colormode$bs_pal = bs_pal(dark=current_mode()=="dark")
	})

  })
}