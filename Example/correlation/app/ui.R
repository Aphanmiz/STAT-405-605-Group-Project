shinyUI(bootstrapPage(

    sidebarPanel(
        sliderInput(inputId = "n",
                    label = "Sample size:",
                    min = 2, max = 1078, value = 100, step = 1),
        
        sliderInput(inputId = "rho",
                    label = "Population Correlation Coefficient:",
                    min = -1, max = 1, value = 0.5, step = 0.01),

        sliderInput(inputId = "SDx",
                    label = "X Population Standard Deviation:",
                    min = 0, max = 10, value = 1, step = 0.01),
        
        sliderInput(inputId = "SDy",
                    label = "Y Population Standard Deviation:",
                    min = 0, max = 10, value = 1, step = 0.01),
        
        actionButton("refreshButton", "Refresh")
        ),
    mainPanel(
        plotOutput(outputId = "main_plot", height = "600px", width = "600px")
        )
    ))

