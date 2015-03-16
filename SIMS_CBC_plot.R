# This script can make cycle-by-cycle plot from IMS 1280 asc file

# Absolute path for a directory containing SIMS .asc files
data.dir <- "/path/to/your/SIMS_data_directory"

# output.path should be end with '.pdf'
# If it's blank, path sets to "data.dir/[directory name].pdf"
# output.path <- file.path(data.dir, 'cycle_by_cycle.pdf')
output.path <- ''

# select element (oxygen, carbon)
# C and O are also acceptable
# TODO (Kouki): auto-detect
# element <- 'oxygen'
element <- 'carbon'


######################
# Plot configurations
######################

VSMOW <- 0.00200520
PDBO  <- 0.0020672  # PDB oxygen
PDBC  <- 0.0112372  # PDB carbon

data.headers <- c("delta",
                  "mass1",
                  "mass2",
                  "hydride",
                  "hydride.ratio")

if (element == 'carbon' | element == 'C') { # CARBON
  mass1         <- "cps.V1"  # 12C
  mass2         <- "cps.V2"  # 13C
  hydride       <- "cps.V3"  # 13C1H
  hydride.ratio <- "cps.V2"  # 13C1H/13C
  deltaScale    <- PDBC

  u.pri <- list('plot'  = 'delta',  # upper left
                'unit'  = '\u2030',
                'label' = expression(paste(delta^{13}*C[raw], " [\u2030]")),
                'color' = 'red2')
  u.sec <- list('plot'  = 'hydride.ratio',  # upper right
                'unit'  = 'cps/cps',
                'label' = expression(paste(''^{13}*C^{1}*H/''^{13}*C, " [cps/cps]")),
                'color' = 'blue2')
  l.pri <- list('plot'  = 'mass2',  # lower left
                'unit'  = 'cps',
                'label' = expression(paste(''^{13}*C, " [cps]")),
                'color' = 'seagreen')
  l.sec <- list('plot'  = 'hydride',  # lower right
                'unit'  = 'cps',
                'label' = expression(paste(''^{13}*C^{1}*H, " [cps]")),
                'color' = 'darkorange')

} else if (element == 'oxygen' | element == 'O') {  # OXYGEN
  mass1         <- "cps.V1"  # 16O
  mass2         <- "cps.V3"  # 18O
  hydride       <- "cps.V2"  # 16O1H
  hydride.ratio <- "cps.V1"  # 16O1H/16O
  deltaScale    <- VSMOW

  u.pri <- list('plot'  = 'delta',  # upper left
                'unit'  = '\u2030',
                'label' = expression(paste(delta^{18}*O[raw], " [\u2030]")),
                'color' = 'red2')
  u.sec <- list('plot'  = 'hydride.ratio',  # upper right
                'unit'  = 'cps/cps',
                'label' = expression(paste(''^{16}*O^{1}*H/''^{16}*O, " [cps/cps]")),
                'color' = 'blue2')
  l.pri <- list('plot'  = 'mass1',  # lower left
                'unit'  = 'cps',
                'label' = expression(paste(''^{16}*O, " [cps]")),
                'color' = 'seagreen')
  l.sec <- list('plot'  = 'hydride',  # lower right
                'unit'  = 'cps',
                'label' = expression(paste(''^{16}*O^{1}*H, " [cps]")),
                'color' = 'darkorange')
}

# # # # # # # # # # # # # # # #
# Functions
# # # # # # # # # # # # # # # #

GetAscFileList <- function(dir.name, add.dir.name = TRUE) {
  files <- list.files(dir.name, pattern="\\.asc$") # get .asc file list
  file.num <- as.numeric(gsub('*@([0123456789]*)\\.asc$','\\1',files))
  ascfiles <- files[order(file.num)] # sort file
  if (add.dir.name) {
    ascfiles <- file.path(dir.name, ascfiles)
  }

  return(ascfiles)
}

GetCommentList <- function(dir.name, spreadsheet=NULL) {
  # import comment file
  # comment file name: asc_comm.txt
  # comment file format:
  #  Two columns [File, Comment] tab delimited
  # If asc_comm.txt is not available, this function will try to find and read
  # Excel spreadsheet

  file.name <- basename(dir.name)
  comment.file.name <- file.path(dir.name, "asc_comm.txt")
  xls.file.name <- ifelse(!is.null(spreadsheet), spreadsheet,
                          file.path(dir.name, paste0(file.name, '.xls')))
  comments <- NULL
  if (file.exists(comment.file.name)) {
    print("importing comments from asc_comm.txt")
    comments <- read.table(comment.file.name,
                           header = T, sep = "\t", check.names = F,
                           comment.char = "", row.names = "File")
  } else if (file.exists(xls.file.name)) {
    library(xlsx) # reading xls file
    xls <- read.xlsx(xls.file.name, sheetName = "Sum_table")
    print(paste0("importing comments from excel file. [", basename(xls.file.name), "]"))
    c <- subset(xls, !is.na(File) & !is.na(Comment), c(File, Comment))
    comments <- data.frame(File = c$File, Comment = c$Comment)
    write.table(comments, file = comment.file.name,
                sep = "\t", quote = F, col.names = T, row.names = F)
    comments <- transform(comments, row.names = 'File')
  }

  return(comments)
}

ParseAscFile <- function(ascfile) {
  # Parse SIMS .asc file
  #
  tmpData <- read.csv(ascfile, header = F, blank.lines.skip = F,
                      as.is = F, fill = F, quote = "", sep = "`")

  # get line numbers for cps data
  limits <- try(grep('^#block', tmpData[,1], ignore.case = T))
  limits[1] = as.numeric(limits[1]) + 3
  limits[2] = as.numeric(limits[2]) - 3

  # get cycle number
  cycle <- limits[2] - limits[1] - 1

  # get comment
  comment <- gsub("\t", " ", gsub("\"", "", sub("\r", "", tmpData[8, 1])))

  # parse cps data
  d1 <- d2 <- d3 <- c()
  for (i in seq(limits[1], limits[2])) {
    tmpSepData <- as.numeric(
      gsub('\\s+', '', strsplit(as.character(tmpData[i, 1]), "\t")[[1]])
    )
    if (length(tmpSepData) > 0 ) {
      d1 <- c(d1, tmpSepData[3])
      d2 <- c(d2, tmpSepData[4])
      d3 <- c(d3, tmpSepData[5])
    }
  }
  cps <- data.frame(V1 = d1, V2 = d2, V3 = d3)

  return(c('cps' = cps, 'comment' = comment, 'cycle' = cycle))
}

pdf2 <- function(file, width = 0, height = 0, onefile, family, title, fonts,
                 version, paper = "us", encoding = "MacRoman", bg, fg,
                 pointsize, pagecentre, colormodel, useDingbats, useKerning,
                 fillOddEven, compress) {
  grDevices::pdf(file=file, width=width, height=height, onefile, family, title,
                 fonts, version, paper=paper, encoding=encoding, bg, fg,
                 pointsize, pagecentre, colormodel, useDingbats, useKerning,
                 fillOddEven, compress)
}

# ##################
# Plotting functions
# ##################

PlotDataByCycle <- function(data, cycle, ylim, color, pch = 15, axes = TRUE) {
  plot(data,
       xlim = c(1, cycle), ylim = ylim, col = color, pch = pch, axes = axes,
       main = '',
       type = 'b', lty = 1, cex = 0.9,
       xlab = '', ylab = '', yaxt = 'n', xaxt = 'n')
}

PlotPrimaryY <- function(data, target, stat, x.minor.ticks = FALSE) {
  Y <- target$plot
  cycle   <- length(d[, 1])
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
    axis(side = 3, tcl = 0.5, at = axTicks(1), padj = -1.5, labels=F)
  } else {
    axis(side = 1, labels=F, at = axTicks(1), tcl = 0.5)
  }

  # line for average value
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  # text of average and 2SE
  mtext(paste0(format(round(average, 2), nsmall = 2), " \u00B1 ",
        format(round(stat$se[[Y]], 2), nsmall = 2), " [", target$unit, "] (2SE)"),
        side = 3, padj = 1.7, adj = 0.98, col = color, cex = 0.9)
}

PlotSecondaryY <- function(data, target, stat) {
  Y <- target$plot
  cycle   <- length(d[, 1])
  limits  <- stat$limits[[Y]]
  average <- stat$ave[[Y]]
  color   <- target$color
  par(new=T)
  PlotDataByCycle(d[[Y]], cycle, limits, color, 1, FALSE)
  axis(side = 4, at = axTicks(2),
       format(axTicks(2), digits = 2, nsmall = 2, scientific = T),
       las = 1, hadj = 0.3, tcl = 0.5, col.axis = color)
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  #  secondary label
  mtext(target$label, side = 4, padj = 4.5, col = color)
  #  average and 2SE
  abline(h = average, lwd = 0.5, col = color, lty = 3)
  mtext(paste0(format(average, digits = 2, nsmall = 2, scientific = T),
        " \u00B1 ",
        format(stat$se[[Y]], digits = 2, nsmall = 2, scientific = T),
        " [", target$unit, "] (2SE)"),
        side = 3, padj = 3.1, adj = 0.98, col = color, cex = 0.9)
}

AddTitle <- function(title, subtitle) {
  mtext(paste("(", basename(subtitle), ")", sep = ""), 3, padj = -0.5)
  title(main=title)
}

AddYMinorTicks <- function(minorX=FALSE) {
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



##################################################
# MAIN ROUTINE
##################################################
if (!file.exists(data.dir)) {
  stop(paste("Directory [", data.dir, "] doesn't exist"))
}

if (output.path == '') {
  output.path = file.path(data.dir, paste0(basename(data.dir), '.pdf'))
}

ascfiles <- GetAscFileList(data.dir)  # get list of .asc files

pdf2(output.path, paper="us")  # set output device
par(mfrow=c(2, 1), oma=c(0,0,0,0))  # set print margins

comments <- GetCommentList(data.dir)  # get comments from Spreadsheet

# ============
#  MAIN LOOP
# ============

for (filename in ascfiles) {
  asc.data <- ParseAscFile(filename)

  comment <- ifelse(!is.null(comments),
                    as.character(comments[basename(filename),]),
                    asc.data$comment)

  print(paste(basename(filename), ":", comment))

  d <- data.frame(delta = ((asc.data[[mass2]] / asc.data[[mass1]]) / deltaScale - 1) * 1000,
                  mass1 = asc.data[[mass1]],
                  mass2 = asc.data[[mass2]],
                  hydride = asc.data[[hydride]],
                  hydride.ratio = asc.data[[hydride]] / asc.data[[hydride.ratio]])

  margin <- 0.15 * c(-1, 1) # set 15% margin on Y-axes for legends

  stat <- list()
  for (i in data.headers) {
    tmp <- d[[i]]
    tmp.range <- range(tmp) + margin * abs(diff(range(tmp, na.rm = T)))
    stat$ave[[i]]    <- mean(tmp, na.rm = T)
    stat$se[[i]]     <- sd(tmp, na.rm = T) / sqrt(length(tmp)) * 2
    stat$limits[[i]] <- tmp.range  # c(min, max)
  }

  # ===================
  #  Graph drawing
  # ===================

  # ==================
  #  upper plot
  # ------------------
  par(mar=c(0, 5.5, 4, 5.5))
  PlotPrimaryY(d, u.pri, stat)
  PlotSecondaryY(d, u.sec, stat)
  AddTitle(comment, filename)
  # legend for upper plot
  legend("bottomright", legend = c(u.pri$label, u.sec$label),
         col = c(u.pri$color, u.sec$color), pch = c(15, 1), ncol = 2,
         bg = "white")

  # ==================
  #  lower plot
  # ------------------
  par(mar=c(5, 5.5, 0, 5.5))
  PlotPrimaryY(d, l.pri, stat, x.minor.ticks = TRUE)
  PlotSecondaryY(d, l.sec, stat)
  #  legend for lower plot
  legend("bottomleft", legend = c(l.pri$label, l.sec$label),
         col = c(l.pri$color, l.sec$color),
         pch = c(15, 1), ncol = 2, bg = "white")
  # x label
  mtext("Cycle #", side = 1, line = 1, padj = 1.5)

} # end of main loop

dev.off() # shuts down pdf writer

# open pdf file
system(paste(options('pdfviewer'), output.path))
