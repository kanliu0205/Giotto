% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auxiliary_giotto.R
\name{addGeneStatistics}
\alias{addGeneStatistics}
\title{addGeneStatistics}
\usage{
addGeneStatistics(gobject, expression_values = c("normalized", "scaled",
  "custom"), detection_threshold = 0, return_gobject = TRUE)
}
\arguments{
\item{gobject}{giotto object}

\item{expression_values}{expression values to use}

\item{detection_threshold}{detection threshold to consider a gene detected}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}
}
\value{
giotto object if return_gobject = TRUE
}
\description{
adds gene statistics to the giotto object
}
\details{
Details about gene statistics that are returned.
}
\examples{
    addGeneStatistics(gobject)
}
