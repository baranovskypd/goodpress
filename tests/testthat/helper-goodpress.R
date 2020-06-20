library("vcr")

vcr_dir <- "../fixtures"

if (!nzchar(Sys.getenv("WP_PWD"))||!nzchar(Sys.getenv("WP_USER"))) {
  if (dir.exists(vcr_dir)) {
    Sys.setenv("WP_PWD" = "foobar")
    Sys.setenv("WP_USER" = "barfoo")
  } else {
    stop("No WordPress username+application password, nor cassettes, tests cannot be run.",
         call. = FALSE)
  }
}


invisible(vcr::vcr_configure(
  dir = vcr_dir,
  filter_sensitive_data = list("<<<my_api_key>>>" = Sys.getenv('WP_PWD'),
                               "<<<my_username>>>" = Sys.getenv('WP_USER'))
))
vcr::check_cassette_names()
