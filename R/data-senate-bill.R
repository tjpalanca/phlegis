#' @describeIn data Senate - Bills and Resolutions
data_senate_bill <- function() {

  dataset_open(data_bucket("senate/bill"))

}

#' @rdname data
data_senate_bill_pipeline <- function(...) {

  session <-
    scrape_session("http://legacy.senate.gov.ph/lis/leg_sys.aspx?type=bill")

  session %>%
    data_senate_congress_extract() %>%
    filter(...) %>% {
      map2(
        .$congress_link, .$congress_id,
        function(congress_link, congress_id) {
          congress_link %>%
            data_senate_bill_extract(congress_id) %>%
            data_senate_bill_load(congress_id)
        }
      )
    }

}

data_senate_bill_extract <- function(congress_link,
                                     congress_id,
                                     page_limit = Inf) {

  log_info("Starting extraction for {congress_id} congress")

  congress_data <- tibble()
  congress_stop <- FALSE
  page_index <- 1L

  while (!congress_stop) {

    page_link <- glue("{congress_link}&p={page_index}")
    session  <- scrape_session(page_link)

    log_trace("Extracting data from {page_link}")

    next_page_exists <- data_senate_next_page_exists(session, page_index)

    if (next_page_exists & page_index < page_limit) {
      log_trace("Next page exists")
      page_index <- page_index + 1L
    } else {
      log_trace("Next page does not exist. Stopping at this iteration.")
      congress_stop <-  TRUE
    }

    congress_data <-
      session %>%
      html_nodes("div.alight a") %>% {
        tibble(
          bill_link = html_attr(., "href") %>%
            url_absolute("http://legacy.senate.gov.ph/lis/"),
          bill_text = html_text(.)
        )
      } %>%
      mutate(bill_info = map(bill_link, data_senate_bill_extract_bill)) %>%
      unnest(bill_info) %>%
      bind_rows(congress_data)

    log_info("Extracted {nrow(congress_data)} rows, {page_index - 1L} page(s)")

  }

  congress_data %>%
    mutate(
      across(
        where(
          ~is.list(.x) &&
            purrr::discard(., is.null) %>%
            extract2(1) %>%
            is.character()
        ),
        ~map_chr(., ~. %||% NA_character_)
      )
    ) %>%
    arrange(
      across(
        where(
          ~is.list(.x) &&
            purrr::discard(., is.null) %>%
            extract2(1) %>%
            is_tibble()
        ),
        ~map_lgl(., is.null)
      )
    ) %>%
    mutate(
      floor_activity = purrr::map_if(
        floor_activity,
        ~!is.null(.),
        ~mutate(., X3 = as.character(X3))
      )
    ) %>%
    mutate(congress_id = !!congress_id) %T>% {
      log_success("Completed extraction for {congress_id} congress")
    }

}

data_senate_bill_extract_bill <- function(bill_link, rate_limit = 5) {

  log_debug("Extracting {bill_link}")

  session <- scrape_session(bill_link)

  bill_extraction_error <-
    session %>%
    html_node("#content") %>%
    html_text(trim = TRUE) %>%
    equals("An error has occured. Exception has been logged.")

  if (bill_extraction_error) {
    log_debug("Bill extraction error. Server-side error.")
    return(NULL)
  }

  fields <-
    session %>%
    html_node("#form1") %>%
    html_form() %$%
    fields

  Sys.sleep(1 / rate_limit)
  POST(
    url    = bill_link,
    encode = "form",
    body   = list(
      `__EVENTTARGET` = "lbAll",
      `__VIEWSTATE` = fields$`__VIEWSTATE`$value,
      `__VIEWSTATEGENERATOR` = fields$`__VIEWSTATEGENERATOR`$value,
      `__EVENTVALIDATION` = fields$`__EVENTVALIDATION`$value
    )
  ) %>%
    content(as = "parsed") %>% {
      tibble(
        congress_title =
          html_nodes(., "#content") %>%
          html_node(xpath = "text()[1]") %>%
          html_text(trim = TRUE),
        bill_title =
          html_nodes(., "#content") %>%
          html_node(xpath = "text()[2]") %>%
          html_text(trim = TRUE),
        filing_title =
          html_nodes(., "#content") %>%
          html_node(xpath = "text()[3]") %>%
          html_text(trim = TRUE),
        pdf_links = list(
          html_nodes(., "#lis_download ul a") %>% {
            tibble(
              pdf_name = html_text(.),
              pdf_link = html_attr(., "href") %>%
                url_absolute("http://legacy.senate.gov.ph")
            )
          }
        ),
        legis_info = list(tibble(
          field =
            html_nodes(
              .,
              "#content p:not(.h1_bold):not(.backtotop)"
            ) %>%
            html_text(),
          value =
            html_nodes(
              .,
              "#content p:not(.h1_bold):not(.backtotop) + blockquote"
            ) %>% {
              map2(
                html_node(., "table"),
                html_text(.),
                ~if (is.na(.x)) {
                  .y
                } else {
                  html_table(.x)
                }
              )
            }
        ))
      ) %>%
        unnest(legis_info) %>%
        mutate(field = snakecase::to_snake_case(field)) %>%
        pivot_wider(
          names_from = field,
          values_from = value
        )
    }

}

data_senate_bill_load <- function(data, congress_id) {

  data %>%
    group_by(congress_id) %T>% {
      log_info("Loading bills and resolutions for {congress_id} congress!")
    } %>%
    dataset_write(data_bucket("senate/bill")) %T>% {
      log_success("Loaded bills and resolutions for {congress_id} congress!")
    }

}
