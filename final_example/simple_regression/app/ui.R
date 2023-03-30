shinyUI(bootstrapPage(

    sidebarPanel(
        sliderInput(inputId = "n",
                    label = "Sample size:",
                    min = 2, max = 5000, value = 50, step = 1),
        
        sliderInput(inputId = "meanx",
                    label = "meanx:",
                    min = -3, max = 3, value = 0, step = .1),

        sliderInput(inputId = "SDx",
                    label = "SDx:",
                    min = .01, max = 3, value = 1, step = .01),
        
        sliderInput(inputId = "meany",
                    label = "meany:",
                    min = -3, max = 3, value = 0, step = .1),

        sliderInput(inputId = "SDy",
                    label = "SDy:",
                    min = .01, max = 3, value = 1, step = .01),

        sliderInput(inputId = "rho",
                    label = "rho:",
                    min = -1, max = 1, value = 0.5, step = .01),
        
        checkboxInput(inputId = "show_population",
                      label = "Show Population lines", value = FALSE),
        
        textInput("seed",
                  label = "Seed", value = 19761111),

        checkboxInput(inputId = "show_point_of_averages",
                      label = "Show point of averages", value = FALSE),

        checkboxInput(inputId = "show_SD_line",
                      label = "Show SD line", value = FALSE),

        checkboxInput(inputId = "show_graph_avg",
                      label = "Show graph of averages", value = FALSE),

        checkboxInput(inputId = "show_SDs",
                      label = "Show SDs", value = FALSE),

        checkboxInput(inputId = "show_reg_line",
                      label = "Show regression line", value = FALSE),
        
        checkboxInput(inputId = "show_vertical_strip",
                      label = "Show vertical strip", value = FALSE),

        sliderInput(inputId = "xcenter",
                    label = "Center of vertical strip:",
                    min = -6, max = 6, value = 1, step = .1),
        
        selectInput(inputId = "points_relative_to",
                    label = "Points relative to",
                    choices=c("SD line", "Regression line")),
        
        checkboxInput(inputId = "show_other_graph_avg",
                      label = "Show other graph of averages", value = FALSE),

        checkboxInput(inputId = "show_other_reg_line",
                      label = "Show other regression line", value = FALSE),

        checkboxInput(inputId = "show_gray_points",
                      label = "Show gray points", value = FALSE),
        
        checkboxInput(inputId = "show_points",
                      label = "Show points", value = TRUE),
        
        sliderInput(inputId = "limits",
                    label = "Limits:",
                    min = 1, max = 15, value = 6, step = 1)
    ),
    mainPanel(
        plotOutput(outputId = "main_plot", height = "600px")
        )
    ))

