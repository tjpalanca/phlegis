#' @describeIn data House of Representatives - Republic Acts
data_house_republic_act <- function() {

  dataset_open(data_bucket("house/republic_act"))

}

#' @rdname data
data_house_republic_act_pipeline <- function(...) {

  session <- scrape_session("https://congress.gov.ph/legisdocs/?v=ra")

  session %>%
    data_house_congress_extract() %>%
    filter(...) %>% {
      walk2(
        .$form_value, .$congress_id,
        function(form_value, congress_id) {
          session %>%
            data_house_republic_act_submit(form_value) %>%
            data_house_republic_act_extract(congress_id) %>%
            data_house_republic_act_load()
        }
      )
    }

}

data_house_republic_act_submit <- function(session, form_value) {

  session %>%
    session_submit(
      html_node(., ".form-inline.pull-right") %>%
        html_form() %>%
        html_form_set(congress = form_value)
    )

}

data_house_republic_act_extract <- function(session, congress_id) {

  log_info("Extracting republic acts for {congress_id} congress")
  bind_cols(
    session %>%
      html_nodes(glue(
        ".panel.panel-default ",
        ".panel-heading:not(.panel-heading-custom)"
      )) %>% {
        tibble::tibble(
          republic_act_id =
            html_node(., "span.text-muted") %>%
            html_text(),
          pdf_link =
            html_node(., "span.pull-right a") %>%
            html_attr("href")  %>%
            url_absolute("https://congress.gov.ph/")
        )
      },
    session %>%
      html_nodes(".panel.panel-default .panel-body") %>% {
        tibble::tibble(
          title =
            html_node(., "p:nth-child(1)") %>%
            html_text() %>%
            parsing_remove_non_utf8(),
          president_approval =
            html_node(., "p:nth-child(2)") %>%
            html_text(),
          origin =
            html_node(., "p:nth-child(3)") %>%
            html_text()
        )
      }
  ) %>%
    mutate(congress_id = !!congress_id)

}

data_house_republic_act_load <- function(data) {
  data %>%
    group_by(congress_id) %T>% {
      log_info("Loading republic acts for {congress_id} congress")
    } %>%
    dataset_write(data_bucket("house/republic_act")) %T>% {
      log_success("Loaded republic acts for {congress_id} congress!")
    }
}
