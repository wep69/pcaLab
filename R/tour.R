# Projection tours ---------------------------------------------------------

#' Explore high-dimensional data with projection tours anchored to PCA
#'
#' @param fit A `pca_fit` object with explicit loadings.
#' @param type `"grand"`, `"guided"`, `"local"`, `"radial"`, or `"history"`.
#' @param dims Starting PCA dimensions, usually c(1,2).
#' @param group Optional point grouping for display.
#' @param angle Local-tour angular radius.
#' @param variable Variable index used by radial tour.
#' @param max_frames Maximum interactive frames.
#' @param save_history Return a saved basis history instead of animating.
#' @param gif_file Optional GIF destination; when supplied, render the saved tour history to a GIF.
#' @param ... Additional arguments passed to tourr animation/history functions.
#' @examples
#' if (requireNamespace("tourr", quietly = TRUE)) {
#'   fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 4)
#'   # headless-safe form: save projection histories instead of animating
#'   h <- pca_tour(fit, type = "grand", max_frames = 20, save_history = TRUE)
#'   length(h)
#'   h <- pca_tour(fit, type = "local", max_frames = 20, save_history = TRUE)
#'   length(h)
#'   \dontrun{
#'     pca_tour(fit, type = "guided")  # opens an interactive animation
#'   }
#' }
#' @export
pca_tour <- function(fit,type=c("grand","guided","local","radial","history"),dims=c(1,2),
                     group=NULL,angle=pi/8,variable=1L,max_frames=60L,save_history=FALSE,gif_file=NULL,...) {
  .pca_require("tourr","projection tours")
  stopifnot(inherits(fit,"pca_fit"));type<-match.arg(type)
  if(is.null(fit$loadings)).pca_stop("PCA-anchored tours require explicit loading vectors.")
  dims <- as.integer(dims)
  if (length(dims) != 2L || any(dims < 1L | dims > fit$ncomp)) .pca_stop("dims must identify two retained components.")
  X<-fit$processed_data;if(anyNA(X)).pca_stop("Touring requires a complete processed data matrix.")
  start<-fit$loadings[,dims,drop=FALSE]
  path<-switch(type,
    grand=tourr::grand_tour(d=2),
    guided=tourr::guided_tour(tourr::holes(),d=2),
    local=tourr::local_tour(start,angle=angle),
    radial=tourr::radial_tour(start,mvar=as.integer(variable)),
    history=tourr::grand_tour(d=2)
  )
  hist <- NULL
  if (isTRUE(save_history) || type=="history" || !is.null(gif_file)) {
    # tourr's local_tour()/radial_tour() generators supply the start basis
    # themselves on their first call. Passing start= explicitly makes that
    # first call return a bare matrix, which breaks save_history() in
    # tourr >= 1.2 ("$ operator is invalid for atomic vectors").
    start_arg <- if (type %in% c("local","radial")) NULL else start
    hist <- tourr::save_history(X,tour_path=path,start=start_arg,max_bases=max_frames,...)
  }
  if (!is.null(gif_file)) {
    if (!exists("render_gif", envir=asNamespace("tourr"), inherits=FALSE))
      .pca_stop("The installed tourr version does not export render_gif().")
    .pca_require("gifski", "GIF tour rendering")
    display <- tourr::display_xy(col = group %||% "black")
    tourr::render_gif(data = X, tour_path = tourr::planned_tour(hist), display = display,
                      gif_file = gif_file, frames = max_frames)
    return(invisible(normalizePath(gif_file,mustWork=FALSE)))
  }
  if(isTRUE(save_history)||type=="history") return(hist)
  start_arg <- if (type %in% c("local","radial")) NULL else start
  tourr::animate_xy(X,tour_path=path,start=start_arg,col=group,max_frames=max_frames,...)
}

#' Compare PCA view with local and guided tour histories
#' @param fit A `pca_fit` object.
#' @param dims PCA dimensions used as the reference projection.
#' @param max_bases Number of saved bases per tour.
#' @param angle Local-tour radius.
#' @examples
#' if (requireNamespace("tourr", quietly = TRUE)) {
#'   fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 4)
#'   tc <- pca_tour_compare(fit, max_bases = 10)
#'   length(tc$local)
#'   length(tc$grand)
#' }
#' @export
pca_tour_compare <- function(fit,dims=c(1,2),max_bases=50L,angle=pi/8) {
  .pca_require("tourr","tour comparison")
  stopifnot(inherits(fit,"pca_fit"))
  if (is.null(fit$loadings)) .pca_stop("PCA-anchored tours require explicit loading vectors.")
  dims <- as.integer(dims)
  if (length(dims) != 2L || any(dims < 1L | dims > fit$ncomp)) .pca_stop("dims must identify two retained components.")
  X<-fit$processed_data
  if (anyNA(X)) .pca_stop("Touring requires a complete processed data matrix.")
  start<-fit$loadings[,dims,drop=FALSE]
  local<-tourr::save_history(X,tourr::local_tour(start,angle=angle),start=NULL,max_bases=max_bases)
  guided<-tourr::save_history(X,tourr::guided_tour(tourr::holes(),d=2),start=start,max_bases=max_bases)
  grand<-tourr::save_history(X,tourr::grand_tour(d=2),start=start,max_bases=max_bases)
  list(pca_basis=start,local=local,guided=guided,grand=grand,
       note="Local tours assess projection robustness; guided/grand tours search for structure that variance-maximizing PCA may not emphasize.")
}
