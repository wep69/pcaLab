library(shiny)
library(pcaLab)

ui <- fluidPage(
  titlePanel("pcaLab Interactive Teaching Laboratory"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("angle", "Projection angle (degrees)", min = 0, max = 180, value = 45, step = 1),
      checkboxInput("standardize", "Standardize variables", FALSE),
      sliderInput("k", "Components used for reconstruction", min = 1, max = 2, value = 1, step = 1),
      helpText("Move the angle to see how projection variance changes. PCA chooses the direction that maximizes projected variance under a unit-length constraint.")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Rotation and variance", plotOutput("rotation"), verbatimTextOutput("rotation_text")),
        tabPanel("Eigenvalues and eigenvectors", tableOutput("eig"), verbatimTextOutput("eig_text")),
        tabPanel("Scores and loadings", plotOutput("scores"), tableOutput("load")),
        tabPanel("Reconstruction", plotOutput("reconstruction"), verbatimTextOutput("rec_text"))
      )
    )
  )
)

server <- function(input, output, session) {
  dat <- reactive({
    X <- matrix(c(1,.5, 2,4, 4,3.5, 5,5.2, 3,2.8, 2.2,1.7, 4.7,4.2), byrow=TRUE, ncol=2)
    colnames(X) <- c("X1","X2")
    X
  })
  prep <- reactive(pca_preprocess(dat(), center=TRUE, scale=input$standardize, na_action="fail"))
  fit <- reactive(pca_fit(dat(), method="classical", center=TRUE, scale=input$standardize, ncomp=2))

  output$rotation <- renderPlot({
    Z <- prep()$data
    th <- input$angle*pi/180
    v <- c(cos(th),sin(th)); sc <- as.vector(Z %*% v)
    plot(Z[,1],Z[,2],asp=1,pch=19,xlab="Variable 1",ylab="Variable 2",main="Projection direction")
    abline(a=0,b=tan(th),lwd=2)
    arrows(0,0,v[1]*max(abs(Z)),v[2]*max(abs(Z)),length=.1,lwd=2)
    mtext(sprintf("Projected variance = %.3f", var(sc)),side=3)
  })
  output$rotation_text <- renderText({
    tv <- pca_teach_variance(dat())
    i <- which.min(abs(tv$data$angle-input$angle))
    paste0("At ",input$angle," degrees, projected variance is approximately ",
           round(tv$data$projected_variance[i],4),".\n\nCore optimization:\nmaximize v' S v subject to v'v = 1.\nThe solution satisfies S v = lambda v.")
  })
  output$eig <- renderTable({
    e <- pca_teach_eigen(dat(),scale=input$standardize)$data
    data.frame(Component=paste0("PC",seq_along(e$eigenvalues)),Eigenvalue=e$eigenvalues,
               Explained=e$eigenvalues/sum(e$eigenvalues),check.names=FALSE)
  },digits=4)
  output$eig_text <- renderText({
    "Eigenvectors are directions that remain collinear after multiplication by the covariance/correlation matrix. In PCA they define loading axes; the associated eigenvalues equal component variances. Eigenvector signs are arbitrary, and near-equal eigenvalues can make individual axes unstable even when their joint subspace is stable."
  })
  output$scores <- renderPlot({
    f <- fit(); plot(f$scores[,1],f$scores[,2],pch=19,xlab="PC1 score",ylab="PC2 score",asp=1)
    abline(h=0,v=0,lty=2)
  })
  output$load <- renderTable({
    f <- fit(); data.frame(Variable=rownames(f$loadings),f$loadings,check.names=FALSE)
  },digits=4)
  output$reconstruction <- renderPlot({
    f <- fit(); R <- pca_reconstruct(f,ncomp=input$k,original_scale=FALSE); Z<-f$processed_data
    plot(Z[,1],Z[,2],pch=19,xlab="Processed variable 1",ylab="Processed variable 2",asp=1)
    points(R[,1],R[,2],pch=1,cex=1.3)
    segments(Z[,1],Z[,2],R[,1],R[,2],lty=2)
  })
  output$rec_text <- renderText({
    f <- fit(); R <- pca_reconstruct(f,ncomp=input$k,original_scale=FALSE)
    sprintf("Rank-%d reconstruction RMSE: %.4f. Filled points are original processed observations; open circles are reconstructed values.",
            input$k,sqrt(mean((f$processed_data-R)^2)))
  })
}

shinyApp(ui, server)
