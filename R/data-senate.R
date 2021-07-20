data_senate_next_page_exists <- function(session, page_index) {

  session %>%
    html_node(".lis_pagenav") %>%
    html_nodes(glue("a:contains('{page_index + 1L}')")) %>%
    length() %>%
    is_weakly_greater_than(1L)

}
