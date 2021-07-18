# Home Rprofile
if (file.exists("~/.Rprofile")) source("~/.Rprofile", chdir = TRUE)

# Development Utilities
if (interactive()) {
  r <- function(reset = FALSE, ...) {
    if (reset) {
      rm(list = ls(globalenv()), envir = )
      source(".Rprofile")
    }
    if (rstudioapi::isAvailable()) {
      rstudioapi::documentSaveAll()
    }
    pkgload::load_all(...)
  }
  dr <- function(reset = FALSE, ...) {
    devtools::document()
    r(reset = reset, ...)
  }
}
