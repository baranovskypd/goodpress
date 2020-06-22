#' Post a post to Wordpress
#'
#' @param post_folder Path to folder where the post (index.Rmd, index.md, images)
#' lives
#' @param wordpress_url URL to your website
#'
#' @details To set the status of the post (One of: "publish", "future", "draft",
#'  "pending", "private") use a YAML field e.g. `status: "draft"`.
#'
#'  The package cannot handle private posts with password, only private posts that
#'   are visible to admins and editors only. You could create a private post, and
#'   then from the WordPress interface make it visible with password. Make it private again
#'   before trying to update the post with the R package.
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
       wd = getwd(),
       options = "--mathjax"
       )
   )

   body <- glue::glue_collapse(readLines(html_path), sep = "\n")
   file.remove(html_path)

   meta <- rmarkdown::yaml_front_matter(path)

  categories <- wp_handle_categories(
       meta$categories, wordpress_url
       )

  tags <- wp_handle_tags(
    meta$tags, wordpress_url
  )

  author <- wp_handle_author(
    meta$author, wordpress_url
  )

   post_list <- list( 'date' = meta$date,
                      'title' = meta$title,
                      'slug' = meta$slug %||% NULL,
                      'comment_status' = meta$comment_status %||% "closed",
                      'ping_status' = meta$ping_status %||% "closed",
                      'status' = 'draft',
                      'content' = body,
                      'excerpt' = meta$excerpt %||% NULL,
                      'format' = meta$format %||% 'standard',
                      'categories' = categories,
                      'tags' = tags
                      )

   if (!is.null(author)) {
     post_list$author <- author
   }

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

   media <- .wp_media_post(
     post,
     post_folder = post_folder,
     post_id = post_post$id,
     wordpress_url
   )

   if (length(media)) {
     content <- xml2::read_html(post_list$content)
     imgs <- xml2::xml_find_all(content, "//img")
       for (i in seq_along(media)) {
         this_img <- imgs[xml2::xml_attr(imgs, "src") == paste0("figs/", media$fig[i])]
          xml2::xml_attr(
            this_img, "src"
           ) <- media$url[i]
       }
    post_list$content <- as.character(content)

   }

   if(is.null(meta$status)){
     post_list$status <- "publish"
   } else {
     post_list$status <- meta$status
   }


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

   message("Post posted with status ", post_post$status)

  if(base::interactive()) {
    if (post_post$status %in% c("publish", "private")) {
      utils::browseURL(post_post$link)
    }

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

  if (length(figs)) {
    fig_urls <- purrr::map_chr(
      figs, wp_upload_media,
      wordpress_url = wordpress_url,
      post_id = post_id)
    return(tibble::tibble(fig = basename(figs), url = fig_urls))
  } else {
    return(NULL)
  }
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

wp_handle_categories <- function(categories, wordpress_url) {

  if (is.null(categories)) {
    return(NULL)
  }

  # list existing categories

  online_categories <- wp_call_api(
    VERB = "GET",
    api_url = paste0(wordpress_url, "/wp-json/wp/v2/categories")
    )

  online_categories_df <- data.frame(
    id = purrr::map_chr(online_categories, "id"),
    name = purrr::map_chr(online_categories, "name"),
    stringsAsFactors = FALSE
  )

  # If needed create categories
  offline_categories <- categories[!categories %in% online_categories_df$name]

  if (length(offline_categories) > 0) {
    for(category in offline_categories) {

      new_category <- wp_call_api(
        VERB = "POST",
        api_url = paste0(wordpress_url, "/wp-json/wp/v2/categories?name=", category)
      )
    online_categories_df <- rbind(
      online_categories_df,
      data.frame(id = new_category$id, name = new_category$name,
                 stringsAsFactors = FALSE)
    )
    }
  }

  # return categories IDs
  online_categories_df$id[online_categories_df$name %in% categories]

}

wp_handle_tags <- function(tags, wordpress_url) {

  if (is.null(tags)) {
    return(NULL)
  }

  # list existing tags

  online_tags <- wp_call_api(
    VERB = "GET",
    api_url = paste0(wordpress_url, "/wp-json/wp/v2/tags")
  )

  online_tags_df <- data.frame(
    id = purrr::map_chr(online_tags, "id"),
    name = purrr::map_chr(online_tags, "name"),
    stringsAsFactors = FALSE
  )

  # If needed create tags
  offline_tags <- tags[!tags %in% online_tags_df$name]

  if (length(offline_tags) > 0) {
    for(tag in offline_tags) {

      new_tag <- wp_call_api(
        VERB = "POST",
        api_url = paste0(wordpress_url, "/wp-json/wp/v2/tags?name=", tag)
      )
      online_tags_df <- rbind(
        online_tags_df,
        data.frame(id = new_tag$id, name = new_tag$name,
                   stringsAsFactors = FALSE)
      )
    }
  }

  # return tags IDs
  online_tags_df$id[online_tags_df$name %in% tags]

}

wp_handle_author <- function(author, wordpress_url) {

  if (is.null(author)) {
    return(NULL)
  }

  # list existing authors

  online_authors <- wp_call_api(
    VERB = "GET",
    api_url = paste0(wordpress_url, "/wp-json/wp/v2/users")
  )

  online_authors_df <- data.frame(
    id = purrr::map_chr(online_authors, "id"),
    name = purrr::map_chr(online_authors, "name"),
    stringsAsFactors = FALSE
  )

  if (!author %in% online_authors_df$name) {
    stop(paste(author, "is not an existing user name."))
  }

  online_authors_df$id[online_authors_df$name == author]

}
