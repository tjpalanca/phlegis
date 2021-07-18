session_house <- function() {

}

extract_house_republic_acts <- function(session) {
  bind_cols(
    html_nodes(
      session,
      ".panel.panel-default .panel-heading:not(.panel-heading-custom)"
    ) %>% {
      tibble::tibble(
        republic_act_id =
          html_nodes(., "span.text-muted") %>%
          html_text(),
        pdf_link =
          html_nodes(., "span.pull-right a") %>%
          html_attr("href") %>%
          url_absolute(republic_acts.ses$url)
      )
    },
    html_nodes(
      session,
      ".panel.panel-default .panel-body"
    ) %>% {
      tibble::tibble(
        title = html_text(html_nodes(., "p:nth-child(1)")),
        president_approval = html_text(html_nodes(., "p:nth-child(2)")),
        origin = html_text(html_nodes(., "p:nth-child(3)"))
      )
    }
  )
}
