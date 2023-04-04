#' Post a post to Wordpress
#'
#' @param post_folder Path to folder where the post
#' (index.Rmd with `hugodown::md_document` output format,
#' index.md, images)
#' lives
#' @param wordpress_url URL to your website
#' @param encoding Encoding argument to readLines
#'
#' @details Several aspects of the post can be controlled by the YAML of index.Rmd.
#' ```yaml
#' ---
#' title: "Title of the Post" # compulsory!
#' date: "2020-04-01T00:00:00" # compulsory!
#' author: "admin7891" # Either omit the field (the author will be
#' #  the authenticated user) or use an username
#' slug: "post-slug" # Important especially if the slug is in the URL
#' excerpt: "Here I summarize this fantastic post"
#' status: "publish" # One of: "publish", "future", "draft",
#' #  "pending", "private"; "publish" by default
#' output: hugodown::md_document # Don't change this
#' categories: # Categories, optional, will be created if
#' # the post is the first with the category
#'   - math
#' - Code and Stuff
#' tags: # Tags, optional, will be created if
#' # the post is the first with the tag
#'   - crul
#'   - mathjax
#'   - R packages
#' comment_status: closed # Either closed (default) or open
#' ping_status: closed # Either closed (default) or open
#' ---
#' ```
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
wp_post <- function(post_folder, wordpress_url, encoding = "UTF-8") {

   if(!(nzchar(Sys.getenv("WP_USER")) && nzchar(Sys.getenv("WP_PWD")))) {
     stop("The environment variables WP_USER (username) and WP_PWD (application password) have not been set correctly in .Renviron.
Refer to https://maelle.github.io/goodpress/articles/setup.html
Use usethis::edit_r_environ() for instance.
Or maybe you forgot to re-start R after editing .Renviron?")
   }

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
       options = c("--mathjax","--wrap=none")
       )
   )

   body <- glue::glue_collapse(readLines(html_path, encoding = encoding), sep = "\n")
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

  date <- format(Sys.time(), '%Y-%m-%dT%H:%M:%S')
  slug <- slugify::slugify(meta$title)

   post_list <- list( 'date' = meta$date %||% date,
                      'title' = meta$title,
                      'slug' = meta$slug %||% slug,
                      'comment_status' = meta$comment_status %||% "closed",
                      'ping_status' = meta$ping_status %||% "closed",
                      'status' = 'draft',
                      'content' = body,
                      'excerpt' = meta$excerpt %||% NULL,
                      'format' = 'standard',
                      'template' = meta$template %||% NULL,
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

   if (!is.null(media)) {
     content <- xml2::read_html(post_list$content)
     imgs <- xml2::xml_find_all(content, "//img")
       for (i in 1:nrow(media)) {
         this_img <- imgs[xml2::xml_attr(imgs, "src") == paste0("figs/", media$fig[i])]
          xml2::xml_attr(
            this_img, "src"
           ) <- media$url[i]
       }
    post_list$content <- as.character(xml2::xml_child(content))

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
    media_ids <- purrr::map_chr(media, ~as.character(.x[["id"]]))[purrr::map_chr(media, "media_type") == "image"]
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

wp_get_taxo_id <- function(term, taxo, wordpress_url) {

  # does the term already exist
  api_url <- httr::modify_url(wordpress_url,
                              path = paste0("/wp-json/wp/v2/", taxo),
                              query = list("per_page" = 100,
                                        "search" = term))

  online_terms <- wp_call_api(
    VERB = "GET",
    api_url = api_url
  )

  online_terms_df <- data.frame(
    id = purrr::map_chr(online_terms, ~as.character(.x[["id"]])),
    name = purrr::map_chr(online_terms, "name"),
    stringsAsFactors = FALSE
  )

  # if not create it
  if (! term %in% online_terms_df$name) {

    new_term <- wp_call_api(
      VERB = "POST",
      api_url = httr::modify_url(
        wordpress_url,
        path = paste0("/wp-json/wp/v2/", taxo),
        query = list(name = term)
      )
    )
    online_terms_df <- rbind(
      online_terms_df,
      data.frame(id = new_term$id, name = new_term$name,
                 stringsAsFactors = FALSE)
    )
  }

  as.character(
    online_terms_df$id[online_terms_df$name == term]
  )
}

wp_handle_tags <- function(tags, wordpress_url) {

  if (is.null(tags)) {
    return(NULL)
  }

  purrr::map_chr(
    tags,
    wp_get_taxo_id,
    taxo = "tags",
    wordpress_url =
      wordpress_url)

}

wp_handle_categories <- function(categories, wordpress_url) {

  if (is.null(categories)) {
    return(NULL)
  }

  purrr::map_chr(
    categories,
    wp_get_taxo_id,
    taxo = "categories",
    wordpress_url =
      wordpress_url)

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
    id = purrr::map_chr(online_authors, ~as.character(.x[["id"]])),
    name = purrr::map_chr(online_authors, "name"),
    stringsAsFactors = FALSE
  )

  if (!author %in% online_authors_df$name) {
    stop(paste(author, "is not an existing user name."))
  }

  online_authors_df$id[online_authors_df$name == author]

}
