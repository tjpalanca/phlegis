#' @title
#' Read and Write Datasets to object storage
#'
#' @description
#' Write a dataset using the [`arrow::write_dataset`] and then set the access
#' policy of the dataset (`public-read` by default). Read the dataset using
#' [`arrow::open_dataset`].
#'
#' @param dataset,path,... see [`arrow::write_dataset`] or
#'                         [`arrow::open_dataset`]
#' @param policy either `public-read` (default) or `private`.
#' @param creds  storage credentials
#'
#' @name dataset
NULL

#' @rdname dataset
#' @export
dataset_write <- function(dataset,
                          path,
                          ...,
                          policy = "public-read",
                          creds = storage_credentials()) {

  assert_class(dataset, "data.frame")
  assert_class(path, "FileSystem")
  assert_choice(policy, c("public-read", "private"))

  arrow::write_dataset(
    dataset = dataset,
    path = path,
    ...
  )

  if (policy == "public-read") {
    storage_set_policy(
      path   = path,
      policy = policy,
      creds  = creds
    )
  }

  return(dataset)

}

#' @rdname dataset
#' @export
dataset_open <- function(...) {

  arrow::open_dataset(...)

}

