# Setup.

# Function for extracting plotting info from string of labels.
{
  library(stringr)
  library(stringi)
  draw_tree <- function(input_string, # String of labels. (See: "labels" field of xgb_trees_data.csv)
                        x=100, y=100, # Coordinates of root vertex.
                        height=500, width=500, # How (physically) big the tree should be.
                        tree.depth=3, # How deep did we specify trees to be when we trained xgb?
                        plot_tree=FALSE, # Do you want to visualize the tree using base plots?
                        font_size=0.5 # Label font size.
                        ){
    # DESCRIPTION:
      # This function takes in a string of labels separated by commons, for example:
            # "wind < 28.2999992, numCrashes < 877.5, wind < 28.6350002, snow < 5.30000019, precip < 0.0799999982, Leaf, wind < 29.6349983, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf"
      # and calculates all the information needed to turn those labels into a binary tree.
      # using grid. Also visualizes the tree if plot_tree==TRUE.
    
    # Outputs:
      # Coordinates of vertices
      # Corresponding text labels
      # Start and endpoint vertices of segments
    
    require(stringi)
    require(stringr)
    labels.raw <- strsplit(input_string, ", ")[[1]]
    
    # First, calculate possible vertex locations based on plotting parameters.
    {
      x.vertices <- c()
      y.vertices <- c()
      vstep <- height/tree.depth
      
      for (depth.ticker in 0:tree.depth) {
        num.vertices.in.row <- 2^(depth.ticker)
        hstep <- width/(num.vertices.in.row+1)
        for (width.ticker in 1:num.vertices.in.row) {
          x.vertices <- append(x.vertices, x+(width.ticker)*hstep)
          y.vertices <- append(y.vertices, y+(depth.ticker)*vstep)
        }
      }
      x.vertices <- x.vertices - width/2
    }
    
    # Next, assign labels and prune vertices that don't exist.
    {
      num.vertices <- length(x.vertices)
      labels.fixed <- rep("HOLDER", times=num.vertices)
      labels.fixed[1] <- labels.raw[1]
      label.tracker <- 2
      for (j in 2:num.vertices) {
        parent <- floor(j/2)
        if (labels.fixed[parent]=="Leaf" | labels.fixed[parent]=="PASS") {
          labels.fixed[j] <- "PASS"
        } else {
          labels.fixed[j] <- labels.raw[label.tracker]
          label.tracker <- label.tracker+1
        }
      }
    }
    
    # Calculate where edges need to be.
    {
      segments.start.x <- c()
      segments.start.y <- c()
      segments.end.x <- c()
      segments.end.y <- c()
      
      for (j in 2:num.vertices){
        parent <- floor(j/2)
        if (!(labels.fixed[parent]=="Leaf" | labels.fixed[parent]=="PASS")) {
          segments.start.x <- append(segments.start.x, x.vertices[parent])
          segments.start.y <- append(segments.start.y, y.vertices[parent])
          segments.end.x <- append(segments.end.x, x.vertices[j])
          segments.end.y <- append(segments.end.y, y.vertices[j])
        }
      }
    }
    
    # Only keep plotted vertices and format labels.
    {
      x.vertices.plot <- x.vertices[labels.fixed!="PASS"]
      y.vertices.plot <- y.vertices[labels.fixed!="PASS"]
      labels.plot <- c()
      for (label in labels.raw) {
        if (label=="Leaf") {
          labels.plot <- append(labels.plot, " ")
        } else {
          labels.plot <- append(labels.plot, str_replace(label, "<", "\n<"))
        }
      }
    }
    
    # If plot_tree=TRUE, then make a plot.
    {
        if (plot_tree) {
        plot(x.vertices.plot, y.vertices.plot)
        text(x.vertices.plot, y.vertices.plot, labels.plot, cex=font_size)
        segments(segments.start.x,
                 segments.start.y,
                 segments.end.x,
                 segments.end.y
                 )
      }
    }
    
    # Clean up and end :3
    {
      rm(hstep)
      rm(vstep)
      rm(label.tracker)
      rm(labels.fixed)
      rm(num.vertices)
      rm(parent)
      rm(width.ticker)
      rm(x.vertices)
      rm(y.vertices)
      rm(x)
      rm(y)
      rm(tree.depth)
      rm(height)
      rm(width)
      
      result <- list(x.vertices.coords=x.vertices.plot,
                     y.vertices.coords=y.vertices.plot,
                     segments.start.x=segments.start.x,
                     segments.start.y=segments.start.y,
                     segments.end.x=segments.end.x,
                     segments.end.y=segments.end.y,
                     labels=labels.plot)
    }
    
    return(result)
  }
}
library(grid)
## heatmap y: iterations, eta: x axis

## Define x and y coords and string input for Patrick's function for
## trees we want to plot
## currently filled in with examples
tree_x <- c(0.1,0.6,0.9)
tree_y <- c(3,10,12)
tree_string <- c("numCrashes < 387.5, propMentions < 0.0226573199, numCrashes < 604.5, Leaf, numCrashes < 245.5, propMentions < 0.0206043962, numCrashes < 681.5, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf",
               "wind < 21.5849991, wind < 21.1399994, numCrashes < 554, snow < 5.30000019, numCrashes < 514.5, precip < 0.120000005, precip < 0.554999948, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf",
               "precip < 1.22500002, precip < 1.17499995, wind < 6.5999999, snow < 1.25, wind < 7.15500021, numCrashes < 673, precip < 1.255, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf, Leaf")

## Round everything to 3 decimals to avoid overlap of labels
tree_string <- str_replace_all(tree_string, "\\b\\d+\\.\\d+\\b", function(x) as.character(round(as.numeric(x), 3)))


## Viewport setup
grid.newpage()
## x axis 0 to 1
## y axis 1 to 20
vp <- viewport(x = 0.5, y = 0.5,
              height = 0.8, width = 0.8,
              xscale = c(0, 1), yscale = c(1, 20))

#grid.show.viewport(vp)
pushViewport(vp)
grid.rect()

## 0.05 increments for x
grid.xaxis(at=seq(from=0,to=1,by=0.05))
## 1 increments for y
grid.yaxis(at=seq(from=1,to=20,by=1))

## Given vectors of x coords, y coords, and string input for Patrick's function,
## plot each tree
for (i in seq(1,length(tree_x))) {
  res <- draw_tree(tree_string[i],x=tree_x[i],y=tree_y[i],height=2.5,width=0.3,plot_tree=FALSE)
  grid.segments(x0 = unit(res$segments.start.x, "native"), y0 = unit(res$segments.start.y, "native"),
               x1 = unit(res$segments.end.x, "native"), y1 = unit(res$segments.end.y, "native"),
               arrow = NULL,
               name = NULL, gp = gpar(col="gray"), draw = TRUE)
  grid.points(x=unit(res$x.vertices.coords,"native"),
              y=unit(res$y.vertices.coords,"native"),pch=21,
              size=unit(0.01,"npc"),gp=gpar(col="gray",fill="white"))
  text <- textGrob(res$labels,x=unit(res$x.vertices.coords,"native"),
            y=unit(res$y.vertices.coords,"native"),
            gp=gpar(fontsize=3,col="black"))
  grid.draw(text)
}



## De-activate viewport
popViewport()

