#' lstore_ui/srv is a shiny module saving/restoring data in the browser's local store
#'
#' The server follows the "petite r" approach. It expects a reactiveValues parameter r. It modifies "lstore" entries
#'
#' The module follows a singleton design pattern, hence the id is preset to "lstore". It is strongly recommended to keep that id.
#'
#' See 
#' shiny::runApp(system.file("examples/02_lstore", package="shiny.gems"))
#' to see the module in action, see colormode_srv for implementation details.
#'
#' @param id character, shiny id. Default "lstore"
#' @param r shiny::reactiveValues object
#' @param verbose logical, diagnostic message, default FALSE
#' @return used for its side effects
#' @export
lstore_srv <- function(id="lstore", r, verbose=TRUE) {
  shiny::moduleServer(id=id, function(input, output, session) {
  
	# Automatically load the saved value when the app starts
    if(verbose) message("lstore: startup")	  
    session$sendCustomMessage(type=paste0("loadFromLocalStorage_", id), message=list())
	
	shiny::observeEvent(input$lstore, {
		if(verbose) message("lstore: observeEvent input$lstore")
		r$lstore <- input$lstore
	})
	
	# Save settings whenever r changes
    shiny::observeEvent(r$lstore, {
	  if(verbose) message("lstore: observeEvent r$lstore")
      if (length(r$lstore) > 0) {
		if(verbose) message("saving to local storage, id=", id)
        session$sendCustomMessage(type=paste0("saveToLocalStorage_", id), message=r$lstore)
      }
    })

  })
}
