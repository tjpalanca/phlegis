#' @title
#' Write a dataset to storage
#'
#' @description
#' Write a dataset using the [`arrow::write_dataset`] and then set the access
#' policy of the dataset (`public-read` by default).
#'
#' @param dataset,path,... see [`arrow::write_dataset`]
#' @param policy either `public-read` (default) or `private`.
#' @param creds  storage credentials
#'
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

}

