#' colormode_ui/srv is a shiny module for managing colors; in particular enabling dark mode.
#'
#' The UI produces a subform that can be integrated in a settings/prefences tab. Inspired by the wikipedia mobile version (Feb. 2025), it displays a radiobutton choice
#' between "light", "dark", and "automatic". The default is "light".
#'
#' For the automatic setting, Javascript is used to determine the local hour. The Javascript code curates a variable "auto_status" that is accessible tin the server
#' module. In particular, the Javascript updates "auto_status" when at 8pm and 6am.
#'
#' The module follows a singleton design pattern, hence the id is preset to "colormode". It is strongly recommended to keep that id.
#'
#' Run shiny::runApp(system.file("examples/01_colormode", package="shiny.gems"))
#' to see the module in action, see colormode_srv for implementation details.
#'
#' @param id character, shiny id. Default "colormode"
#' @param ... further arguments that are passed to shiny::radioButtons(). In particular, "width" and "inline" can be set this way.
#' @return a shiny::div 
#' @export
colormode_ui <- function(id="colormode", ...) {
	ns <- shiny::NS(id)
	dark_starts <- 18
	light_starts <- 6
	
	shiny::div(
		shiny::tags$script(shiny::HTML(paste0("
			function updateTimeStatus() {
				var now = new Date();
				var hours = now.getHours(); // local hour
				var status = (hours >= ", dark_starts, " || hours < ", light_starts, ") ? 'dark' : 'light'; 
				Shiny.setInputValue('", ns("colormode_time_status"), "', status);

				// when does the next change happen?
				var nextUpdateTime;
				if (hours < 20) {
				  // next change at 8pm
				  nextUpdateTime = new Date(now);
				  nextUpdateTime.setHours(", dark_starts, ", 0, 0, 0); 
				} else {
				  // next change at 6 am
				  nextUpdateTime = new Date(now);
				  nextUpdateTime.setDate(nextUpdateTime.getDate() + 1); // next day
				  nextUpdateTime.setHours(", light_starts, ", 0, 0, 0); 
				}

				// set timer after remaining ms until next change
				var timeUntilUpdate = nextUpdateTime - now;
				setTimeout(updateTimeStatus, timeUntilUpdate);
			}

			// initial status 
			$(document).on('shiny:connected', function() {
				updateTimeStatus();
			});

			// shiny message handler (for the initial call)
			Shiny.addCustomMessageHandler('updateTimeStatus', function(message) {
				 updateTimeStatus();
			});
			
			// check system settings
			$(document).on('shiny:connected', function() {
				var isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
				Shiny.setInputValue('", ns("colormode_system_status"), "', isDarkMode);
				
				// react to changes
				window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
				  Shiny.setInputValue('", ns("colormode_system_status"), "', e.matches);
				});
			});
		"))),
		shiny::radioButtons(
			inputId=ns("pref"),
			label="Color:",
			selected = "light",
			choiceNames = c("Light", "Dark", "Automatic (Clock)", "Automatic (System)"),
			choiceValues = c("light", "dark", "clock", "system"),
			...
		)
	)

}
