

#' @title createSpatialNetwork
#' @description Create a spatial network based on cell centroid distances.
#' @param gobject giotto object
#' @param k number of nearest neighbors based on physical distance
#' @param dimensions which spatial dimensions to use (default = all)
#' @param maximum_distance distance cuttof for nearest neighbors to consider
#' @param minimum_k minimum nearest neigbhours if maximum_distance != NULL
#' @param name name for spatial network (default = 'spatial_network')
#' @param verbose verbose
#' @param return_gobject boolean: return giotto object (default = TRUE)
#' @return giotto object with updated spatial network slot
#' @details Creates a spatial network connecting single-cells based on their physical distance to each other.
#' Number of neighbors can be determined by k, maximum distance from each cell with or without
#' setting a minimum k for each cell.
#' @export
#' @examples
#'     createSpatialNetwork(gobject)
createSpatialNetwork <- function(gobject,
                                 k = 4,
                                 dimensions = 'all',
                                 maximum_distance = NULL,
                                 minimum_k = 0,
                                 name = 'spatial_network',
                                 verbose = F,
                                 return_gobject = TRUE) {


  # spatial information
  spatial_locations = gobject@spatial_locs
  spatial_locations = spatial_locations[, grepl('sdim', colnames(spatial_locations)), with = F]
  if(dimensions != 'all') {
    spatial_locations = spatial_locations[, dimensions]
  }
  spatial_locations <- as.matrix(spatial_locations)
  rownames(spatial_locations) <- gobject@cell_ID


  # vector matching cell_ID and order
  cell_ID_vec <- c(1:nrow(spatial_locations))
  names(cell_ID_vec) <- rownames(spatial_locations)


  # knn network
  knn_spatial <- dbscan::kNN(x = spatial_locations, k = k)
  knn_sptial.norm = data.frame(from = rep(1:nrow(knn_spatial$id), k),
                               to = as.vector(knn_spatial$id),
                               weight = 1/(1 + as.vector(knn_spatial$dist)),
                               distance = as.vector(knn_spatial$dist))
  nw_sptial.norm = igraph::graph_from_data_frame(knn_sptial.norm, directed = FALSE)

  # create network for coordinates #
  spatial_network_DT <- data.table::as.data.table(knn_sptial.norm)

  spatial_network_DT[, from := names(cell_ID_vec[from])]
  spatial_network_DT[, to := names(cell_ID_vec[to])]
  spatial_network_DT[, rank_int := rank(distance), by = from]

  if(!is.null(maximum_distance)) {
    spatial_network_DT = spatial_network_DT[distance <= maximum_distance | rank_int <= minimum_k]
  }

  # add to cell metadata
  cel_metadata = gobject@cell_metadata

  spatial_locs_DT = gobject@spatial_locs
  spatial_locations_annot <- spatial_locs_DT[, cell_ID := gobject@cell_ID]

  spatial_network_DT <- merge(spatial_network_DT, by.x = 'from', spatial_locations_annot, by.y = 'cell_ID')
  coord_names = colnames(spatial_locations)
  coord_begin = paste0(coord_names, '_begin')
  setnames(spatial_network_DT, coord_names, coord_begin)

  spatial_network_DT <- merge(spatial_network_DT, by.x = 'to', spatial_locations_annot, by.y = 'cell_ID')
  coord_names = colnames(spatial_locations)
  coord_end = paste0(coord_names, '_end')
  setnames(spatial_network_DT, coord_names, coord_end)


  if(return_gobject == TRUE) {

    spn_names = names(gobject@spatial_network[[name]])

    if(name %in% spn_names) {
      cat('\n ', name, ' has already been used, will be overwritten \n')

    }

    ## update parameters used ##
    parameters_list = gobject@parameters
    number_of_rounds = length(parameters_list)
    update_name = paste0(number_of_rounds,'_spatial_network')

    # parameters to include
    parameters_list[[update_name]] = c('k neighbours' = k,
                                       'dimensions used' = dimensions,
                                       'maximum distance threshold' = ifelse(is.null(maximum_distance), NA, maximum_distance),
                                       'name of spatial network' = name)
    gobject@parameters = parameters_list

    gobject@spatial_network[[name]] = spatial_network_DT


    return(gobject)

  } else {
    return(spatial_network_DT)
  }
}




#' @title find_grid_3D
#' @name find_grid_3D
#' @description find grid location in 3D
find_grid_3D <- function(grid_DT, x_loc, y_loc, z_loc) {

  name = grid_DT[x_loc > x_start & x_loc < x_end & y_loc > y_start & y_loc < y_end & z_loc > z_start & z_loc < z_end]$gr_name
  return(name)
}

#' @title find_grid_2D
#' @name find_grid_2D
#' @description find grid location in 2D
find_grid_2D <- function(grid_DT, x_loc, y_loc) {

  name = grid_DT[x_loc > x_start & x_loc < x_end & y_loc > y_start & y_loc < y_end]$gr_name
  return(name)
}

#' @title find_grid_x
#' @name find_grid_x
#' @description find grid location on x-axis
find_grid_x <- function(grid_DT, x_loc) {

  grid_DT_x = unique(grid_DT[,.(x_start, x_end, gr_x_name)])
  name_x = grid_DT_x[x_loc > x_start & x_loc < x_end]$gr_x_name
  return(name_x)
}

#' @title find_grid_y
#' @name find_grid_y
#' @description find grid location on y-axis
find_grid_y <- function(grid_DT, y_loc) {

  grid_DT_y = unique(grid_DT[,.(y_start, y_end, gr_y_name)])
  name_y = grid_DT_y[y_loc > y_start & y_loc < y_end]$gr_y_name
  return(name_y)
}

#' @title find_grid_z
#' @name find_grid_z
#' @description find grid location on z-axis
find_grid_z <- function(grid_DT, z_loc) {

  grid_DT_z = unique(grid_DT[,.(z_start, z_end, gr_z_name)])
  name_z = grid_DT_z[z_loc > z_start & z_loc < z_end]$gr_z_name
  return(name_z)
}




#' @title createSpatialGrid_3D
#' @description create a spatial grid
#' @param gobject giotto object
#' @param sdimx_stepsize stepsize along the x-axis
#' @param sdimy_stepsize stepsize along the y-axis
#' @param sdimz_stepsize stepsize along the z-axis
#' @param minimum_padding minimum padding on the edges
#' @param name name for spatial grid (default = 'spatial_grid')
#' @param return_gobject boolean: return giotto object (default = TRUE)
#' @return giotto object with updated spatial grid slot
#' @details Creates a spatial grid with defined x, y (and z) dimensions.
#' @export
#' @examples
#'     createSpatialGrid_3D(gobject)
createSpatialGrid_3D <- function(gobject,
                                 sdimx_stepsize = NULL,
                                 sdimy_stepsize = NULL,
                                 sdimz_stepsize = NULL,
                                 minimum_padding = 1,
                                 name = 'spatial_grid',
                                 return_gobject = TRUE) {


  spatlocs = copy(gobject@spatial_locs)
  if(is.null(spatlocs)) stop('\n spatial locations are needed to create a spatial grid \n')

  ## calculate sequences for desired stepsize
  # x-axis
  x_range = range(spatlocs$sdimx)
  x_start = x_range[[1]] - minimum_padding
  x_end = x_range[[2]] + minimum_padding
  dimx_steps = ceiling( (x_end-x_start) / sdimx_stepsize)
  dimx_start = mean(c(x_start, x_end))-((dimx_steps/2)*sdimx_stepsize)
  dimx_end = mean(c(x_start, x_end))+((dimx_steps/2)*sdimx_stepsize)
  my_x_seq = seq(from = dimx_start, to = dimx_end, by = sdimx_stepsize)

  # y-axis
  y_range = range(spatlocs$sdimy)
  y_start = y_range[[1]] - minimum_padding
  y_end = y_range[[2]] + minimum_padding
  dimy_steps = ceiling( (y_end-y_start) / sdimy_stepsize)
  dimy_start = mean(c(y_start, y_end))-((dimy_steps/2)*sdimy_stepsize)
  dimy_end = mean(c(y_start, y_end))+((dimy_steps/2)*sdimy_stepsize)
  my_y_seq = seq(from = dimy_start, to = dimy_end, by = sdimy_stepsize)

  # z-axis
  z_range = range(spatlocs$sdimz)
  z_start = z_range[[1]] - minimum_padding
  z_end = z_range[[2]] + minimum_padding
  dimz_steps = ceiling( (z_end-z_start) / sdimz_stepsize)
  dimz_start = mean(c(z_start, z_end))-((dimz_steps/2)*sdimz_stepsize)
  dimz_end = mean(c(z_start, z_end))+((dimz_steps/2)*sdimz_stepsize)
  my_z_seq = seq(from = dimz_start, to = dimz_end, by = sdimz_stepsize)

  ## create grid with starts and ends
  grid_starts = as.data.table(expand.grid(my_x_seq[-length(my_x_seq)],
                                          my_y_seq[-length(my_y_seq)],
                                          my_z_seq[-length(my_z_seq)]))
  colnames(grid_starts) = c('x_start', 'y_start', 'z_start')
  grid_ends = as.data.table(expand.grid(my_x_seq[-1],
                                        my_y_seq[-1],
                                        my_z_seq[-1]))
  colnames(grid_ends) = c('x_end', 'y_end', 'z_end')
  spatgrid = cbind(grid_starts, grid_ends)


  ## first label the grid itself ##
  spatgrid[, gr_name := paste0('gr_', 1:.N)]

  # x-axis
  x_labels = sort(unique(spatgrid$x_start))
  x_gr_names = paste0('gr_x_', 1:length(x_labels))
  names(x_gr_names) = x_labels
  x_gr_names_vector = x_gr_names[as.character(spatgrid$x_start)]
  spatgrid[, gr_x_name := x_gr_names_vector]

  # y-axis
  y_labels = sort(unique(spatgrid$y_start))
  y_gr_names = paste0('gr_y_', 1:length(y_labels))
  names(y_gr_names) = y_labels
  y_gr_names_vector = y_gr_names[as.character(spatgrid$y_start)]
  spatgrid[, gr_y_name := y_gr_names_vector]

  # z-axis
  z_labels = sort(unique(spatgrid$z_start))
  z_gr_names = paste0('gr_z_', 1:length(z_labels))
  names(z_gr_names) = z_labels
  z_gr_names_vector = z_gr_names[as.character(spatgrid$z_start)]
  spatgrid[, gr_z_name := z_gr_names_vector]




  ## second label the spatial locations ##
  spatlocs = copy(gobject@spatial_locs)

  x_vector = spatlocs$sdimx
  x_breaks = sort(unique(spatgrid$x_end))
  x_breaks_labels = paste0('gr_x_', 1:length(x_breaks))
  minimum_x = min(x_breaks) - sdimx_stepsize
  my_x_gr = cut(x = x_vector, breaks = c(minimum_x, x_breaks), include.lowest = T, right = T, labels = x_breaks_labels)
  spatlocs[, gr_x_loc := as.character(my_x_gr)]

  y_vector = spatlocs$sdimy
  y_breaks = sort(unique(spatgrid$y_end))
  y_breaks_labels = paste0('gr_y_', 1:length(y_breaks))
  minimum_y = min(y_breaks) - sdimy_stepsize
  my_y_gr = cut(x = y_vector, breaks = c(minimum_y, y_breaks), include.lowest = T, right = T, labels = y_breaks_labels)
  spatlocs[, gr_y_loc := as.character(my_y_gr)]

  z_vector = spatlocs$sdimz
  z_breaks = sort(unique(spatgrid$z_end))
  z_breaks_labels = paste0('gr_z_', 1:length(z_breaks))
  minimum_z = min(z_breaks) - sdimz_stepsize
  my_z_gr = cut(x = z_vector, breaks = c(minimum_z, z_breaks), include.lowest = T, right = T, labels = z_breaks_labels)
  spatlocs[, gr_z_loc := as.character(my_z_gr)]


  ## for all dimensions ##
  # converter
  gr_dim_names = spatgrid$gr_name
  names(gr_dim_names) = paste0(spatgrid$gr_x_name,'-', spatgrid$gr_y_name, '-', spatgrid$gr_z_name)

  indiv_dim_names = paste0(spatlocs$gr_x_loc,'-', spatlocs$gr_y_loc, '-', spatlocs$gr_z_loc)
  my_gr = gr_dim_names[indiv_dim_names]
  spatlocs[, gr_loc := as.character(my_gr)]



  if(return_gobject == TRUE) {

    spg_names = names(gobject@spatial_grid)

    if(name %in% spg_names) {
      cat('\n ', name, ' has already been used, will be overwritten \n')
    }

    # assign spatial grid
    gobject@spatial_grid[[name]] <- spatgrid

    # assign spatial locations back to object
    # gobject@spatial_locs = spatlocs


    ## update parameters used ##
    parameters_list = gobject@parameters
    number_of_rounds = length(parameters_list)
    update_name = paste0(number_of_rounds,'_grid')
    # parameters to include
    parameters_list[[update_name]] = c('x stepsize' = sdimx_stepsize,
                                       'y stepsize' = sdimy_stepsize,
                                       'z stepsize' = sdimz_stepsize,
                                       'minimum padding' = minimum_padding,
                                       'name' = name)
    gobject@parameters = parameters_list

    return(gobject)

  } else {

    return(list(grid = spatgrid, locs = spatlocs))
  }
}

#' @title createSpatialGrid_2D
#' @description create a spatial grid
#' @param gobject giotto object
#' @param sdimx_stepsize stepsize along the x-axis
#' @param sdimy_stepsize stepsize along the y-axis
#' @param minimum_padding minimum padding on the edges
#' @param name name for spatial grid (default = 'spatial_grid')
#' @param return_gobject boolean: return giotto object (default = TRUE)
#' @return giotto object with updated spatial grid slot
#' @details Creates a spatial grid with defined x, y (and z) dimensions.
#' @export
#' @examples
#'     createSpatialGrid_2D(gobject)
createSpatialGrid_2D <- function(gobject,
                                 sdimx_stepsize = NULL,
                                 sdimy_stepsize = NULL,
                                 minimum_padding = 1,
                                 name = 'spatial_grid',
                                 return_gobject = TRUE) {


  spatlocs = copy(gobject@spatial_locs)
  if(is.null(spatlocs)) stop('\n spatial locations are needed to create a spatial grid \n')

  ## calculate sequences for desired stepsize
  # x-axis
  x_range = range(spatlocs$sdimx)
  x_start = x_range[[1]] - minimum_padding
  x_end = x_range[[2]] + minimum_padding
  dimx_steps = ceiling( (x_end-x_start) / sdimx_stepsize)
  dimx_start = mean(c(x_start, x_end))-((dimx_steps/2)*sdimx_stepsize)
  dimx_end = mean(c(x_start, x_end))+((dimx_steps/2)*sdimx_stepsize)
  my_x_seq = seq(from = dimx_start, to = dimx_end, by = sdimx_stepsize)

  # y-axis
  y_range = range(spatlocs$sdimy)
  y_start = y_range[[1]] - minimum_padding
  y_end = y_range[[2]] + minimum_padding
  dimy_steps = ceiling( (y_end-y_start) / sdimy_stepsize)
  dimy_start = mean(c(y_start, y_end))-((dimy_steps/2)*sdimy_stepsize)
  dimy_end = mean(c(y_start, y_end))+((dimy_steps/2)*sdimy_stepsize)
  my_y_seq = seq(from = dimy_start, to = dimy_end, by = sdimy_stepsize)


  ## create grid with starts and ends
  grid_starts = as.data.table(expand.grid(my_x_seq[-length(my_x_seq)],
                                          my_y_seq[-length(my_y_seq)]))
  colnames(grid_starts) = c('x_start', 'y_start')
  grid_ends = as.data.table(expand.grid(my_x_seq[-1],
                                        my_y_seq[-1]))
  colnames(grid_ends) = c('x_end', 'y_end')
  spatgrid = cbind(grid_starts, grid_ends)


  ## first label the grid itself ##
  spatgrid[, gr_name := paste0('gr_', 1:.N)]

  # x-axis
  x_labels = sort(unique(spatgrid$x_start))
  x_gr_names = paste0('gr_x_', 1:length(x_labels))
  names(x_gr_names) = x_labels
  x_gr_names_vector = x_gr_names[as.character(spatgrid$x_start)]
  spatgrid[, gr_x_name := x_gr_names_vector]

  # y-axis
  y_labels = sort(unique(spatgrid$y_start))
  y_gr_names = paste0('gr_y_', 1:length(y_labels))
  names(y_gr_names) = y_labels
  y_gr_names_vector = y_gr_names[as.character(spatgrid$y_start)]
  spatgrid[, gr_y_name := y_gr_names_vector]


  ## second label the spatial locations ##
  spatlocs = copy(gobject@spatial_locs)

  x_vector = spatlocs$sdimx
  x_breaks = sort(unique(spatgrid$x_end))
  x_breaks_labels = paste0('gr_x_', 1:length(x_breaks))
  minimum_x = min(x_breaks) - sdimx_stepsize
  my_x_gr = cut(x = x_vector, breaks = c(minimum_x, x_breaks), include.lowest = T, right = T, labels = x_breaks_labels)
  spatlocs[, gr_x_loc := as.character(my_x_gr)]

  y_vector = spatlocs$sdimy
  y_breaks = sort(unique(spatgrid$y_end))
  y_breaks_labels = paste0('gr_y_', 1:length(y_breaks))
  minimum_y = min(y_breaks) - sdimy_stepsize
  my_y_gr = cut(x = y_vector, breaks = c(minimum_y, y_breaks), include.lowest = T, right = T, labels = y_breaks_labels)
  spatlocs[, gr_y_loc := as.character(my_y_gr)]



  ## for all dimensions ##
  # converter
  gr_dim_names = spatgrid$gr_name
  names(gr_dim_names) = paste0(spatgrid$gr_x_name,'-', spatgrid$gr_y_name)

  indiv_dim_names = paste0(spatlocs$gr_x_loc,'-', spatlocs$gr_y_loc)
  my_gr = gr_dim_names[indiv_dim_names]
  spatlocs[, gr_loc := as.character(my_gr)]



  if(return_gobject == TRUE) {

    spg_names = names(gobject@spatial_grid)

    if(name %in% spg_names) {
      cat('\n ', name, ' has already been used, will be overwritten \n')
    }

    # assign spatial grid
    gobject@spatial_grid[[name]] <- spatgrid

    # assign spatial locations back to object
    # gobject@spatial_locs = spatlocs

    ## update parameters used ##
    parameters_list = gobject@parameters
    number_of_rounds = length(parameters_list)
    update_name = paste0(number_of_rounds,'_grid')
    # parameters to include
    parameters_list[[update_name]] = c('x stepsize' = sdimx_stepsize,
                                       'y stepsize' = sdimy_stepsize,
                                       'minimum padding' = minimum_padding,
                                       'name' = name)
    gobject@parameters = parameters_list

    return(gobject)

  } else {

    return(list(grid = spatgrid, locs = spatlocs))
  }
}


#' @title createSpatialGrid2
#' @description create a spatial grid
#' @param gobject giotto object
#' @param sdimx_stepsize stepsize along the x-axis
#' @param sdimy_stepsize stepsize along the y-axis
#' @param sdimz_stepsize stepsize along the z-axis
#' @param minimum_padding minimum padding on the edges
#' @param name name for spatial grid (default = 'spatial_grid')
#' @param return_gobject boolean: return giotto object (default = TRUE)
#' @return giotto object with updated spatial grid slot
#' @details Creates a spatial grid with defined x, y (and z) dimensions.
#' @export
#' @examples
#'     createSpatialGrid2(gobject)
createSpatialGrid <- function(gobject,
                              sdimx_stepsize = NULL,
                              sdimy_stepsize = NULL,
                              sdimz_stepsize = NULL,
                              minimum_padding = 1,
                              name = 'spatial_grid',
                              return_gobject = TRUE) {


  if(length(c(sdimx_stepsize, sdimy_stepsize, sdimz_stepsize)) == 3) {

    result = createSpatialGrid_3D(gobject = gobject,
                                  sdimx_stepsize = sdimx_stepsize,
                                  sdimy_stepsize = sdimy_stepsize,
                                  sdimz_stepsize = sdimz_stepsize,
                                  minimum_padding = minimum_padding,
                                  name = name,
                                  return_gobject = return_gobject)

  } else if(!is.null(sdimx_stepsize) & !is.null(sdimy_stepsize)) {

    result = createSpatialGrid_2D(gobject = gobject,
                                  sdimx_stepsize = sdimx_stepsize,
                                  sdimy_stepsize = sdimy_stepsize,
                                  minimum_padding = minimum_padding,
                                  name = name,
                                  return_gobject = return_gobject)

  } else {
    cat('\n the stepsize for the x-axis (sdimx) and y-axis (sdimy) is the minimally required \n')
    cat('\n Additionally for a 3D spatial grid the z-axis (sdimz) is also required \n')
  }
  return(result)
}



#' @title annotate_spatlocs_with_spatgrid_3D
#' @description annotate spatial locations with 3D spatial grid information
#' @param spatloc spatial_locs slot from giotto object
#' @param spatgrid selected spatial_grid slot from giotto object
#' @return annotated spatial location data.table
#' @examples
#'     annotate_spatlocs_with_spatgrid_3D()
annotate_spatlocs_with_spatgrid_3D = function(spatloc, spatgrid) {

  ## second label the spatial locations ##
  spatlocs = copy(spatloc)

  x_vector = spatlocs$sdimx
  x_breaks = sort(unique(spatgrid$x_end))
  x_breaks_labels = paste0('gr_x_', 1:length(x_breaks))
  minimum_x = min(spatgrid$x_start)
  my_x_gr = cut(x = x_vector, breaks = c(minimum_x, x_breaks), include.lowest = T, right = T, labels = x_breaks_labels)
  spatlocs[, gr_x_loc := as.character(my_x_gr)]

  y_vector = spatlocs$sdimy
  y_breaks = sort(unique(spatgrid$y_end))
  y_breaks_labels = paste0('gr_y_', 1:length(y_breaks))
  minimum_y = min(spatgrid$y_start)
  my_y_gr = cut(x = y_vector, breaks = c(minimum_y, y_breaks), include.lowest = T, right = T, labels = y_breaks_labels)
  spatlocs[, gr_y_loc := as.character(my_y_gr)]

  z_vector = spatlocs$sdimz
  z_breaks = sort(unique(spatgrid$z_end))
  z_breaks_labels = paste0('gr_z_', 1:length(z_breaks))
  minimum_z = min(spatgrid$z_start)
  my_z_gr = cut(x = z_vector, breaks = c(minimum_z, z_breaks), include.lowest = T, right = T, labels = z_breaks_labels)
  spatlocs[, gr_z_loc := as.character(my_z_gr)]


  ## for all dimensions ##
  # converter
  gr_dim_names = spatgrid$gr_name
  names(gr_dim_names) = paste0(spatgrid$gr_x_name,'-', spatgrid$gr_y_name, '-', spatgrid$gr_z_name)

  indiv_dim_names = paste0(spatlocs$gr_x_loc,'-', spatlocs$gr_y_loc, '-', spatlocs$gr_z_loc)
  my_gr = gr_dim_names[indiv_dim_names]
  spatlocs[, gr_loc := as.character(my_gr)]

  return(spatlocs)

}

#' @title annotate_spatlocs_with_spatgrid_2D
#' @description annotate spatial locations with 2D spatial grid information
#' @param spatloc spatial_locs slot from giotto object
#' @param spatgrid selected spatial_grid slot from giotto object
#' @return annotated spatial location data.table
#' @examples
#'     annotate_spatlocs_with_spatgrid_2D()
annotate_spatlocs_with_spatgrid_2D = function(spatloc, spatgrid) {

  ## second label the spatial locations ##
  spatlocs = copy(spatloc)

  x_vector = spatlocs$sdimx
  x_breaks = sort(unique(spatgrid$x_end))
  x_breaks_labels = paste0('gr_x_', 1:length(x_breaks))
  minimum_x = min(spatgrid$x_start)
  my_x_gr = cut(x = x_vector, breaks = c(minimum_x, x_breaks), include.lowest = T, right = T, labels = x_breaks_labels)
  spatlocs[, gr_x_loc := as.character(my_x_gr)]

  y_vector = spatlocs$sdimy
  y_breaks = sort(unique(spatgrid$y_end))
  y_breaks_labels = paste0('gr_y_', 1:length(y_breaks))
  minimum_y = min(spatgrid$y_start)
  my_y_gr = cut(x = y_vector, breaks = c(minimum_y, y_breaks), include.lowest = T, right = T, labels = y_breaks_labels)
  spatlocs[, gr_y_loc := as.character(my_y_gr)]


  ## for all dimensions ##
  # converter
  gr_dim_names = spatgrid$gr_name
  names(gr_dim_names) = paste0(spatgrid$gr_x_name,'-', spatgrid$gr_y_name)

  indiv_dim_names = paste0(spatlocs$gr_x_loc,'-', spatlocs$gr_y_loc)
  my_gr = gr_dim_names[indiv_dim_names]
  spatlocs[, gr_loc := as.character(my_gr)]

  return(spatlocs)

}

