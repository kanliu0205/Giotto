% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clustering.R
\name{doRandomWalkCluster}
\alias{doRandomWalkCluster}
\title{doRandomWalkCluster}
\usage{
doRandomWalkCluster(gobject, name = "random_walk_clus",
  nn_network_to_use = "sNN", network_name = "sNN.pca",
  walk_steps = 4, walk_clusters = 10, walk_weights = NA,
  return_gobject = TRUE, set_seed = F, seed_number = 1234, ...)
}
\arguments{
\item{gobject}{giotto object}

\item{name}{name for cluster}

\item{nn_network_to_use}{type of NN network to use (kNN vs sNN)}

\item{network_name}{name of NN network to use}

\item{walk_steps}{number of walking steps}

\item{walk_clusters}{number of final clusters}

\item{walk_weights}{cluster column defining the walk weights}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}

\item{set_seed}{set seed}

\item{seed_number}{number for seed}

\item{...}{additional parameters}
}
\value{
giotto object appended with new cluster
}
\description{
Cluster cells using a random walk approach.
}
\details{
See random walk algorithm from the igraph package in R.
}
\examples{
    doRandomWalkCluster(gobject)
}
