% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/differential_expression.R
\name{findGiniMarkers_one_vs_all}
\alias{findGiniMarkers_one_vs_all}
\title{findGiniMarkers_one_vs_all}
\usage{
findGiniMarkers_one_vs_all(gobject, expression_values = c("normalized",
  "scaled", "custom"), cluster_column, subset_clusters = NULL,
  min_expr_gini_score = 0.5, min_det_gini_score = 0.5,
  detection_threshold = 0, min_genes = 10, verbose = TRUE)
}
\arguments{
\item{gobject}{giotto object}

\item{expression_values}{gene expression values to use}

\item{cluster_column}{clusters to use}

\item{subset_clusters}{selection of clusters to compare}

\item{min_expr_gini_score}{filter on minimum gini coefficient on expression}

\item{min_det_gini_score}{filter on minimum gini coefficient on detection}

\item{detection_threshold}{detection threshold for gene expression}

\item{min_genes}{minimum genes to keep per cluster, overrides pval and logFC}

\item{verbose}{be verbose}
}
\value{
data.table with marker genes
}
\description{
Identify marker genes for all clusters based on gini detection and expression scores.
}
\details{
Description of parameters.
}
\examples{
    findGiniMarkers_one_vs_all(gobject)
}
