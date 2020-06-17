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
     glue::glue_collapse(split_yaml_body(readLines(path))$body,
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


# from https://github.com/rstudio/blogdown/blob/9ce8c0d0d8e3cadfa26b216e2a58d2e313f9b6bd/R/utils.R#L442
# split Markdown to YAML and body (adapted from xaringan)
split_yaml_body = function(x) {
  i = grep('^---\\s*$', x)
  n = length(x)
  res = if (n < 2 || length(i) < 2 || (i[1] > 1 && !knitr:::is_blank(x[seq(i[1] - 1)]))) {
    list(yaml = character(), body = x)
  } else list(
    yaml = x[i[1]:i[2]], yaml_range = i[1:2],
    body = if (i[2] == n) character() else x[(i[2] + 1):n]
  )
  res$yaml_list = if ((n <- length(res$yaml)) >= 3) {
    yaml_load(res$yaml[-c(1, n)])
  }
  res
}

# anotate seq type values because both single value and list values are
# converted to vector by default
yaml_load = function(x) yaml::yaml.load(
  x, handlers = list(
    seq = function(x) {
      # continue coerce into vector because many places of code already assume this
      if (length(x) > 0) {
        x = unlist(x, recursive = FALSE)
        attr(x, 'yml_type') = 'seq'
      }
      x
    }
  )
)

