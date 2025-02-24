#' @title S4 giotto Class
#' @description Framework of giotto object
#' @keywords giotto, object
#' @slot raw_exprs raw expression counts
#' @slot norm_expr normalized expression counts
#' @slot norm_scaled_expr normalized and scaled expression counts
#' @slot custom_expr custom normalized counts
#' @slot spatial_locs spatial location coordinates for cells
#' @slot cell_metadata metadata for cells
#' @slot gene_metadata metadata for genes
#' @slot cell_ID unique cell IDs
#' @slot gene_ID unique gene IDs
#' @slot spatial_network spatial network in data.table/data.frame format
#' @slot spatial_grid spatial grid in data.table/data.frame format
#' @slot dimension_reduction slot to save dimension reduction coordinates
#' @slot nn_network nearest neighbor network in igraph format
#' @slot parameters slot to save parameters that have been used
#' @slot offset_file offset file used to stitch together image fields
#' @export
giotto <- setClass(
  "giotto",
  slots = c(
    raw_exprs = "ANY",
    norm_expr = "ANY",
    norm_scaled_expr = "ANY",
    custom_expr = "ANY",
    spatial_locs = "ANY",
    cell_metadata = "ANY",
    gene_metadata = "ANY",
    cell_ID = "ANY",
    gene_ID = "ANY",
    spatial_network = "ANY",
    spatial_grid = "ANY",
    dimension_reduction = 'ANY',
    nn_network = "ANY",
    parameters = "ANY",
    offset_file = "ANY"
  ),

  prototype = list(
    raw_exprs = NULL,
    norm_expr = NULL,
    norm_scaled_expr = NULL,
    custom_expr = NULL,
    spatial_locs = NULL,
    cell_metadata = NULL,
    gene_metadata = NULL,
    cell_ID = NULL,
    gene_ID = NULL,
    spatial_network = NULL,
    spatial_grid = NULL,
    dimension_reduction = NULL,
    nn_network = NULL,
    parameters = NULL,
    offset_file = NULL
  ),

  validity = function(object) {

    if(any(lapply(list(object@raw_exprs), is.null) == TRUE)) {
      return('expression and spatial locations slots need to be filled in')
    }

    #if(any(lapply(list(object@raw_exprs, object@spatial_locs), is.null) == TRUE)) {
    #  return('expression and spatial locations slots need to be filled in')
    #}

    #if(ncol(object@raw_exprs) != nrow(object@spatial_locs)) {
    #  return('number of cells do not correspond between expression matrix and spatial locations')
    #}
    return(TRUE)
  }
)



#' @title show method for giotto class
#' @keywords giotto, object
#'
#' @export
setMethod(
  f = "show",
  signature = "giotto",
  definition = function(object) {
    cat(
      "An object of class",
      class(object),
      "\n",
      nrow(x = object@raw_exprs),
      "genes across",
      ncol(x = object@raw_exprs),
      "samples.\n \n"
    )
    cat('Steps and parameters used: \n \n')
    print(object@parameters)
    invisible(x = NULL)
  }
)


#' @title print method for giotto class
#' @description print method for giotto class.
#' Prints the chosen number of genes (rows) and cells (columns) from the raw count matrix.
#' Also print the spatial locations for the chosen number of cells.
#' @param nr_genes number of genes (rows) to print
#' @param nr_cells number of cells (columns) to print
#' @keywords giotto, object
#'
#' @export
setGeneric(name = "print.giotto",
           def = function(object, ...) {
             standardGeneric("print.giotto")
           })

setMethod(f = "print.giotto",
          signature = "giotto",
          definition = function(object, nr_genes = 5, nr_cells = 5) {
            print(object@raw_exprs[1:nr_genes, 1:nr_cells])
            cat('\n')
            print(object@spatial_locs[1:nr_cells,])
          })



#' @title create Giotto object
#' @description Function to create a giotto object
#' @param raw_exprs matrix with raw expression counts [required]
#' @param spatial_locs data.table with coordinates for cell centroids [required]
#' @param norm_expr normalized expression values
#' @param norm_scaled_expr scaled expression values
#' @param custom_expr custom expression values
#' @param cell_metadata cell metadata
#' @param gene_metadata gene metadata
#' @param spatial_network list of spatial network(s)
#' @param spatial_network_name list of spatial network name(s)
#' @param spatial_grid list of spatial grid(s)
#' @param spatial_grid_name list of spatial grid name(s)
#' @param dimension_reduction list of dimension reduction(s)
#' @param nn_network list of nearest neighbor network(s)
#' @param offset_file file used to stitch fields together (optional)
#' @return giotto object
#' @keywords giotto
#' @export
#' @examples
#'     createGiottoObject(raw_exprs, spatial_locs)
createGiottoObject <- function(raw_exprs,
                               spatial_locs = NULL,
                               norm_expr = NULL,
                               norm_scaled_expr = NULL,
                               custom_expr = NULL,
                               cell_metadata = NULL,
                               gene_metadata = NULL,
                               spatial_network = NULL,
                               spatial_network_name = NULL,
                               spatial_grid = NULL,
                               spatial_grid_name = NULL,
                               dimension_reduction = NULL,
                               nn_network = NULL,
                               offset_file = NULL) {

  # create minimum giotto
  gobject = giotto(raw_exprs = raw_exprs,
                   spatial_locs = spatial_locs,
                   norm_expr = NULL,
                   norm_scaled_expr = NULL,
                   custom_expr = NULL,
                   cell_metadata = cell_metadata,
                   gene_metadata = gene_metadata,
                   cell_ID = NULL,
                   gene_ID = NULL,
                   spatial_network = NULL,
                   spatial_grid = NULL,
                   dimension_reduction = NULL,
                   nn_network = NULL,
                   parameters = NULL,
                   offset_file = offset_file)

  # prepare other slots
  gobject@cell_ID = colnames(raw_exprs)
  gobject@gene_ID = rownames(raw_exprs)
  gobject@parameters = list()


  ## if no spatial information is given; create dummy spatial data
  if(is.null(spatial_locs)) {
    cat('\n spatial locations are not given, dummy 3D data will be created \n')
    spatial_locs = data.table::data.table(x = 1:ncol(raw_exprs),
                                          y = 1:ncol(raw_exprs),
                                          z = 1:ncol(raw_exprs))
    gobject@spatial_locs = spatial_locs
  }


  ## spatial
  if(nrow(spatial_locs) != ncol(raw_exprs)) {
    stop('\n Number of rows of spatial location must equal number of columns of expression matrix \n')
  } else {
    spatial_dimensions = c('x', 'y', 'z')
    colnames(gobject@spatial_locs) <- paste0('sdim', spatial_dimensions[1:ncol(gobject@spatial_locs)])
    gobject@spatial_locs = data.table::as.data.table(gobject@spatial_locs)
    gobject@spatial_locs[, cell_ID := colnames(raw_exprs)]
  }


  ## OPTIONAL:
  # add other normalized expression data
  if(!is.null(norm_expr)) {

    if(all(dim(norm_expr) == dim(raw_exprs)) &
       all(colnames(norm_expr) == colnames(raw_exprs)) &
       all(rownames(norm_expr) == rownames(raw_exprs))) {

      gobject@norm_expr = norm_expr
    } else {
      stop('\n dimensions, row or column names are not the same between normalized and raw expression \n')
    }
  }

  # add other normalized and scaled expression data
  if(!is.null(norm_scaled_expr)) {

    if(all(dim(norm_scaled_expr) == dim(raw_exprs)) &
       all(colnames(norm_scaled_expr) == colnames(raw_exprs)) &
       all(rownames(norm_scaled_expr) == rownames(raw_exprs))) {

      gobject@norm_scaled_expr = norm_scaled_expr
    } else {
      stop('\n dimensions, row or column names are not the same between normalized + scaled and raw expression \n')
    }
  }

  # add other custom normalized expression data
  if(!is.null(custom_expr)) {

    if(all(dim(custom_expr) == dim(raw_exprs)) &
       all(colnames(custom_expr) == colnames(raw_exprs)) &
       all(rownames(custom_expr) == rownames(raw_exprs))) {

      gobject@custom_expr = custom_expr
    } else {
      stop('\n dimensions, row or column names are not the same between custom normalized and raw expression \n')
    }
  }

  # cell metadata
  if(is.null(cell_metadata)) {
    gobject@cell_metadata = data.table::data.table(cell_ID = colnames(raw_exprs))
  } else {
    gobject@cell_metadata = data.table::as.data.table(gobject@cell_metadata)
    gobject@cell_metadata[, cell_ID := colnames(raw_exprs)]
  }

  # gene metadata
  if(is.null(gene_metadata)) {
    gobject@gene_metadata = data.table::data.table(gene_ID = rownames(raw_exprs))
  } else {
    gobject@gene_metadata = data.table::as.data.table(gobject@gene_metadata)
    gobject@gene_metadata[, gene_ID := rownames(raw_exprs)]
  }


  ### OPTIONAL:
  ## spatial network
  if(!is.null(spatial_network)) {
    if(is.null(spatial_network_name) | length(spatial_network) != length(spatial_network_name)) {
      stop('\n each spatial network must be given a unique name \n')
    } else {

      for(network_i in 1:length(spatial_network)) {

        networkname = spatial_network_name[[network_i]]
        network     = spatial_network[[network_i]]

        if(any(c('data.frame', 'data.table') %in% class(network))) {
          if(all(c('to', 'from', 'weight', 'sdimx_begin', 'sdimy_begin', 'sdimx_end', 'sdimy_end') %in% colnames(network))) {
            gobject@spatial_network[[networkname]] = network
          } else {
            stop('\n network ', networkname, ' does not have all necessary column names, see details \n')
          }
        } else {
          stop('\n network ', networkname, ' is not a data.frame or data.table \n')
        }
      }
    }
  }


  ## spatial grid
  if(!is.null(spatial_grid)) {
    if(is.null(spatial_grid_name) | length(spatial_grid) != length(spatial_grid_name)) {
      stop('\n each spatial grid must be given a unique name \n')
    } else {

      for(grid_i in 1:length(spatial_grid)) {

        gridname = spatial_grid_name[[grid_i]]
        grid     = spatial_grid[[grid_i]]

        if(any(c('data.frame', 'data.table') %in% class(grid))) {
          if(all(c('x_start', 'y_start', 'x_end', 'y_end', 'gr_name') %in% colnames(grid))) {
            gobject@spatial_grid[[gridname]] = grid
          } else {
            stop('\n grid ', gridname, ' does not have all necessary column names, see details \n')
          }
        } else {
          stop('\n grid ', gridname, ' is not a data.frame or data.table \n')
        }
      }
    }
  }

  # dimension reduction
  if(!is.null(dimension_reduction)) {

    for(dim_i in 1:length(dimension_reduction)) {

      dim_red = dimension_reduction[[dim_i]]

      if(all(c('type', 'name', 'reduction_method', 'coordinates', 'misc') %in% names(dim_red))) {

        coord_data = dim_red[['coordinates']]

        if(all(rownames(coord_data) %in% gobject@cell_ID)) {

          type_value = dim_red[['type']] # cells or genes
          reduction_meth_value = dim_red[['reduction_method']] # e.g. umap, tsne, ...
          name_value = dim_red[['name']]  # uniq name
          misc_value = dim_red[['misc']]  # additional data

          gobject@dimension_reduction[[type_value]][[reduction_meth_value]][[name_value]] = dim_red[c('name', 'reduction_method', 'coordinates', 'misc')]
        } else {
          stop('\n rownames for coordinates are not found in gobject IDs \n')
        }

      } else {
        stop('\n each dimension reduction list must contain all required slots, see details. \n')
      }

    }

  }

  # NN network
  if(!is.null(nn_network)) {

    for(nn_i in 1:length(nn_network)) {

      nn_netw = nn_network[[nn_i]]

      if(all(c('type', 'name', 'igraph') %in% names(nn_netw))) {

        igraph_data = nn_netw[['igraph']]

        if(all(names(V(igraph_data)) %in% gobject@cell_ID)) {

          type_value = nn_netw[['type']] # sNN or kNN
          name_value = nn_netw[['name']]  # uniq name

          gobject@nn_network[[type_value]][[name_value]][['igraph']] = igraph_data
        } else {
          stop('\n igraph vertex names are not found in gobject IDs \n')
        }

      } else {
        stop('\n each nn network list must contain all required slots, see details. \n')
      }

    }

  }

  # other information
  # TODO

  return(gobject)

}






