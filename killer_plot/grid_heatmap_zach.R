# calling the csv data that Patrick made
tree <- read.csv('xgb_trees_data.csv')

# making a new data set from Patrick's data such that eta is the columns and 
# number of iterations is the rows. Each cell gives the accuracy level for the
# the corresponding eta value and number of iteration
holder = matrix(rep(0, times=420), nrow=21)
for (j in 1:420) {
  holder[(20*tree$eta)[j]+1, tree$N[j]] = tree$MAD[j]
}
df <- t(holder)

# renaming the columns to match values of eta
colnames(df) <- seq(0, 1, 0.05)

# replacing each accuracy value with a corresponding hexadecimal color
# better accuracy values (lower MAD) will have a "more red" hexadecimal color
lst <- as.vector(as.matrix(df))
lst <- sort(lst)
colors <- colorRampPalette(c("red", "white"))(nrow(df) * ncol(df))
new <- matrix(rep('', 420), nrow = nrow(df))
for (k in 1:length(lst)) {
  for (i in 1:nrow(df)) {
    for (j in 1:ncol(df)) {
      if (lst[k] == df[i, j])
        new[i, j] <- colors[k]
    }
  }
}
# Generating the heat map using cird library
grid.newpage()
vp <- plotViewport(margins = c(5.1, 4.1, 4.1, 2.1))
pushViewport(vp)
grid.raster(new)
