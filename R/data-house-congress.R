#' @describeIn data House of Representatives - Congress
#' @export
data_house_congress <- function() {

  dataset_open(data_house_congress_bucket())

}

#' @rdname data
data_house_congress_load <- function() {

  session("https://congress.gov.ph/legisdocs/?v=ra") %>%
    html_node("select[name='congress']") %>%
    html_nodes("option") %>%
    map_dfr(~tibble::tibble(
      congress_id = html_text(.),
      form_value  = html_attr(., "value")
    )) %>%
    dataset_write(data_house_congress_bucket())

}

data_house_congress_bucket <- function() {
  data_bucket("congress")
}
