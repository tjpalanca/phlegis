#' @title
#' Legislative Data
#'
#' @description
#' Access the datasets stored in public DigitalOcean space. `*_load()` functions
#' run the data extraction and load function into the space, for which you will
#' need access keys.
#'
#' @name data
NULL

#' @describeIn data bucket storage
data_bucket <- function(path) {

  storage_bucket("phdwh", "phlegis")$path(path)

}

#' @describeIn data run the whole loading process
data_load <- function() {

  data_house_congress_load()

}
