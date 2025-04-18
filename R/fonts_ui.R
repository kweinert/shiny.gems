#' fonts_ui/srv is a shiny module for managing fonts and fonts size
#'
#' The UI produces a subform that can be integrated in a settings/prefences tab. Inspired by the wikipedia mobile version (Feb. 2025), it displays a radiobutton choice
#' between "small", "standard", and "large". The default is "standard". The font family can not be altered by the user.
#'
#' For some plotting techniques (e.g. plotting with base R), the screen density is of importance.
#' window.devicePixelRatio is a JavaScript property that specifies the ratio between physical pixels (actual screen pixels) and 
#' CSS pixels (logical units for web design). It is a number, e.g:
#' 1: Standard resolution (1 CSS pixel = 1 physical pixel, e.g. older screens).
#' 2: Retina/High-DPI displays (1 CSS pixel = 2x2 physical pixels, e.g. many modern smartphones, MacBooks).
#' 3 or higher: Ultra-high-DPI displays (e.g. 4K monitors, newer devices).
#' fonts_ui uses Javascript to query the window.devicePixelRatio
#'
#' The module follows a singleton design pattern, hence the id is preset to "fonts". It is strongly recommended to keep that id.
#'
#' Run shiny::runApp(system.file("examples/03_fonts", package="shiny.gems")) to see the module in action, see fonts_srv for implementation details.
#'
#' @param id character, shiny id. Default "fonts"
#' @param ... further arguments that are passed to shiny::radioButtons(). In particular, "width" and "inline" can be set this way.
#' @return a shiny::div 
#' @export
fonts_ui <- function(id="fonts", ...) {
	ns <- shiny::NS(id)
	
	shiny::div(
		shiny::tags$script(HTML(paste0('
			$(document).on("shiny:connected", function() {
				var devicePixelRatio = window.devicePixelRatio || 1;
				Shiny.setInputValue("', ns("devicePixelRatio"), '", devicePixelRatio);
			});
		'))),
		uiOutput(ns("dynamic_font_style")), # Dynamic CSS for font scaling
		shiny::radioButtons(
			inputId=ns("pref"),
			label="Text Size:",
			selected = "standard",
			choiceNames = c("Small", "Standard", "Large"),
			choiceValues = c("small", "standard", "large"),
			...
		)
	)

}
