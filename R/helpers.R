#' Add "Read More" Separator
#'
#' @description This function allows you to insert a Read More tag
#' into your post.
#' @return Read More tag
#' @details used in your inline code wherever you want in your index.Rmd
#' @export
#'
#' @examples
#' goodpress::read_more()
read_more <- function() {
  paste(
    "<!-- wp:more -->",
    "<!--more-->",
    "<!-- /wp:more -->",
    sep = "\n"
  )
}

#' Get WordPress Categories
#' @description This function helps you get your WordPress categories
#' details so that you can use for your YAML header.
#' @param wordpress_url URL to your website
#' @return A data frame with category ids and names
#' @export
#'
#' @examples
#' wordpress_url <- "https://rmd-wordpress.eu" # replace with your own (test) website
#' wp_categories(wordpress_url)
wp_categories <- function(wordpress_url) {
  if (is.null(wordpress_url)) {
    stop("wordpress_url is missing")
  }

  wp_get_taxo(taxo = "categories", wordpress_url = wordpress_url)
}

#' Get WordPress Tags
#'
#' @param wordpress_url URL to your website
#' @description This function helps you get your WordPress tags
#' details so that you can use for your YAML header.
#'
#' @return A data frame with tag ids and names
#' @export
#'
#' @examples
#' wordpress_url <- "https://rmd-wordpress.eu" # replace with your own (test) website
#' wp_tags(wordpress_url)
wp_tags <- function(wordpress_url) {
  if (is.null(wordpress_url)) {
    stop("wordpress_url is missing")
  }

  wp_get_taxo(taxo = "tags", wordpress_url = wordpress_url)
}

wp_get_taxo <- function(taxo, wordpress_url) {
  api_url <- httr::modify_url(wordpress_url,
                              path = paste0("/wp-json/wp/v2/", taxo),
                              query = list("per_page" = 100))

  online_terms <- wp_call_api(
    VERB = "GET",
    api_url = api_url
  )

  online_terms_df <- data.frame(
    id = purrr::map_chr(online_terms, "id"),
    name = purrr::map_chr(online_terms, "name"),
    stringsAsFactors = FALSE
  )

  return(online_terms_df)
}

