#' @describeIn data Senate - Republic Acts
data_senate_republic_act <- function() {

  dataset_open(data_bucket("senate/republic_act"))

}

#' @rdname data
data_senate_republic_act_pipeline <- function(...) {

  session <-
    scrape_session(
      "http://legacy.senate.gov.ph/lis/pdf_sys.aspx?type=republic_act"
    )

  session %>%
    data_senate_congress_extract() %>%
    filter(...) %>% {
      walk2(
        .$congress_link, .$congress_id,
        function(congress_link, congress_id) {
          congress_link %>%
            data_senate_republic_act_extract(congress_id) %>%
            data_senate_republic_act_load(congress_id)
        }
      )
    }

  data_senate_republic_act()

}

data_senate_republic_act_extract <- function(congress_link,
                                             congress_id,
                                             page_limit = Inf) {

  log_info("Extracting republic acts for {congress_id} congress")

  congress_data <- tibble()
  congress_stop <- FALSE
  page_index <- 1L

  while (!congress_stop) {

    page_link <- glue("{congress_link}&p={page_index}")
    session <- scrape_session(page_link)

    log_trace("Extracting data from {page_link}")

    next_page_exists <- data_senate_next_page_exists(session, page_index)

    if (next_page_exists & page_index <= page_limit) {
      log_trace("Next page exists")
      page_index <- page_index + 1L
    } else {
      log_trace("Next page does not exist. Stopping at this iteration.")
      congress_stop <-  TRUE
    }

    congress_data <-
      session %>%
        html_nodes("div.alight p") %>% {
          tibble(
          republic_act_id =
            html_node(., "span") %>%
            html_text(),
          title = ifelse(
            is.na(html_node(., "a")),
            html_node(., xpath = "text()[1]") %>%
              html_text(trim = TRUE) %>%
              stringr::str_remove("(Approved|Lapsed).*$"),
            html_node(., "a") %>%
              html_node(xpath = "text()[1]") %>%
              html_text(trim = TRUE)
          ),
          approval = ifelse(
            is.na(html_node(., "a")),
            html_node(., xpath = "text()[1]") %>%
              html_text(trim = TRUE) %>%
              stringr::str_extract("(Approved|Lapsed).*$"),
            html_node(., xpath = "text()[1]") %>%
              html_text(trim = TRUE)
          ),
          pdf_link = ifelse(
            is.na(html_node(., "a")),
            NA_character_,
            html_node(., "a") %>%
              html_attr("href") %>%
              url_absolute("http://legacy.senate.gov.ph/lis/")
          )
        )
      } %>%
      bind_rows(congress_data)

    log_info("Extracted {nrow(congress_data)} rows")

  }

  congress_data %>%
    mutate(congress_id = !!congress_id)

}

data_senate_republic_act_load <- function(data, congress_id) {
  data %>%
    group_by(congress_id) %T>% {
      log_info("Loading republic acts for {congress_id} congress")
    } %>%
    dataset_write(data_bucket("senate/republic_act")) %T>% {
      log_success("Loaded republic acts for {congress_id} congress!")
    }
}
