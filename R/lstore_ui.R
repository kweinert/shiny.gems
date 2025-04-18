#' lstore_ui/srv is a shiny module saving/restoring data in the browser's local store
#'
#' The UI is hidden and contains an initializiation javascript function.
#'
#' See 
#' shiny::runApp(system.file("examples/02_lstore", package="shiny.gems"))
#' to see the module in action, see colormode_srv for implementation details.
#'
#' @param id character, shiny id. Default "lstore"
#' @return hidden div with initialization script only
#' @export
lstore_ui <- function(id) {
  ns <- NS(id)
  
  shiny::tagList(
    shiny::tags$div(id = ns("lstore-init"), style = "display: none;",
		shiny::tags$script(HTML(paste0("
		  // Listen for messages from Shiny
		  Shiny.addCustomMessageHandler('saveToLocalStorage_", id, "', function(value) {
			localStorage.setItem('", id, "', JSON.stringify(value));
		  });

		  Shiny.addCustomMessageHandler('loadFromLocalStorage_", id, "', function(message) {
			var value = localStorage.getItem('", id, "');
			// Send the value back to Shiny
			Shiny.setInputValue('", ns("lstore"), "', JSON.parse(value), {priority: 'event'});
		  });
		")))
    )
  )
}
