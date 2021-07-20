scrape_allowed <- function(url, ...) {

  robotstxt::paths_allowed(
    paths = url,
    ...,
    user_agent = pkg_user_agent,
    bot = pkg_user_agent
  )

}

scrape_session <- function(url, ...) {

  assert_true(scrape_allowed(url))

  session(
    url = url,
    httr::user_agent(pkg_user_agent),
    ...
  )

}
