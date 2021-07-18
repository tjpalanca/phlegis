#' @title
#' Legislative Data
#'
#' @description
#' Access the datasets stored in public DigitalOcean space.
#'
#' The load process for these datasets is run by using the `*_pipeline()`
#' functions. You will need the right access keys to be able to write to the
#' buckets.
#'
#' @name data
NULL

#' @describeIn data bucket storage
data_bucket <- function(path) {

  storage_bucket("phdwh", "phlegis")$path(path)

}

#' @describeIn data run the whole data pipeline
data_pipeline <- function() {

  data_house_congress_pipeline()

}
