#' Shiny Version of TryCatch
#'
#' Use in reactive context, i.e. inside a server function only.
#' 
#' @param session the app session object
#' @param expr R expression to evaluate safely
#' @return NULL
#' @export
exec_safely <- function(session, expr) {

	tryCatch(
		withCallingHandlers(
			warning=function(cnd) {
				msg <- paste(conditionMessage(cnd), sep="\n")
				shiny::showNotification(
					ui=msg,
					duration=10,
					closeButton=TRUE,
					type="warning"
				)
			},
			message=function(cnd) {
				msg <- paste(conditionMessage(cnd), sep="\n")
				shiny::showNotification(
					ui=msg,
					duration=5,
					closeButton=TRUE,
					type="message"
				)
			},
			expr
		),

		error=function(cnd) {
			msg <- paste(conditionMessage(cnd), sep="\n")
			shiny::showNotification(
				ui=msg,
				duration=10,
				closeButton=TRUE,
				type="error"
			)
		}
	)
}
