# Publication-ready plotting ------------------------------------------------

#' Publication theme used by pcaLab
#' @param base_size Base font size.
#' @param base_family Font family; empty uses the graphics-device default.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
#'     ggplot2::geom_point() +
#'     pca_theme_publication(12)
#' }
#' @export
pca_theme_publication <- function(base_size=11,base_family="") {
  .pca_require("ggplot2","publication graphics")
  ggplot2::theme_classic(base_size=base_size,base_family=base_family)+
    ggplot2::theme(
      plot.title=ggplot2::element_text(face="bold",hjust=0),
      axis.title=ggplot2::element_text(face="plain"),
      legend.title=ggplot2::element_text(face="bold"),
      legend.key=ggplot2::element_blank(),
      strip.background=ggplot2::element_blank(),
      strip.text=ggplot2::element_text(face="bold"),
      panel.border=ggplot2::element_rect(fill=NA,linewidth=.4),
      plot.margin=ggplot2::margin(6,8,6,6)
    )
}

.pca_pc_label <- function(fit,j) {
  v <- fit$variance_explained[j]
  if (!is.finite(v)) paste0("PC",j) else paste0("PC",j," (",formatC(100*v,format="f",digits=1),"%)")
}

.pca_palette <- function(n) {
  base <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#F0E442", "#000000")
  if (n <= length(base)) base[seq_len(n)] else grDevices::hcl.colors(n, palette = "Dark 3")
}

#' Publication-ready PCA figures
#'
#' @param fit A `pca_fit` object.
#' @param type Figure type: scree, cumulative, scores, loadings, correlation_circle,
#'   contributions, cos2, biplot, diagnostics, bootstrap_loadings, eigen_ci, inference_axes, dimension_selection, trajectory, eigenfunctions, reconstruction, or scores3d.
#' @param dims Component indices used by two-dimensional figures.
#' @param component Component used by one-dimensional variable summaries.
#' @param group Optional supplementary group labels for score plots.
#' @param labels Label observations/variables where meaningful.
#' @param group_region Optional result from `pca_group()`.
#' @param bootstrap Optional result from `pca_boot()` for bootstrap-based plots.
#' @param selection Optional result from `pca_ncomp()` for dimensionality-selection plots.
#' @param inference Optional result from `pca_test()` for inferential plots.
#' @param base_size Publication-theme base font size.
#' @return A ggplot object.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#'   pca_plot(fit, type = "scree")
#'   pca_plot(fit, type = "scores", group = iris$Species)
#'   pca_plot(fit, type = "loadings", component = 1)
#'   pca_plot(fit, type = "correlation_circle")
#' }
#' @export
pca_plot <- function(fit,type=c("scree","cumulative","scores","loadings","correlation_circle",
                                "contributions","cos2","biplot","diagnostics","bootstrap_loadings","eigen_ci",
                                "inference_axes","dimension_selection","trajectory","eigenfunctions",
                                "reconstruction","scores3d"),dims=c(1,2),component=1L,group=NULL,labels=FALSE,
                     group_region=NULL,bootstrap=NULL,selection=NULL,inference=NULL,base_size=11) {
  stopifnot(inherits(fit,"pca_fit"));type<-match.arg(type)
  dims<-as.integer(dims);component<-as.integer(component)
  if (type == "scores3d") {
    .pca_require("plotly", "3D PCA score plots")
    if (length(dims) != 3L) dims <- c(1L,2L,3L)
    if (any(dims > fit$ncomp)) .pca_stop("scores3d needs three retained components.")
    d <- data.frame(x=fit$scores[,dims[1]], y=fit$scores[,dims[2]], z=fit$scores[,dims[3]],
                    observation=rownames(fit$scores) %||% paste0("Obs",seq_len(nrow(fit$scores))))
    if (!is.null(group)) { if(length(group)!=nrow(d)).pca_stop("group length mismatch."); d$group<-as.factor(group) }
    if (is.null(group)) {
      pp <- plotly::plot_ly(d,x=~x,y=~y,z=~z,type="scatter3d",mode="markers",text=~observation,marker=list(size=4))
      return(plotly::layout(pp,scene=list(xaxis=list(title=.pca_pc_label(fit,dims[1])),yaxis=list(title=.pca_pc_label(fit,dims[2])),zaxis=list(title=.pca_pc_label(fit,dims[3])))))
    }
    pp <- plotly::plot_ly(d,x=~x,y=~y,z=~z,type="scatter3d",mode="markers",text=~observation,symbol=~group,marker=list(size=4))
    return(plotly::layout(pp,scene=list(xaxis=list(title=.pca_pc_label(fit,dims[1])),yaxis=list(title=.pca_pc_label(fit,dims[2])),zaxis=list(title=.pca_pc_label(fit,dims[3])))))
  }
  .pca_require("ggplot2","pca_plot")
  theme<-pca_theme_publication(base_size)
  if(type=="scree") {
    d<-data.frame(PC=seq_along(fit$eigenvalues),eigenvalue=fit$eigenvalues,pve=fit$variance_explained)
    return(ggplot2::ggplot(d,ggplot2::aes(PC,eigenvalue))+ggplot2::geom_line(linewidth=.5)+
             ggplot2::geom_point(size=2)+ggplot2::scale_x_continuous(breaks=d$PC)+
             ggplot2::labs(x="Principal component",y="Eigenvalue",title="PCA eigenspectrum")+theme)
  }
  if(type=="cumulative") {
    if (!any(is.finite(fit$cumulative_variance)))
      .pca_stop("Cumulative explained variance is not defined for this engine. Use an engine-specific fit criterion instead.")
    d<-data.frame(PC=seq_along(fit$cumulative_variance),cum=fit$cumulative_variance)
    return(ggplot2::ggplot(d,ggplot2::aes(PC,cum))+ggplot2::geom_line(linewidth=.5)+ggplot2::geom_point(size=2)+
             ggplot2::scale_y_continuous(labels=function(x)paste0(round(100*x),"%"),limits=c(0,1))+
             ggplot2::scale_x_continuous(breaks=d$PC)+ggplot2::labs(x="Principal component",y="Cumulative explained variance")+theme)
  }
  if(type=="scores") {
    if(any(dims>fit$ncomp)||length(dims)!=2L) .pca_stop("scores plot needs two valid component indices.")
    d<-data.frame(x=fit$scores[,dims[1]],y=fit$scores[,dims[2]],observation=rownames(fit$scores))
    if(!is.null(group)){if(length(group)!=nrow(d)).pca_stop("group length mismatch.");d$group<-as.factor(group)}
    p<-ggplot2::ggplot(d,ggplot2::aes(x,y))
    if(is.null(group)) p<-p+ggplot2::geom_point(size=2,alpha=.85) else {
      pal <- .pca_palette(nlevels(d$group))
      p<-p+ggplot2::geom_point(ggplot2::aes(shape=group,color=group),size=2.4,alpha=.85)+
        ggplot2::scale_color_manual(values=pal)
    }
    if(isTRUE(labels)) p<-p+ggplot2::geom_text(ggplot2::aes(label=observation),check_overlap=TRUE,vjust=-.5,size=3)
    if(!is.null(group_region)&&!is.null(group_region$regions)) {
      rr <- group_region$regions; rr$group <- as.factor(rr$group)
      p<-p+ggplot2::geom_path(data=rr,ggplot2::aes(x,y,group=group,color=group),inherit.aes=FALSE,linewidth=.6)
      if (is.null(group)) p<-p+ggplot2::scale_color_manual(values=.pca_palette(nlevels(rr$group)))
    }
    p<-p+ggplot2::geom_hline(yintercept=0,linewidth=.3)+ggplot2::geom_vline(xintercept=0,linewidth=.3)+
      ggplot2::labs(x=.pca_pc_label(fit,dims[1]),y=.pca_pc_label(fit,dims[2]))
    if(!is.null(group)) p<-p+ggplot2::labs(shape="Group",color="Group")
    return(p+theme)
  }
  if(type=="loadings") {
    if(is.null(fit$loadings)).pca_stop("This engine has no ordinary variable loadings.")
    d<-data.frame(variable=rownames(fit$loadings),loading=fit$loadings[,component])
    d$variable<-factor(d$variable,levels=d$variable[order(d$loading)])
    return(ggplot2::ggplot(d,ggplot2::aes(variable,loading))+ggplot2::geom_hline(yintercept=0,linewidth=.3)+
             ggplot2::geom_segment(ggplot2::aes(xend=variable,y=0,yend=loading),linewidth=.5)+ggplot2::geom_point(size=2)+
             ggplot2::coord_flip()+ggplot2::labs(x=NULL,y=paste0("Loading on PC",component))+theme)
  }
  if(type=="correlation_circle") {
    C<-fit$correlation_loadings;if(is.null(C)).pca_stop("Correlation loadings are unavailable.")
    d<-data.frame(x=C[,dims[1]],y=C[,dims[2]],variable=rownames(C))
    th<-seq(0,2*pi,length.out=361);circ<-data.frame(x=cos(th),y=sin(th))
    p<-ggplot2::ggplot()+ggplot2::geom_path(data=circ,ggplot2::aes(x,y),linewidth=.4)+
      ggplot2::geom_segment(data=d,ggplot2::aes(x=0,y=0,xend=x,yend=y),arrow=grid::arrow(length=grid::unit(0.12,"inches")),linewidth=.45)+
      ggplot2::geom_text(data=d,ggplot2::aes(x,y,label=variable),size=3,vjust=-.35)+
      ggplot2::geom_hline(yintercept=0,linewidth=.3)+ggplot2::geom_vline(xintercept=0,linewidth=.3)+ggplot2::coord_equal(xlim=c(-1.1,1.1),ylim=c(-1.1,1.1))+
      ggplot2::labs(x=.pca_pc_label(fit,dims[1]),y=.pca_pc_label(fit,dims[2]))+theme
    return(p)
  }
  if(type%in%c("contributions","cos2")) {
    M<-if(type=="contributions")fit$contributions else fit$cos2;if(is.null(M)).pca_stop(type," values are unavailable.")
    d<-data.frame(variable=rownames(M),value=M[,component]);d$variable<-factor(d$variable,levels=d$variable[order(d$value)])
    p<-ggplot2::ggplot(d,ggplot2::aes(variable,value))+ggplot2::geom_col(width=.75)+ggplot2::coord_flip()+
      ggplot2::labs(x=NULL,y=if(type=="contributions")paste0("Contribution to PC",component)else paste0("cos^2 on PC",component))+theme
    if(type=="contributions")p<-p+ggplot2::geom_hline(yintercept=1/nrow(M),linetype=2,linewidth=.4)
    return(p)
  }
  if(type=="biplot") {
    if(is.null(fit$loadings)).pca_stop("Biplot requires explicit variable loadings.")
    sc<-data.frame(x=fit$scores[,dims[1]],y=fit$scores[,dims[2]])
    L<-fit$correlation_loadings;if(is.null(L))L<-fit$loadings
    ld<-data.frame(x=L[,dims[1]],y=L[,dims[2]],variable=rownames(L))
    sx<-max(abs(sc$x),na.rm=TRUE);sy<-max(abs(sc$y),na.rm=TRUE);lx<-max(abs(ld$x),na.rm=TRUE);ly<-max(abs(ld$y),na.rm=TRUE)
    mult<-min(sx/max(lx,.Machine$double.eps),sy/max(ly,.Machine$double.eps))*.8
    ld$x<-ld$x*mult;ld$y<-ld$y*mult
    return(ggplot2::ggplot(sc,ggplot2::aes(x,y))+ggplot2::geom_point(size=1.8,alpha=.65)+
             ggplot2::geom_segment(data=ld,ggplot2::aes(x=0,y=0,xend=x,yend=y),inherit.aes=FALSE,arrow=grid::arrow(length=grid::unit(.10,"inches")),linewidth=.45)+
             ggplot2::geom_text(data=ld,ggplot2::aes(x,y,label=variable),inherit.aes=FALSE,size=3,vjust=-.35)+
             ggplot2::geom_hline(yintercept=0,linewidth=.3)+ggplot2::geom_vline(xintercept=0,linewidth=.3)+
             ggplot2::labs(x=.pca_pc_label(fit,dims[1]),y=.pca_pc_label(fit,dims[2]))+theme)
  }
  if(type=="diagnostics") {
    d<-pca_diagnose(fit)
    return(ggplot2::ggplot(d,ggplot2::aes(score_distance,orthogonal_distance,shape=outlier_flag))+
             ggplot2::geom_point(size=2.2)+ggplot2::geom_vline(xintercept=unique(d$score_cutoff),linetype=2,linewidth=.4)+
             ggplot2::geom_hline(yintercept=unique(d$orthogonal_cutoff),linetype=2,linewidth=.4)+
             ggplot2::labs(x="Score distance",y="Orthogonal distance",shape="Flagged")+theme)
  }
  if(type=="bootstrap_loadings") {
    if (is.null(bootstrap)) bootstrap <- fit$bootstrap
    if(is.null(bootstrap)).pca_stop("Supply bootstrap = pca_boot(fit) for bootstrap_loadings.")
    ci<-bootstrap$loading_ci[,component,,drop=FALSE]
    d<-data.frame(variable=dimnames(ci)[[1]],estimate=fit$loadings[,component],lower=ci[,1,"lower"],upper=ci[,1,"upper"])
    d$variable<-factor(d$variable,levels=d$variable[order(d$estimate)])
    return(ggplot2::ggplot(d,ggplot2::aes(variable,estimate))+ggplot2::geom_hline(yintercept=0,linewidth=.3)+
             ggplot2::geom_errorbar(ggplot2::aes(ymin=lower,ymax=upper),width=.15)+ggplot2::geom_point(size=2)+ggplot2::coord_flip()+
             ggplot2::labs(x=NULL,y=paste0("Loading on PC",component," with bootstrap CI"))+theme)
  }
  if(type=="eigen_ci") {
    if (is.null(bootstrap)) bootstrap <- fit$bootstrap
    if (is.null(bootstrap)) .pca_stop("Supply bootstrap = pca_boot(fit) for eigen_ci.")
    ci <- bootstrap$eigenvalue_ci
    d <- data.frame(PC=seq_len(nrow(ci)),estimate=fit$eigenvalues[seq_len(nrow(ci))],lower=ci[,"lower"],upper=ci[,"upper"])
    return(ggplot2::ggplot(d,ggplot2::aes(PC,estimate))+ggplot2::geom_errorbar(ggplot2::aes(ymin=lower,ymax=upper),width=.15)+
      ggplot2::geom_point(size=2)+ggplot2::scale_x_continuous(breaks=d$PC)+ggplot2::labs(x="Principal component",y="Eigenvalue with bootstrap interval")+theme)
  }
  if(type=="inference_axes") {
    if (is.null(inference)) inference <- fit$inference
    if (is.null(inference)) .pca_stop("Supply inference = pca_test(fit) for inference_axes.")
    d <- inference$axes; d$index <- seq_len(nrow(d))
    return(ggplot2::ggplot(d,ggplot2::aes(index,-log10(p_value),shape=significant))+ggplot2::geom_point(size=2.5)+
      ggplot2::geom_hline(yintercept=-log10(inference$alpha),linetype=2,linewidth=.4)+
      ggplot2::scale_x_continuous(breaks=d$index,labels=d$component)+ggplot2::labs(x="Principal component",y=expression(-log[10](italic(p))),shape="Significant")+theme)
  }
  if(type=="dimension_selection") {
    if (is.null(selection)) selection <- fit$ncomp_selection
    if (is.null(selection)) .pca_stop("Supply selection = pca_ncomp(fit) for dimension_selection.")
    d <- selection$recommendations; d <- d[is.finite(d$suggested_k),,drop=FALSE]
    if (!nrow(d)) .pca_stop("No finite component-number recommendations are available.")
    d$method <- factor(d$method,levels=rev(d$method))
    return(ggplot2::ggplot(d,ggplot2::aes(suggested_k,method))+ggplot2::geom_point(size=2.6)+
      ggplot2::geom_vline(xintercept=selection$consensus,linetype=2,linewidth=.5)+
      ggplot2::scale_x_continuous(breaks=sort(unique(c(d$suggested_k,selection$consensus))))+
      ggplot2::labs(x="Suggested number of components",y=NULL,title="Dimensionality criteria",subtitle=paste0("Consensus k = ",selection$consensus))+theme)
  }
  if(type=="trajectory") {
    if(length(dims)!=2L||any(dims>fit$ncomp)) .pca_stop("trajectory requires two valid components.")
    d <- data.frame(index=seq_len(nrow(fit$scores)),x=fit$scores[,dims[1]],y=fit$scores[,dims[2]])
    if(!is.null(group)){if(length(group)!=nrow(d)).pca_stop("group length mismatch.");d$group<-as.factor(group)}
    p <- ggplot2::ggplot(d,ggplot2::aes(x,y))+ggplot2::geom_path(ggplot2::aes(group=1),linewidth=.45,alpha=.7)+ggplot2::geom_point(size=1.7)
    if(!is.null(group)) p <- ggplot2::ggplot(d,ggplot2::aes(x,y,color=group))+ggplot2::geom_path(ggplot2::aes(group=1),linewidth=.45,alpha=.6)+ggplot2::geom_point(size=1.8)+ggplot2::scale_color_manual(values=.pca_palette(nlevels(d$group)))
    return(p+ggplot2::labs(x=.pca_pc_label(fit,dims[1]),y=.pca_pc_label(fit,dims[2]),color="Group")+theme)
  }
  if(type=="eigenfunctions") {
    ef <- fit$extra$eigenfunctions
    if (is.null(ef)) .pca_stop("This fit does not expose functional eigenfunctions.")
    if (is.list(ef)) .pca_stop("Multivariate functional eigenfunctions are backend-specific; inspect fit$extra$eigenfunctions or the MFPCA backend object.")
    grid <- fit$extra$grid %||% seq_len(nrow(ef)); kk <- min(ncol(ef),fit$ncomp)
    d <- do.call(rbind,lapply(seq_len(kk),function(j)data.frame(grid=grid,value=ef[,j],component=paste0("PC",j))))
    return(ggplot2::ggplot(d,ggplot2::aes(grid,value,linetype=component))+ggplot2::geom_line(linewidth=.65)+
      ggplot2::labs(x="Functional domain",y="Eigenfunction",linetype="Component")+theme)
  }
  if(type=="reconstruction") {
    rec<-pca_reconstruct(fit,original_scale=FALSE);obs<-as.vector(fit$processed_data);pred<-as.vector(rec);ok<-is.finite(obs)&is.finite(pred)
    d<-data.frame(observed=obs[ok],reconstructed=pred[ok])
    return(ggplot2::ggplot(d,ggplot2::aes(observed,reconstructed))+ggplot2::geom_point(alpha=.35,size=1)+
             ggplot2::geom_abline(slope=1,intercept=0,linetype=2,linewidth=.5)+ggplot2::coord_equal()+
             ggplot2::labs(x="Observed processed value",y="PCA reconstruction")+theme)
  }
}

#' Export a publication-ready PCA figure
#' @param plot ggplot object.
#' @param filename Output file; extension determines format.
#' @param width Width in inches.
#' @param height Height in inches.
#' @param dpi Resolution for raster formats.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#'   f <- tempfile(fileext = ".png")
#'   pca_export_plot(pca_plot(fit, type = "scree"), f,
#'                   width = 5, height = 4, dpi = 150)
#'   file.exists(f)
#' }
#' @export
pca_export_plot <- function(plot,filename,width=7,height=5,dpi=600) {
  .pca_require("ggplot2","figure export")
  ggplot2::ggsave(filename=filename,plot=plot,width=width,height=height,dpi=dpi,units="in",bg="white")
  invisible(normalizePath(filename,mustWork=FALSE))
}
