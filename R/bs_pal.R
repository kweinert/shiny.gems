#' Bootstrap Color Palette
#'
#' This function uses bslib::bs_current_theme() and bslib::bs_get_variables() to query the root level colors. 
#' If dark ist TRUE, it returns the "-dark" variables. The names of the returned vector are however those used for the light mode.
#'
#' Note that there is a slightly different naming convention for highlight/highlight-bg. In dark mode, these colors are stored under
#' mark-color-dark/mark-bg-dark.
#'
#' This function should be called in a reactive context.
#' 
#' See https://getbootstrap.com/docs/5.3/customize/color-modes/ for more information on the color mode.
#'
#' @param dark logical, default FALSE
#' @return a named character vector, with names body-bg, body-color, body-emphasis-color, body-secondary-color, body-secondary-bg,
#'	body-tertiary-color, body-tertiary-bg, headings-color, link-color, link-hover-color, 
#'	code-color, highlight-color, highlight-bg, border-color, border-color-translucent, 
#'	form-valid-color, form-valid-border-color, form-invalid-color, form-invalid-border-color
#' @export
bs_pal <- function(dark=FALSE) {
	current_theme <- bslib::bs_current_theme()
	varnames_dark <- c(
		"body-bg-dark", "body-color-dark", "body-emphasis-color-dark", "body-secondary-color-dark", "body-secondary-bg-dark",
		"body-tertiary-color-dark", "body-tertiary-bg-dark", "headings-color-dark", "link-color-dark", "link-hover-color-dark", 
		"code-color-dark", "mark-color-dark", "mark-bg-dark", "border-color-dark", "border-color-translucent-dark", "form-valid-color-dark",
		"form-valid-border-color-dark", "form-invalid-color-dark", "form-invalid-border-color-dark"
	)
	varnames_light <- c(
		"body-bg", "body-color", "body-emphasis-color", "body-secondary-color", "body-secondary-bg",
		"body-tertiary-color", "body-tertiary-bg", "headings-color", "link-color", "link-hover-color", 
		"code-color", "highlight-color", "highlight-bg", "border-color", "border-color-translucent", 
		"form-valid-color", "form-valid-border-color", "form-invalid-color", "form-invalid-border-color"
	)
	
	ans <- stats::setNames(
		bslib::bs_get_variables(current_theme, varnames=if(dark) varnames_dark else varnames_light),
		varnames_light
	)
	
	sapply(ans, \(x) if(grepl("^rgba\\(", x)) {
		regex <- "(\\d+(?:\\.\\d+)?)"
		rgba <- regmatches(x, gregexpr(regex, x, perl = TRUE))[[1]]
		stopifnot(length(rgba)==4)
		rgba <- as.numeric(rgba) |> pmin(255) |> pmax(0)
		sprintf("#%02X%02X%02X%02X", rgba[1], rgba[2], rgba[3], round(rgba[4] * 255))
	} else x)

}
