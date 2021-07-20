#' @describeIn data House of Representatives - Bills and Resolutions
data_house_bill <- function() {

  dataset_open(data_bucket("house/bill"))

}

data_house_bill_pipeline <- function(...) {

  session <- scrape_session("https://congress.gov.ph/legisdocs/?v=bills")

  session %>%
    data_house_congress_extract() %>%
    filter(...) %>% {
      map2(
        .$form_value, .$congress_id,
        function(form_value, congress_id) {
          session %>%
            data_house_bill_submit(form_value) %>%
            data_house_bill_extract(congress_id) %>%
            data_house_bill_load(congress_id)
        }
      )
    }

}

data_house_bill_submit <- function(session, form_value) {

  session %>%
    session_submit(
      html_node(., ".form-inline.pull-right") %>%
        html_form() %>%
        html_form_set(congress = form_value)
    )

}

data_house_bill_extract <- function(session, congress_id) {

  log_info("Extracting bills and resolutions for {congress_id} congress")
  session %>%
    html_nodes(".panel-body") %>% (function(bodies) {
      tibble::tibble(
        pdf_link = bodies %>%
          html_node(".pull-left a:nth-child(2)") %>%
          html_attr("href") %>%
          url_absolute("https://congress.gov.ph"),
        title = bodies %>%
          html_node("p strong") %>%
          html_text() %>%
          parsing_remove_non_utf8(),
        data_id = bodies %>%
          html_node(".pull-left a:nth-child(1)") %>%
          html_attr("data-id")
      ) %>% mutate(info = {
        log_info("Retreiving information")
        pb <- pb_new(bodies)
        map(
          bodies,
          ~html_nodes(., xpath = "p[position() >= 2]") %>% {
            tibble::tibble(
              field = html_text(html_nodes(., "span.text-warning")),
              value = html_text(html_nodes(., xpath = "text()"), trim = TRUE)
            )
          } %>%
            pb_tick(pb)
        )
      }) %>% mutate(extra = {
        log_info("Retreiving history")
        pb <- pb_new(data_id)
        map(
          data_id,
          ~POST(
            url    = "https://congress.gov.ph/legisdocs/fetch_history.php",
            encode = "form",
            body   = list(rowid = .)
          ) %>%
            content(as = "parsed") %>%
            html_nodes("td") %>%
            html_text() %>%
            pb_tick(pb)
        )
      })
    }) %>%
    mutate(congress_id = !!congress_id)

}

data_house_bill_load <- function(data, congress_id) {

  data %>%
    group_by(congress_id) %T>% {
      log_info("Loading bills and resolutions for {congress_id} congress!")
    } %>%
    dataset_write(data_bucket("house/bill")) %T>% {
      log_success("Loaded bills and resolutions for {congress_id} congress!")
    }

}

