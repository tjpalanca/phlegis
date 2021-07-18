#' @title
#' Philippines Legislative Analysis
#'
#' @import glue
#'         tibble
#'         magrittr
#'         logger
#'
#' @importFrom rvest
#'             session session_submit
#'             html_node html_nodes
#'             html_form html_form_set
#'             html_text html_attr
#'             url_absolute
#'
#' @importFrom dplyr
#'             mutate
#'             filter
#'             select
#'             pull
#'             collect
#'             group_by
#'             bind_cols bind_rows
#'
#' @importFrom purrr
#'             map map2 map_dfr
#'             walk walk2
#'
#' @importFrom stringr
#'             str_remove
#'             str_detect
#'
#' @importFrom arrow
#'             S3FileSystem
#'
#' @importFrom checkmate
#'             assert_class
#'             assert_string
#'             assert_choice
#'
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(...) {

  # Set logging colors
  logger::log_layout(logger::layout_glue_colors)

}
