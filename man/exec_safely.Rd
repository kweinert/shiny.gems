% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exec_safely.R
\name{exec_safely}
\alias{exec_safely}
\title{Shiny Version of TryCatch}
\usage{
exec_safely(session, expr)
}
\arguments{
\item{session}{the app session object}

\item{expr}{R expression to evaluate safely}
}
\description{
Use in reactive context, i.e. inside a server function only.
}
