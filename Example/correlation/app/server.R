shinyServer(function(input, output) {

  output$main_plot <- renderPlot({
    
    input$refreshButton
    
    diffr <- function(n, rho, SDx = 1, SDy = 1) {
      meanx <- 3; meany <- 3
      
      x1 <- rnorm(n = n)
      x2 <- rnorm(n = n)
      x3 <- rho*x1 + sqrt(1-rho^2)*x2
      
      x <- meanx + SDx*x1
      y <- meany + SDy*x3
      
      r <- round(cor(x, y), 3)
      
      par(mai = c(.2, .2, .2, .2), mgp = c(1.5, 0.2, 0), tck = -.01, mfrow = c(1,1))
      plot(x, y, xlim = c(0,6), ylim = c(0,6),
           xaxs = "i", yaxs = "i", main = paste("rho =", rho, "; r = ", r))
    }

    set.seed(123)
    diffr(rho = input$rho, n = input$n, SDx = input$SDx, SDy = input$SDy)
  })
})
