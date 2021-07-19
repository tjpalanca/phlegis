dev_job <- function(expr) {
  expr <- substitute(expr)
  job::job({
    devtools::load_all()
    eval(expr)
    job::export("all")
  }, packages = NULL)
}
