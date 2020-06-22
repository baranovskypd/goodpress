# from https://github.com/r-lib/desc/blob/da1950108695edd9edd9ac795ecaceb511d845fa/R/utils.R#L2
`%||%` <- function(l, r) if (is.null(l)) r else l
