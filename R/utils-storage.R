storage_credentials <- function() {

  list(
    key      = Sys.getenv("PHLEGIS_DOSPACE_KEY"),
    secret   = Sys.getenv("PHLEGIS_DOSPACE_SECRET"),
    base_url = "digitaloceanspaces.com",
    region   = "sgp1"
  )

}

storage_s3 <- function(fn, ..., creds = storage_credentials()) {

  fn(
    ...,
    key      = creds$key,
    secret   = creds$secret,
    base_url = creds$base_url,
    region   = creds$region
  )

}

storage_get_paths <- function(filesystem, path = "") {

  assert_class(filesystem, "FileSystem")

  if (inherits(filesystem$base_fs, "S3FileSystem")) {
    list(
      bucket = str_remove(filesystem$base_path, "/$"),
      prefix = path
    )
  } else {
    storage_get_paths(
      filesystem$base_fs,
      paste0(filesystem$base_path, path)
    )
  }
}

storage_bucket <- function(bucket,
                           path,
                           creds = storage_credentials()) {

  assert_string(bucket)

  S3FileSystem$create(
    access_key = creds$key,
    secret_key = creds$secret,
    endpoint_override = glue("{creds$region}.{creds$base_url}")
  )$cd(bucket)$cd(path)

}

storage_list <- function(path, creds = storage_credentials()) {

  assert_class(path, "FileSystem")

  paths <- storage_get_paths(path)

  storage_s3(
    fn       = aws.s3::get_bucket_df,
    bucket   = paths$bucket,
    prefix   = paths$prefix,
    creds    = creds,
  ) %>%
    set_names(snakecase::to_snake_case(names(.)))

}

storage_set_policy <- function(path,
                               policy,
                               creds = storage_credentials()) {

  assert_class(path, "FileSystem")
  assert_choice(policy, c("public-read", "private"))

  paths <- storage_get_paths(path)

  storage_list(path, creds) %>%
    # Remove directory keys
    filter(!str_detect(key, "/$")) %>%
    pull(key) %>%
    walk(
      function(path, bucket, policy, creds) {
        storage_s3(
          fn       = aws.s3::s3HTTP,
          verb     = "PUT",
          path     = path,
          bucket   = bucket,
          query    = list(acl = ""),
          creds    = creds,
          headers  = list(`x-amz-acl` = policy)
        )
      },
      bucket = paths$bucket,
      policy = policy,
      creds  = creds
    )

}

storage_delete <- function(path, creds = storage_credentials()) {

  paths <- storage_get_paths(path)

  storage_list(path, creds) %>%
    pull(key) %>%
    storage_s3(
      object = .,
      fn     = aws.s3::delete_object,
      bucket = paths$bucket,
      creds  = creds
    )

}
