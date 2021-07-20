scrape_allowed <- function(url, ...) {

  suppressMessages(robotstxt::paths_allowed(
    paths = url,
    ...,
    user_agent = pkg_user_agent
  ))

}

scrape_session <- function(url, ...) {

  assert_true(scrape_allowed(url))

  rvest::session(
    url = url,
    httr::user_agent(pkg_user_agent),
    ...
  )

}
