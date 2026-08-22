# Tables and reproducible reporting ----------------------------------------

#' Create publication-ready PCA tables
#'
#' @param fit A `pca_fit` object.
#' @param type `"eigenvalues"`, `"loadings"`, `"scores"`, `"variables"`,
#'   `"diagnostics"`, `"preprocessing"`, `"ncomp"`, `"inference_global"`,
#'   `"inference_axes"`, `"bootstrap_eigenvalues"`, or `"associations"`.
#' @param component Optional component for variable summaries.
#' @param selection Optional result from `pca_ncomp()` used by `type = "ncomp"`.
#' @param inference Optional result from `pca_test()`.
#' @param bootstrap Optional result from `pca_boot()`.
#' @param association Optional result from `pca_associate()`.
#' @param format `"data.frame"` or `"gt"`.
#' @return A data frame or gt table.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' pca_table(fit, type = "eigenvalues")
#' pca_table(fit, type = "variables", component = 1)
#' @export
pca_table <- function(fit,type=c("eigenvalues","loadings","scores","variables","diagnostics","preprocessing","ncomp",
                                      "inference_global","inference_axes","bootstrap_eigenvalues","associations"),
                      component=1L,selection=NULL,inference=NULL,bootstrap=NULL,association=NULL,
                      format=c("data.frame","gt")) {
  stopifnot(inherits(fit,"pca_fit"));type<-match.arg(type);format<-match.arg(format)
  tab<-switch(type,
    eigenvalues=data.frame(component=.pca_component_names(fit$ncomp),eigenvalue=fit$eigenvalues,
                           explained_variance=fit$variance_explained,cumulative_variance=fit$cumulative_variance),
    loadings={if(is.null(fit$loadings)).pca_stop("No loadings available.");data.frame(variable=rownames(fit$loadings),fit$loadings,check.names=FALSE)},
    scores=data.frame(observation=rownames(fit$scores)%||%paste0("Obs",seq_len(nrow(fit$scores))),fit$scores,check.names=FALSE),
    variables={
      if(is.null(fit$loadings)).pca_stop("No variable metrics available.")
      data.frame(variable=rownames(fit$loadings),loading=fit$loadings[,component],
                 correlation=if(is.null(fit$correlation_loadings))NA_real_ else fit$correlation_loadings[,component],
                 cos2=if(is.null(fit$cos2))NA_real_ else fit$cos2[,component],
                 contribution=if(is.null(fit$contributions))NA_real_ else fit$contributions[,component])
    },
    diagnostics=pca_diagnose(fit),
    preprocessing=fit$preprocessing$audit,
    ncomp={if(is.null(selection)) selection<-fit$ncomp_selection; if(is.null(selection)).pca_stop("Supply selection = pca_ncomp(fit).");selection$recommendations},
    inference_global={if(is.null(inference))inference<-fit$inference;if(is.null(inference)).pca_stop("Supply inference = pca_test(fit).");inference$global},
    inference_axes={if(is.null(inference))inference<-fit$inference;if(is.null(inference)).pca_stop("Supply inference = pca_test(fit).");inference$axes},
    bootstrap_eigenvalues={if(is.null(bootstrap))bootstrap<-fit$bootstrap;if(is.null(bootstrap)).pca_stop("Supply bootstrap = pca_boot(fit).");
      data.frame(component=rownames(bootstrap$eigenvalue_ci) %||% .pca_component_names(nrow(bootstrap$eigenvalue_ci)), bootstrap$eigenvalue_ci, check.names=FALSE)},
    associations={if(is.null(association))association<-pca_associate(fit,test=inference,boot=bootstrap);association}
  )
  if(format=="gt") {
    .pca_require("gt","gt tables")
    return(gt::gt(tab))
  }
  tab
}

.pca_md_table <- function(d,digits=4) {
  if(is.null(d)||!nrow(d)) return("_No rows._\n")
  dd<-d
  for(j in seq_along(dd)) if(is.numeric(dd[[j]])) dd[[j]]<-formatC(dd[[j]],digits=digits,format="fg",flag="#")
  head<-paste0("| ",paste(names(dd),collapse=" | ")," |\n")
  sep<-paste0("| ",paste(rep("---",ncol(dd)),collapse=" | ")," |\n")
  rows<-apply(dd,1,function(z)paste0("| ",paste(z,collapse=" | ")," |"))
  paste0(head,sep,paste(rows,collapse="\n"),"\n")
}

#' Generate a reproducible PCA report
#'
#' @param fit A `pca_fit` object.
#' @param file Optional output path. Markdown is always supported; `.html` requires rmarkdown.
#' @param include_diagnostics Include diagnostic table.
#' @param inference Optional result from `pca_test()`.
#' @param selection Optional result from `pca_ncomp()`.
#' @param bootstrap Optional result from `pca_boot()`.
#' @param include_variable_table Include a variable summary for the first component.
#' @return Markdown text invisibly, and optionally a written/rendered file.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' f <- tempfile(fileext = ".md")
#' pca_report(fit, f)
#' writeLines(head(readLines(f), 6))
#' @export
pca_report <- function(fit,file=NULL,include_diagnostics=TRUE,include_variable_table=TRUE,
                       inference=NULL,selection=NULL,bootstrap=NULL) {
  stopifnot(inherits(fit,"pca_fit"))
  ev<-pca_table(fit,"eigenvalues")
  variance_valid <- isTRUE(fit$extra$variance_partition_valid)
  spectrum_heading <- if (variance_valid) "## Component spectrum and explained variance" else "## Latent component scale summary"
  spectrum_note <- if (variance_valid) {
    "The explained-variance columns refer to the variance/inertia partition defined by this engine."
  } else {
    "This engine does not define an ordinary PCA variance partition. Score-variance/eigenvalue-like fields are retained only as descriptive component-scale quantities; explained-variance columns are therefore undefined."
  }
  txt<-c(
    "# Principal Component Analysis Report",
    "",
    paste0("**Method:** `",fit$method,"`  "),
    paste0("**Engine:** `",fit$engine,"`  "),
    paste0("**Observations:** ",nrow(fit$processed_data),"  "),
    paste0("**Variables:** ",ncol(fit$processed_data),"  "),
    paste0("**Retained components:** ",fit$ncomp,"  "),
    paste0("**Centering:** ",if(isTRUE(fit$preprocessing$center))"yes" else "no","  "),
    paste0("**Scaling:** ",fit$preprocessing$scale_method %||% "none"),
    "",
    spectrum_heading, "", spectrum_note, "", .pca_md_table(ev), ""
  )
  if(include_variable_table&&!is.null(fit$loadings)) txt<-c(txt,"## Variable interpretation for PC1","",.pca_md_table(pca_table(fit,"variables",component=1)),"")
  if(include_diagnostics&&nrow(fit$scores)) txt<-c(txt,"## Observation diagnostics","",.pca_md_table(pca_diagnose(fit)),"")
  if(is.null(inference)) inference<-fit$inference
  if(!is.null(inference)) {
    txt<-c(txt,"## Permutation inference","",
      paste0("Global Psi Monte Carlo p-value: ", formatC(inference$global$p_value[inference$global$statistic == "Psi"][1], digits=4, format="fg")),
      paste0("Global Phi Monte Carlo p-value: ", formatC(inference$global$p_value[inference$global$statistic == "Phi"][1], digits=4, format="fg")),
      "",.pca_md_table(inference$axes),"")
  }
  if(!is.null(selection)) txt<-c(txt,"## Component-number selection","",.pca_md_table(selection$recommendations),
                                 paste0("Consensus k: ",selection$consensus),"")
  if(!is.null(bootstrap)) txt<-c(txt,"## Bootstrap uncertainty","",
                                 paste0("Bootstrap resamples: ",bootstrap$nboot,"; confidence level: ",bootstrap$conf),
                                 "",.pca_md_table(data.frame(component=rownames(bootstrap$eigenvalue_ci) %||% .pca_component_names(nrow(bootstrap$eigenvalue_ci)),bootstrap$eigenvalue_ci,check.names=FALSE)),"")
  safeguard <- if (fit$method %in% c("classical", "weighted", "nipals", "em", "ppca", "bayesian", "robust", "cellwise", "sparse", "robust_sparse", "rpca", "shrinkage", "randomized", "compositional", "functional", "dynamic", "multilevel", "multiblock")) {
    "For ordinary linear PCA geometry, components are variance/inertia-oriented linear combinations. Uncorrelated component scores are not necessarily statistically independent. The sign of each loading vector is arbitrary. Near-equal eigenvalues can make individual loading vectors unstable even when their joint subspace is stable."
  } else {
    "This fit uses a nonlinear or generalized latent-component geometry. Do not transfer ordinary covariance-PCA eigenvalue, variance-explained, orthogonality, or reconstruction interpretations unless the engine explicitly defines them."
  }
  txt<-c(txt,"## Interpretation safeguards","", safeguard,
         "Group labels, when shown, are supplementary and were not used to estimate an unsupervised fit unless explicitly stated otherwise.","")
  md<-paste(txt,collapse="\n")
  if(!is.null(file)) {
    ext<-tolower(tools::file_ext(file))
    if(ext=="html") {
      .pca_require("rmarkdown","HTML report rendering")
      tmp<-tempfile(fileext=".md");writeLines(md,tmp,useBytes=TRUE)
      rmarkdown::render(tmp,output_format="html_document",output_file=basename(file),output_dir=dirname(file),quiet=TRUE)
    } else writeLines(md,file,useBytes=TRUE)
  }
  invisible(md)
}


#' Export a PCA table
#'
#' @param table A data frame, or an object returned by `pca_table(..., format="data.frame")`.
#' @param filename Destination. Supported extensions are csv, tsv, md, tex, xlsx, html, and docx.
#' @param digits Numeric display precision for text formats.
#' @return The output path invisibly.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' f <- tempfile(fileext = ".csv")
#' pca_export_table(pca_table(fit, type = "eigenvalues"), f)
#' utils::read.csv(f)
#' @export
pca_export_table <- function(table, filename, digits = 4L) {
  d <- as.data.frame(table)
  ext <- tolower(tools::file_ext(filename))
  if (!nzchar(ext)) .pca_stop("filename must have a supported extension.")
  if (ext == "csv") utils::write.csv(d, filename, row.names = FALSE)
  else if (ext == "tsv") utils::write.table(d, filename, sep = "\t", row.names = FALSE, quote = FALSE)
  else if (ext == "md") writeLines(.pca_md_table(d, digits = digits), filename, useBytes = TRUE)
  else if (ext == "tex") {
    esc <- function(x) gsub("([_%&#$])", "\\\\\\1", as.character(x), perl = TRUE)
    dd <- d
    for (j in seq_along(dd)) {
      if (is.numeric(dd[[j]])) dd[[j]] <- formatC(dd[[j]], digits = digits, format = "fg")
      dd[[j]] <- esc(dd[[j]])
    }
    align <- paste(rep("l", ncol(dd)), collapse = "")
    lines <- c(paste0("\\begin{tabular}{", align, "}"), "\\hline",
               paste(esc(names(dd)), collapse = " & "), "\\\\", "\\hline")
    if (nrow(dd)) for (i in seq_len(nrow(dd))) lines <- c(lines, paste(dd[i, ], collapse = " & "), "\\\\")
    lines <- c(lines, "\\hline", "\\end{tabular}")
    writeLines(lines, filename, useBytes = TRUE)
  } else if (ext == "xlsx") {
    .pca_require("openxlsx", "XLSX table export")
    openxlsx::write.xlsx(d, filename, rowNames = FALSE, overwrite = TRUE)
  } else if (ext == "html") {
    .pca_require("gt", "HTML table export")
    gt::gtsave(gt::gt(d), filename)
  } else if (ext == "docx") {
    .pca_require("officer", "DOCX table export")
    .pca_require("flextable", "DOCX table export")
    ft <- flextable::autofit(flextable::flextable(d))
    doc <- officer::read_docx()
    doc <- officer::body_add_par(doc, "pcaLab table", style = "heading 1")
    doc <- flextable::body_add_flextable(doc, value = ft)
    print(doc, target = filename)
  } else .pca_stop("Unsupported table extension: ", ext)
  invisible(normalizePath(filename, mustWork = FALSE))
}
