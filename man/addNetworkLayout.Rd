% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NN_network.R
\name{addNetworkLayout}
\alias{addNetworkLayout}
\title{addNetworkLayout}
\usage{
addNetworkLayout(gobject, nn_network_to_use = NULL,
  network_name = NULL, layout_type = c("drl"), options_list = NULL,
  layout_name = "layout", return_gobject = TRUE)
}
\arguments{
\item{gobject}{giotto object}

\item{nn_network_to_use}{kNN or sNN}

\item{network_name}{name of NN network to be used}

\item{layout_type}{layout algorithm to use}

\item{options_list}{list of options for selected layout}

\item{layout_name}{name for layout}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}
}
\value{
giotto object with updated layout for selected NN network
}
\description{
Add a network layout for a select nearest neighbor network
}
\details{
Description of layouts and options.
}
\examples{
    addNetworkLayout(gobject)
}
