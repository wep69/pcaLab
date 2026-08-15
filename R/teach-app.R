# Interactive teaching application -----------------------------------------

#' Launch the interactive PCA teaching laboratory
#'
#' The application connects geometric rotation, projected variance,
#' eigenvalues/eigenvectors, scores, loadings, dimensionality selection, and
#' low-rank reconstruction. It uses only synthetic demonstration data and is
#' intended for teaching rather than inferential analysis.
#'
#' @param launch.browser Passed to `shiny::runApp()`.
#' @param ... Additional arguments passed to `shiny::runApp()`.
#' @examples
#' \dontrun{
#'   pca_teach_app(launch.browser = FALSE)
#' }
#' @export
pca_teach_app <- function(launch.browser = TRUE, ...) {
  .pca_require("shiny", "interactive PCA teaching laboratory")
  app <- system.file("shiny", "pca_teach", package = "pcaLab")
  if (!nzchar(app)) .pca_stop("The teaching application was not installed with the package.")
  shiny::runApp(app, launch.browser = launch.browser, ...)
}
