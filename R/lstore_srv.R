
lstore_srv <- function(id, r, verbose=TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
  
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