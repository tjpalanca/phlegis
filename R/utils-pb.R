pb_tick <- function(x, pb, ...) {
  pb$tick(...)
  return(x)
}

pb_new <- function(x, ...) {
  progress_bar$new(
    total = length(x),
    ...
  )$tick(0)
}
