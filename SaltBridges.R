#####################
## Customization
#####################

transparent <- function(color) {
  rgb.val <- col2rgb(color)
  new_col <- rgb(rgb.val[1]/255, rgb.val[2]/255, rgb.val[3]/255, alpha = 0.2)
  return(new_col)
}

minimum_percentage     <- 60     # Ratio of acceptable coverage
acceptable_SB_distance <- 3.2    # Acceptable salt bridge distance
smoothing_spur         <- 0.2    # Higher is smoother 
graph_col              <- "blue" # Color of salt bridge data
straight_col           <- "red"  # Color of straight line 

#####################
#####################

# Save distance of salt bridge throughout trajectory in CSV
# Plot distance vs frame
# Data saved in directory called validSB_files
# Plots saved in directory called Plots
#####################

save_saltBridge_data <- function(dist_list, x, percent) {
  # Save data
  df <- data.frame(Index = c(), Distance = c())
  len <- length(dist_list)
  sb_name <- substr(x, 8, nchar(x)-4)
  for (i in 1:len) {
    new_row <- data.frame(Index = c(i), Distance = (dist_list[i]))
    df <- rbind(df, new_row)
  }
  dir.create(file.path("../", "validSB_files"), showWarnings = FALSE)
  file_name <- paste("../validSB_files/", sb_name, ".csv",
                     sep = "", collapse = NULL)
  write.csv(df, file_name)
  # Plot data
  smoothingSpline = smooth.spline(df$Index, df$Distance, spar=smoothing_spur)
  plot(df, type="l", ylim = c(2, 5),
       main = paste(sb_name, percent), 
       ylab = "Frame", xlab = "Distance (Å)",
       col = transparent(graph_col), cex.lab = 1.4, lwd = 1.5)
  lines(smoothingSpline, type="l", col = graph_col, lwd = 1.5)
  abline(h = 3.2, col = straight_col, lwd = 2)
  dir.create(file.path("../", "Plots"), showWarnings = FALSE)
  file_name <- paste("../Plots/", sb_name, ".jpg",
                     sep = "", collapse = NULL)
  dev.copy(png, file_name)
  dev.off()
}

# Find acceptable salt bridges
#####################

find_saltBridges <- function(x) {
  t <- read.table(x, header=FALSE)
  dist_list <- t$V2
  sum <- 0
  len <- length(dist_list)
  for (i in 1:len) {
    if (dist_list[i] < acceptable_SB_distance) {
      sum <- sum + 1
    }
  }
  percent <- 100 * sum / len
  if (percent > minimum_percentage) {
    percent <- paste("(", toString(percent), "%)", sep = "")
    save_saltBridge_data(dist_list, x, percent)
    return(x)
  }
  return("")
}

# Script
#####################

files <- list.files(pattern="*.dat")

return_list <- lapply(files, find_saltBridges)
return_list <- return_list[return_list != ""];
return_list <- substr(return_list, 8, nchar(return_list)-4)

header <- paste("Salt bridges with at least ", 
                toString(minimum_percentage),
                "% coverage: ", toString(length(return_list)))
text <- paste(return_list, collapse = "\n")
text <- paste(header, text, sep = "\n")

fileConn<-file("../saltBridges.txt")
writeLines(text, fileConn)
close(fileConn)


