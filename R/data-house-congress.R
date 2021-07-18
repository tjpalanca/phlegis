#' @describeIn data House of Representatives - Congress
#' @export
data_house_congress <- function() {

  dataset_open(data_bucket("house/congress"))

}

#' @rdname data
data_house_congress_pipeline <- function() {

  session("https://congress.gov.ph/legisdocs/?v=ra") %>%
    data_house_congress_extract() %>%
    data_house_congress_load()

}

data_house_congress_load <- function(data) {

  data %>%
    dataset_write(data_bucket("house/congress"))

}

data_house_congress_extract <- function(session) {

  session %>%
    html_node("select[name='congress']") %>%
    html_nodes("option") %>% {
      tibble::tibble(
        congress_id = html_text(.),
        form_value  = html_attr(., "value")
      )
    }

}
