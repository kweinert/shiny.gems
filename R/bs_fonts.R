#' Bootstrap Font Information
#'
#' This function uses bslib::bs_current_theme() and bslib::bs_get_variables() to query the root level font information. 
#'
#' This function should be called in a reactive context.
#' 
#'
#' @return a named character vector, with names body-bg, body-color, body-emphasis-color, body-secondary-color, body-secondary-bg,
#'	body-tertiary-color, body-tertiary-bg, headings-color, link-color, link-hover-color, 
#'	code-color, highlight-color, highlight-bg, border-color, border-color-translucent, 
#'	form-valid-color, form-valid-border-color, form-invalid-color, form-invalid-border-color
#' @export
bs_fonts <- function() {
	current_theme <- bslib::bs_current_theme()
	font_vars <- c(
		"font-family-sans-serif", "font-family-monospace", "font-family-base", 
		"font-family-code", "font-size-root", "font-size-base", "font-size-sm", 
		"font-size-lg", "font-weight-lighter", "font-weight-light", "font-weight-normal", 
		"font-weight-medium", "font-weight-semibold", "font-weight-bold", 
		"font-weight-bolder", "font-weight-base", "h1-font-size", "h2-font-size", 
		"h3-font-size", "h4-font-size", "h5-font-size", "h6-font-size", 
		"headings-font-family", "headings-font-style", "headings-font-weight", 
		"display-font-family", "display-font-style", "display-font-weight", 
		"lead-font-size", "lead-font-weight", "small-font-size", "sub-sup-font-size", 
		"initialism-font-size", "blockquote-font-size", "blockquote-footer-font-size", 
		"legend-font-size", "legend-font-weight", "dt-font-weight", "table-th-font-weight", 
		"input-btn-font-family", "input-btn-font-size", "input-btn-font-size-sm", 
		"input-btn-font-size-lg", "btn-font-family", "btn-font-size", 
		"btn-font-size-sm", "btn-font-size-lg", "btn-font-weight", "form-text-font-size", 
		"form-text-font-style", "form-text-font-weight", "form-label-font-size", 
		"form-label-font-style", "form-label-font-weight", "input-font-family", 
		"input-font-size", "input-font-weight", "input-font-size-sm", 
		"input-font-size-lg", "form-check-min-height", "input-group-addon-font-weight", 
		"form-select-font-family", "form-select-font-size", "form-select-font-weight", 
		"form-select-font-size-sm", "form-select-font-size-lg", "form-feedback-font-size", 
		"form-feedback-font-style", "nav-link-font-size", "nav-link-font-weight", 
		"navbar-brand-font-size", "nav-link-height", "navbar-brand-height", 
		"navbar-toggler-font-size", "dropdown-font-size", "pagination-font-size", 
		"tooltip-font-size", "form-feedback-tooltip-font-size", "popover-font-size", 
		"popover-header-font-size", "toast-font-size", "badge-font-size", 
		"badge-font-weight", "alert-link-font-weight", "progress-font-size", 
		"figure-caption-font-size", "breadcrumb-font-size", "code-font-size", 
		"kbd-font-size"
	)

	stats::setNames(
		bslib::bs_get_variables(current_theme, varnames=font_vars),
		font_vars
	)
	


}
