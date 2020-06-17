#' Post a post
#'
#' @param post (JSON)
#' @param wordpress_url
#'
#' @return URL to the post
#' @export
#'
#' @examples
#'   post <- jsonlite::toJSON(
#'   list( 'date' = '2017-06-19T20:00:35',
#'         'title' = 'First REST API post',
#'         'slug' = 'rest-api-1',
#'         'status' = 'publish',
#'         'content' = 'this is the <a href="https://masalmon.eu">content</a>',
#'         'excerpt' = 'Exceptional post!',
#'         'format' = 'standard'),
#'   auto_unbox = TRUE
#'   )
#'  wordpress_url <- "https://rmd-wordpress.eu"
#'   wp_post(post, wordpress_url)
wp_post <- function(post, wordpress_url) {

  token <- paste("Basic",
                 jsonlite::base64_enc(
    glue::glue(
      '{Sys.getenv("WP_USER")}:{Sys.getenv("WP_PWD")}'
      )
    )
  )

  post_post <- httr::POST(url = paste0(wordpress_url, "/wp-json/wp/v2/posts"),
             httr::add_headers(Authorization = token,
                               "Content-Type"="application/json"),
             body = post)
  httr::stop_for_status(post_post)

  post_url <- httr::content(post_post)$link

  if(base::interactive()) {
    browseURL(post_url)
  }

  invisible(post_url)

}
