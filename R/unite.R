#' Unite multiple columns into one.
#'
#' Convenience function to paste together multiple columns into one.
#'
#' @inheritSection gather Rules for selection
#' @inheritParams gather
#' @param data A data frame.
#' @param col The name of the new column, as a string or symbol.
#'
#'   This argument is passed by expression and supports
#'   [quasiquotation][rlang::quasiquotation] (you can unquote strings
#'   and symbols). The name is captured from the expression with
#'   [rlang::quo_name()] (note that this kind of interface where
#'   symbols do not represent actual objects is now discouraged in the
#'   tidyverse; we support it here for backward compatibility).
#' @param sep Separator to use between values.
#' @param remove If `TRUE`, remove input columns from output data frame.
#' @seealso [separate()], the complement.
#' @export
#' @examples
#' library(dplyr)
#' unite_(mtcars, "vs_am", c("vs","am"))
#'
#' # Separate is the complement of unite
#' mtcars %>%
#'   unite(vs_am, vs, am) %>%
#'   separate(vs_am, c("vs", "am"))
unite <- function(data, col, ..., sep = "_", remove = TRUE) {
  UseMethod("unite")
}
#' @export
unite.data.frame <- function(data, col, ..., sep = "_", remove = TRUE) {
  var <- quo_name(enquo(col))

  if (dots_n(...) == 0) {
    from_vars <- colnames(data)
  } else {
    from_vars <- tidyselect::vars_select(colnames(data), ...)
  }

  out <- data
  if (remove) {
    out <- out[setdiff(names(out), from_vars)]
  }

  first_pos <- which(names(data) %in% from_vars)[1]
  united <- invoke(paste, c(data[from_vars], list(sep = sep)))

  out <- append_col(out, united, var, after = first_pos - 1L)
  reconstruct_tibble(data, out, if (remove) from_vars)
}
