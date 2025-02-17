% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spatial_genes.R
\name{calculateSpatialGenes}
\alias{calculateSpatialGenes}
\title{calculateSpatialGenes}
\usage{
calculateSpatialGenes(gobject, expression_values = c("normalized",
  "scaled", "custom"), method = c("kmeans", "gini", "rank"),
  spatial_network_name = "spatial_network", simulations = 10,
  detection_threshold = 0, loess_span = 0.2, pred_difference = 0.01,
  split_gene_groups = 10, show_plot = T, rank_percentage = 10,
  pvalue = 0.01, OddsRatio = 2, min_N = 20, max_N = 5000,
  SVname = "SV", show_genes = T, nr_genes = 20, return_gobject = T)
}
\arguments{
\item{gobject}{giotto object}

\item{expression_values}{expression values to use}

\item{method}{method to calculate spatial genes}

\item{spatial_network_name}{name of spatial network to use (default = 'spatial_network')}

\item{detection_threshold}{detection threshold to consider a gene detected}

\item{loess_span}{loess span for loess regression}

\item{pred_difference}{minimum difference between observed and predicted}

\item{split_gene_groups}{number of groups to split genes in}

\item{show_plot}{show plots}

\item{rank_percentage}{percentage of top cells for binarization}

\item{pvalue}{minimum p-value}

\item{OddsRatio}{minimum odds ratio}

\item{min_N}{minimum number of cells that need to display high expression upon binarization}

\item{max_N}{maximum number of cells that can display high expression upon binarization}

\item{SVname}{name for identified spatial genes (default = 'SV')}

\item{show_genes}{show top genes on plot}

\item{nr_genes}{# of genes to plot if show_genes = TRUE}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}
}
\value{
giotto object spatial genes appended to fDataDT
}
\description{
compute genes that are spatially clustered
}
\details{
Description of how we compute spatial genes.
}
\examples{
    calculateSpatialGenes(gobject)
}
