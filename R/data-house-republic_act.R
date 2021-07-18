#' @describeIn data House of Representatives - Republic Acts
data_house_republic_act <- function() {

  dataset_open(data_bucket("house/republic_act"))

}

data_house_republic_act_load <- function(...) {

  republic_acts.ses <-
    session("https://congress.gov.ph/legisdocs/?v=ra")

  data_house_congress() %>%
    filter(...) %>%
    collect() %>%
    mutate(
      session = map2(form_value, congress_id, function(form_value, cid) {
        log_info("Extracting web page content for {cid} congress")
        republic_acts.ses %>%
          session_submit(
            html_node(., ".form-inline.pull-right") %>%
              html_form() %>%
              html_form_set(congress = form_value)
          )
      })
    ) %>%
    mutate(
      extract = walk2(
        session, congress_id,
        data_house_republic_act_extract
      )
    )

  data_house_republic_act()

}

data_house_republic_act_extract <- function(session, congress_id) {

  log_info("Extracting republic acts for {congress_id} congress")
  bind_cols(
    session %>%
      html_nodes(glue(
        ".panel.panel-default ",
        ".panel-heading:not(.panel-heading-custom)"
      )) %>%
      map_dfr(function(node) {
        tibble::tibble(
          republic_act_id =
            html_node(node, "span.text-muted") %>%
            html_text(),
          pdf_link =
            html_node(node, "span.pull-right a") %>%
            html_attr("href") %>%
            url_absolute("https://congress.gov.ph/")
        )
      }),
    session %>%
      html_nodes(".panel.panel-default .panel-body") %>%
      map_dfr(function(node) {
        tibble::tibble(
          title =
            html_text(html_node(node, "p:nth-child(1)")) %>%
            parsing_remove_non_utf8(),
          president_approval = html_text(html_node(node, "p:nth-child(2)")),
          origin = html_text(html_node(node, "p:nth-child(3)"))
        )
      })
  ) %>%
    mutate(congress_id = !!congress_id) %>%
    group_by(congress_id) %T>% {
      log_info("Loading republic acts for {congress_id} congress!")
    } %>%
    dataset_write(data_bucket("house/republic_act")) %T>% {
      log_success("Loaded republic acts for {congress_id} congress!")
    }

}
