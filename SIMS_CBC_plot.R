# This script can make cycle-by-cycle plot from IMS 1280 asc file

# Absolute path for a directory containing SIMS .asc files
data.dir <- '/path/to/your/SIMS_data_directory'

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

data.headers <- c('delta',
                  'mass1',
                  'mass2',
                  'hydride',
                  'hydride.ratio')

if (element == 'carbon' | element == 'C') { # CARBON
  mass1         <- 'cps.V1'  # 12C
  mass2         <- 'cps.V2'  # 13C
  hydride       <- 'cps.V3'  # 13C1H
  hydride.ratio <- 'cps.V2'  # 13C1H/13C
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
  mass1         <- 'cps.V1'  # 16O
  mass2         <- 'cps.V3'  # 18O
  hydride       <- 'cps.V2'  # 16O1H
  hydride.ratio <- 'cps.V1'  # 16O1H/16O
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

source('./ims1280_asc_parser.R')
source('./plot_cycle_by_cycle.R')

##################################################
# MAIN ROUTINE
##################################################
if (!file.exists(data.dir)) {
  stop(paste0('Directory [', data.dir, '] doesn\'t exist'))
}

if (output.path == '') {
  output.path = file.path(data.dir, paste0(basename(data.dir), '.pdf'))
}

ascfiles <- GetAscFileList(data.dir)  # get list of .asc files
comments <- GetCommentList(data.dir)  # get comments from Spreadsheet

pdf(output.path, paper = 'us', width = 0, height = 0, encoding = 'MacRoman')  # set output device
par(mfrow = c(2, 1), oma = c(0, 0, 0, 0))  # set print margins

# ============
#  MAIN LOOP
# ============

for (filename in ascfiles) {
  asc.data <- ParseAscFile(filename)

  comment <- ifelse(!is.null(comments),
                    as.character(comments[basename(filename),]),
                    asc.data$comment)

  print(paste(basename(filename), ':', comment))

  d <- data.frame(delta = ((asc.data[[mass2]] / asc.data[[mass1]]) / deltaScale - 1) * 1000,
                  mass1 = asc.data[[mass1]],
                  mass2 = asc.data[[mass2]],
                  hydride = asc.data[[hydride]],
                  hydride.ratio = asc.data[[hydride]] / asc.data[[hydride.ratio]])

  margin <- 0.15 * c(-1, 1) # set 15% margin on Y-axes for legends

  stat <- list()
  for (i in data.headers) {
    tmp <- d[[i]]
    tmp.range <- range(tmp) + margin * abs(diff(range(tmp, na.rm = TRUE)))
    stat$ave[[i]]    <- mean(tmp, na.rm = TRUE)
    stat$se[[i]]     <- sd(tmp, na.rm = TRUE) / sqrt(length(tmp)) * 2
    stat$limits[[i]] <- tmp.range  # c(min, max)
  }

  # ===================
  #  Graph drawing
  # ===================

  # ==================
  #  upper plot
  # ------------------
  par(mar = c(0, 5.5, 4, 5.5))
  PlotPrimaryY(d, u.pri, stat)
  PlotSecondaryY(d, u.sec, stat)
  AddTitle(comment, filename)
  # legend for upper plot
  legend('bottomright', legend = c(u.pri$label, u.sec$label),
         col = c(u.pri$color, u.sec$color), pch = c(15, 1), ncol = 2,
         bg = 'white')

  # ==================
  #  lower plot
  # ------------------
  par(mar = c(5, 5.5, 0, 5.5))
  PlotPrimaryY(d, l.pri, stat, x.minor.ticks = TRUE)
  PlotSecondaryY(d, l.sec, stat)
  #  legend for lower plot
  legend('bottomleft', legend = c(l.pri$label, l.sec$label),
         col = c(l.pri$color, l.sec$color),
         pch = c(15, 1), ncol = 2, bg = 'white')
  # x label
  mtext('Cycle #', side = 1, line = 1, padj = 1.5)

} # end of main loop

dev.off() # shuts down pdf writer

# open pdf file
system(paste(options('pdfviewer'), output.path))
