#' @describeIn data Senate - Congress
#' @export
data_senate_congress <- function() {

  dataset_open(data_bucket("senate/congress"))

}

#' @rdname data
data_senate_congress_pipeline <- function() {

  scrape_session("http://legacy.senate.gov.ph/lis/leg_sys.aspx") %>%
    data_senate_congress_extract() %>%
    data_senate_congress_load()

}

data_senate_congress_extract <- function(session) {

  session %>%
    html_node("#div_ChangeCongress") %>%
    html_nodes("li") %>% {
      tibble::tibble(
        congress_link = html_node(., "a") %>%
          html_attr("href") %>%
          url_absolute("http://legacy.senate.gov.ph/lis/"),
        congress_text = html_text(.)
      ) %>%
        mutate(
          congress_id = congress_link %>%
            stringr::str_extract("congress=[0-9]+") %>%
            str_remove("congress=")
        )
    }

}

data_senate_congress_load <- function(data) {

  data %>%
    dataset_write(data_bucket("senate/congress"))

}
