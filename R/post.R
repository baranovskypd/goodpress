#' Post a post to Wordpress
#'
#' @param post_folder Path to folder where the post (index.Rmd, index.md, media)
#' lives
#' @param wordpress_url URL to your website
#'
#' @return URL to the post (invisibly)
#' @export
#'
#' @examples
#' \dontrun{
#' # this requires authentication!
#' post_folder <- system.file(file.path("post-example", "index.md"), package = "goodpress")
#' wordpress_url <- "https://rmd-wordpress.eu" # replace with your own (test) website
#' wp_post(post_folder, wordpress_url)
#' }
wp_post <- function(post_folder, wordpress_url) {

   body <- commonmark::markdown_html(
     glue::glue_collapse(blogdown:::split_yaml_body(readLines(path))$body,
                         sep = "\n"),
     extensions = TRUE)

   meta <- rmarkdown::yaml_front_matter(path)
     post <- jsonlite::toJSON(
     list( 'date' = meta$date,
           'title' = meta$title,
           'slug' = meta$slug,
           'status' = 'publish',
           'content' = body,
           'excerpt' = meta$excerpt,
           'format' = 'standard'),
     auto_unbox = TRUE
     )
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




