parsing_remove_non_utf8 <- function(x) {
  iconv(x, "UTF-8", "UTF-8", sub = " ")
}
