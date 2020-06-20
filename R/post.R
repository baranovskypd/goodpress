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

   html_path <- tempfile(fileext = ".html")
   file.create(html_path)

   withr::with_dir(
     post_folder,
     rmarkdown::pandoc_convert(
       "index.md",
       to = "html",
       output = html_path,
       wd = getwd()
       )
   )

   body <- glue::glue_collapse(readLines(html_path), sep = "\n")
   file.remove(html_path)

   meta <- rmarkdown::yaml_front_matter(path)

   post_list <- list( 'date' = meta$date,
                      'title' = meta$title,
                      'slug' = meta$slug,
                      'status' = 'draft',
                      'content' = body,
                      'excerpt' = meta$excerpt,
                      'format' = 'standard')

   post <- jsonlite::toJSON(
     post_list,
     auto_unbox = TRUE
     )


  # Create the post if it doesn't exist
  if(!file.exists(wordpress_meta_path)) {

    post_post <- .wp_post(
      post,
      post_id = NULL,
      wordpress_url
    )

  } else {
    # Update the existing post
    wordpress_meta <- yaml::read_yaml(wordpress_meta_path)

    post_post <- .wp_post(
      post,
      post_id = wordpress_meta$id,
      wordpress_url
      )

  }

   # Media

   if(length(dir(file.path(post_folder, "figs"))) > 0) {
     media <- .wp_media_post(
       post,
       post_folder = post_folder,
       post_id = post_post$id,
       wordpress_url
     )

     for (i in seq_along(media)) {

       post_list$content <- gsub(paste0("figs/", media$fig[i]),
                    media$url[i],
                    post_list$content)
     }

   }

   post_list$status <- "publish"

   post <- jsonlite::toJSON(
     post_list,
     auto_unbox = TRUE
   )

   post_post <- .wp_post(
     post,
     post_id = post_post$id,
     wordpress_url
   )

   # Write WordPress metadata to disk
   yaml::write_yaml(
     list(
       URL = post_post$link,
       id = post_post$id
     ),
     file = wordpress_meta_path)



  if(base::interactive()) {
    utils::browseURL(post_post$link)
  }

  invisible(post_post$link)

}


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

.wp_media_post <- function(post, post_folder, post_id,
                           wordpress_url) {
  # delete all existing image media

  api_url <- paste0(wordpress_url, "/wp-json/wp/v2/media?parent=", post_id)

  media <- wp_call_api(VERB = "GET", api_url = api_url)

  if (length(media) > 0) {
    media_ids <- purrr::map_chr(media, "id")[purrr::map_chr(media, "media_type") == "image"]
    purrr::walk(media_ids, wp_delete_media,
                wordpress_url)
  }

  figs <- dir(file.path(post_folder, "figs"),
              full.names = TRUE)

  fig_urls <- purrr::map_chr(
             figs, wp_upload_media,
              wordpress_url = wordpress_url,
              post_id = post_id)
  return(tibble::tibble(fig = basename(figs), url = fig_urls))
}

wp_delete_media <- function(media_id, wordpress_url) {

  wp_call_api(VERB = "DELETE", api_url =
                paste0(wordpress_url, "/wp-json/wp/v2/media/", media_id, "?force=true"))
}

wp_upload_media <- function(media_path, wordpress_url, post_id) {

  image <- httr::upload_file(media_path)

  img <- wp_call_api(VERB = "POST",
              api_url =
                paste0(wordpress_url, "/wp-json/wp/v2/media?post=", post_id),
              body = image,
              filename = basename(media_path))

  return(img$media_details$sizes$full$source_url)
}
