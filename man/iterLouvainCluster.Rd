% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clustering.R
\name{iterLouvainCluster}
\alias{iterLouvainCluster}
\title{iterLouvainCluster}
\usage{
iterLouvainCluster(gobject, version = c("community", "multinet"),
  nr_rounds = 5, hvg_param = list(reverse_log_scale = T,
  difference_in_variance = 1, expression_values = "normalized"),
  hvg_min_perc_cells = 5, hvg_mean_expr_det = 1,
  use_all_genes_as_hvg = FALSE, min_nr_of_hvg = 5,
  pca_param = list(expression_values = "normalized", scale_unit = T),
  nn_param = list(dimensions_to_use = 1:20), k_neighbors = 20,
  resolution = 1, gamma = 1, omega = 1, python_path = NULL,
  nn_network_to_use = "sNN", network_name = "sNN.pca",
  name = "iter_clus", return_gobject = TRUE, ...)
}
\arguments{
\item{gobject}{giotto object}

\item{version}{louvain clustering algorithm to use}

\item{nr_rounds}{number of iterative rounds}

\item{hvg_param}{parameters for calculateHVG}

\item{hvg_min_perc_cells}{threshold for detection in min percentage of cells}

\item{hvg_mean_expr_det}{threshold for mean expression level in cells with detection}

\item{use_all_genes_as_hvg}{forces all genes to be HVG and to be used as input for PCA}

\item{min_nr_of_hvg}{minimum number of HVG, or all genes will be used as input for PCA}

\item{pca_param}{parameters for runPCA}

\item{nn_param}{parameters for parameters for runPCA}

\item{k_neighbors}{k for nn-network}

\item{resolution}{resolution}

\item{gamma}{gamma}

\item{omega}{omega}

\item{python_path}{python path to use for Leiden clustering}

\item{nn_network_to_use}{NN network to use}

\item{network_name}{NN network name}

\item{name}{name of clustering}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}

\item{...}{additional parameters}
}
\value{
giotto object appended with new cluster
}
\description{
cluster cells iteratively
}
\details{
Description of iterative clustering.
}
\examples{
    iterLouvainCluster(gobject)
}
