PlotDataByCycle <- function(data, cycle, ylim, color, pch = 15, axes = TRUE) {
  plot(data,
       xlim = c(1, cycle), 
       ylim = ylim, 
       col = color, pch = pch, 
       axes = axes,
       main = '',
       type = 'b', lty = 1, cex = 0.9,
       xlab = '', ylab = '', yaxt = 'n', xaxt = 'n')
}

PlotPrimaryY <- function(data, target, stat, x.minor.ticks = FALSE) {
  Y <- target$plot
  cycle   <- length(data[, 1])
  limits  <- stat$limits[[Y]]
  average <- stat$ave[[Y]]
  color   <- target$color

  PlotDataByCycle(data[[Y]], cycle, limits, color)
  # Major ticks for Y axis
  axis(side = 2, col.axis = color, las = 1, hadj = 0.75, tcl = 0.5)
  # label for Y axis
  mtext(target$label, side = 2, padj = -4, col = color)

  AddYMinorTicks(x.minor.ticks)
  # Major ticks for x axis
  if (isTRUE(x.minor.ticks)) {
    axis(side = 1, tcl = 0, at = axTicks(1), padj = -1.5)
    axis(side = 3, tcl = 0.5, at = axTicks(1), padj = -1.5, labels = FALSE)
  } else {
    axis(side = 1, labels = FALSE, at = axTicks(1), tcl = 0.5)
  }

  # line for average value
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  # text of average and 2SE
  mtext(paste0(format(round(average, 2), nsmall = 2), ' \u00B1 ',
        format(round(stat$se[[Y]], 2), nsmall = 2),
        ' [', target$unit, '] (2SE)'),
        side = 3, padj = 1.7, adj = 0.98, col = color, cex = 0.9)
}

PlotSecondaryY <- function(data, target, stat) {
  Y <- target$plot
  cycle   <- length(d[, 1])
  limits  <- stat$limits[[Y]]
  average <- stat$ave[[Y]]
  color   <- target$color
  par(new = TRUE)
  PlotDataByCycle(data[[Y]], cycle, limits, color, 1, FALSE)
  axis(side = 4, at = axTicks(2),
       format(axTicks(2), digits = 2, nsmall = 2, scientific = TRUE),
       las = 1, hadj = 0.3, tcl = 0.5, col.axis = color)
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  #  secondary label
  mtext(target$label, side = 4, padj = 4.5, col = color)
  #  average and 2SE
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  mtext(paste0(format(average, digits = 2, nsmall = 2, scientific = TRUE),
        ' \u00B1 ',
        format(stat$se[[Y]], digits = 2, nsmall = 2, scientific = TRUE),
        ' [', target$unit, '] (2SE)'),
        side = 3, padj = 3.1, adj = 0.98, col = color, cex = 0.9)
}

AddTitle <- function(title, subtitle) {
  mtext(paste('(', basename(subtitle), ')'), 3, padj = -0.5)
  title(main=title)
}

AddYMinorTicks <- function(minorX = FALSE) {
  library(Hmisc)  # for minor ticks
  minor.ticks.X <- axTicks(1)[2] - axTicks(1)[1]
  minor.ticks.Y <- axTicks(2)[2] - axTicks(2)[1]
  minor.ticks.Y <- minor.ticks.Y / 10 ^ floor(log10(minor.ticks.Y))
  if (minor.ticks.Y == 1) {
    minor.ticks.Y <- 5
  } else if (minor.ticks.Y == 2) {
    minor.ticks.Y <- 4
  }
  if (isTRUE(minorX)) {
    minor.tick(minor.ticks.X, minor.ticks.Y, -0.5)
  } else {
    minor.tick(0, minor.ticks.Y, -0.5)
  }
}
