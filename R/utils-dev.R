dev_job <- function(expr, title = NULL) {
  expr <- substitute(expr)
  job::job(
    {
      devtools::load_all()
      eval(expr)
      job::export("all")
    },
    packages = NULL,
    title = title
  )
}
