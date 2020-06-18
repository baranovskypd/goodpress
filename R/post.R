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
#' post_folder <- system.file(file.path("post-example"), package = "goodpress")
#' tmp_post_folder <- file.path(tempdir(), "post")
#' dir.create(tmp_post_folder)
#' file.copy(dir(post_folder, full.names = TRUE), tmp_post_folder)
#' wordpress_url <- "https://rmd-wordpress.eu" # replace with your own (test) website
#' wp_post(tmp_post_folder, wordpress_url)
#' file.remove(dir(tmp_post_folder, full.names = TRUE))
#' }
wp_post <- function(post_folder, wordpress_url) {

   path <- file.path(post_folder, "index.md")
   wordpress_meta_path <- file.path(post_folder, ".wordpress.yml")

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


  # Create the post if it doesn't exist
  if(!file.exists(wordpress_meta_path)) {

    post_post <- .wp_post(post, post_id = NULL,
                          wordpress_url)

    # Write WordPress metadata to disk
    yaml::write_yaml(
      list(
        URL = post_post$link,
        id = post_post$id
        ),
      file = wordpress_meta_path)

  } else {
    # Update the existing post
    wordpress_meta <- yaml::read_yaml(wordpress_meta_path)

    post_post <- .wp_post(post,
                          post_id = wordpress_meta$id,
                          wordpress_url
                          )
    # Write WordPress metadata to disk
    yaml::write_yaml(
      list(
        URL = post_post$link,
        id = post_post$id
      ),
      file = wordpress_meta_path)
  }

  if(base::interactive()) {
    browseURL(post_post$link)
  }

  invisible(post_post$link)

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

.wp_post <- function(post, post_id = NULL,
                     wordpress_url) {

  if (is.null(post_id)) {
    api_url <- paste0(wordpress_url, "/wp-json/wp/v2/posts")
  } else{
    api_url <- paste0(wordpress_url, "/wp-json/wp/v2/posts/", post_id)
  }

  wp_call_api(
    VERB = "POST",
    api_url = api_url,
    body = post
    )
}
