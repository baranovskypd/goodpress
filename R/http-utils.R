wp_call_api <- function(VERB, api_url, body = NULL) {

  token <- paste("Basic",
                 jsonlite::base64_enc(
                   glue::glue(
                     '{Sys.getenv("WP_USER")}:{Sys.getenv("WP_PWD")}'
                   )
                 )
  )

  api_response <- httr::VERB(verb = VERB,
                          url = api_url,
                          httr::add_headers(Authorization = token,
                                            "Content-Type"="application/json"),
                          body = body)

  httr::stop_for_status(api_response)

  httr::content(api_response)
}
