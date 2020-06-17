#' Set hooks for R Markdown
#'
#' @return Nothing
#' @export
#'
set_hooks <- function() {
  wordpress_classes <- function ()
  {
    c(NUM_CONST = "r plain", STR_CONST = "r string", NULL_CONST = "kr", FUNCTION = "r functions",
      special = "r plain", infix = "r plain", SYMBOL = "r plain", SYMBOL_FUNCTION_CALL = "r functions",
      SYMBOL_PACKAGE = "r plain", SYMBOL_FORMALS = "r plain", COMMENT = "r comments")
  }

  # knitr hook to render source code
  # differently when it's shell code (results == "asis")
  # vs R code
  knitr::knit_hooks$set(
    source = function(x, options) {

        if(!grepl("engine", options$params.src)) {
         downlit::highlight(
           glue::glue_collapse(x, sep = "\n"),
           classes = wordpress_classes(),
           pre_class = "wp-block-preformatted syntaxhighlighter  r")
        }
    }
  )
}


