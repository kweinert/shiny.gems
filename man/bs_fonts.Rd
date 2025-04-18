% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bs_fonts.R
\name{bs_fonts}
\alias{bs_fonts}
\title{Bootstrap Font Information}
\usage{
bs_fonts()
}
\value{
a named character vector, with names body-bg, body-color, body-emphasis-color, body-secondary-color, body-secondary-bg,
body-tertiary-color, body-tertiary-bg, headings-color, link-color, link-hover-color, 
code-color, highlight-color, highlight-bg, border-color, border-color-translucent, 
form-valid-color, form-valid-border-color, form-invalid-color, form-invalid-border-color
}
\description{
This function uses bslib::bs_current_theme() and bslib::bs_get_variables() to query the root level font information.
}
\details{
This function should be called in a reactive context.
}
