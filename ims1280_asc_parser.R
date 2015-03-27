GetAscFileList <- function(dir.name, full.names = TRUE) {
  files <- list.files(dir.name, pattern = '\\.asc$', full.names = full.names) # get .asc file list
  file.num <- as.numeric(gsub('.*@([0-9]*)\\.asc$','\\1', files))
  ascfiles <- files[order(file.num)] # sort file

  return(ascfiles)
}

GetCommentList <- function(dir.name, spreadsheet = NULL) {
  # import comment file
  # comment file name: asc_comm.txt
  # comment file format:
  #  Two columns [File, Comment] tab delimited
  # If asc_comm.txt is not available, this function will try to find and read
  # Excel spreadsheet

  file.name <- basename(dir.name)
  comment.file.name <- file.path(dir.name, 'asc_comm.txt')
  xls.file.name <- ifelse(!is.null(spreadsheet), spreadsheet,
                          file.path(dir.name, paste0(file.name, '.xls')))
  comments <- NULL
  if (file.exists(comment.file.name)) {
    # print('importing comments from asc_comm.txt')
    comments <- read.table(comment.file.name,
                           header = TRUE, sep = '\t', check.names = FALSE,
                           comment.char = '', row.names = 'File')
  } else if (file.exists(xls.file.name)) {
    library(xlsx) # reading xls file
    xls <- read.xlsx(xls.file.name, sheetName = 'Sum_table')
    # print(paste0('importing comments from excel file. [', basename(xls.file.name), ']'))
    c <- subset(xls, !is.na(File) & !is.na(Comment), c(File, Comment))
    comments <- data.frame(File = c$File, Comment = c$Comment)
    write.table(comments, file = comment.file.name,
                sep = '\t', quote = FALSE, col.names = TRUE, row.names = FALSE)
    comments <- transform(comments, row.names = 'File')
  }

  return(comments)
}

ParseAscFile <- function(ascfile) {
  # ascfile: /path/to/20201231@326.asc
  # Parse SIMS .asc file
  o <- list()
  line.sep.data <- GetLineSepData(ascfile)
  
  o$analysis.name<-ascfile
  o$date.time   <- GetDateTime(line.sep.data)
  o$file.names  <- GetFileNames(line.sep.data)
  o$description <- GetComment(line.sep.data)
  o$position    <- GetPosition(line.sep.data)
  o$params <- c(o$params, TableParseWOColName(line.sep.data,
                                              'SAMPLE NAME', 0))
  o$params <- c(o$params, TableParseWOColName(line.sep.data,
                                              'ANALYTICAL PARAM', 2))
  o$params <- c(o$params, TableParseWOColName(line.sep.data,
                                              'CORRECTION FACTORS', 2))
  o$params <- c(o$params, TableParseWOColName(line.sep.data,
                                              'ACQUISITION CONTROL', 3))
  o$params <- c(o$params, TableParseWOColName(line.sep.data,
                                              'Pre-sputtering PARAM', 2))
  o$detector.params <- TableParseWColName(line.sep.data,
                                          'DETECTOR PARAM', 4)
  o$cumurated.result <- TableParseWColName(line.sep.data,
                                           'CUMULATED RESULTS', 4)
  o$beam.centering <- TableParseWColName(line.sep.data,
                                         'BEAM CENTERING RESULTS', 4)
  o$isotopic.ratio <- GetRatioDefinitions(line.sep.data)
  o$primary.beam   <- GetPrimaryIntensity(line.sep.data)
  o$cycle.number   <- GetCycleNumber(line.sep.data)
  o$block.number   <- GetBlockNumber(line.sep.data)
  o$cps <- GetCPS2(line.sep.data)

  return(o)
}

GetLineSepData <- function(asc.file.path) {
  line.sep.data <- read.csv(asc.file.path, header = FALSE,
                            blank.lines.skip = FALSE, as.is = FALSE,
                            fill = FALSE, quote = '', sep = '`')
  return(line.sep.data)
}

GetRatioDefinitions <- function(line.sep.data) {
  out <- c()
  r <- try(grep('^ISOTOPICS RATIO', line.sep.data[, 1]))
  while(TRUE | r < 1000) {
    r <- r + 1
    l <- as.character(line.sep.data[r, 1])
    if (grepl('STATISTICS', l)) {
      break
    }
    if (grepl('[a-zA-Z]', l)) {
      sep <- strsplit(l, "=")[[1]]
      out[[sep[1]]] <- sep[2]
    }
  }

  return(out)
}

GetPrimaryIntensity <- function(line.sep.data) {
  r <- try(grep('^Primary Current START', line.sep.data[, 1]))
  sep <- MySplit(line.sep.data[r, 1])
  start <- as.numeric(sep[3])
  sep <- MySplit(line.sep.data[r + 1, 1])
  end <- as.numeric(sep[3])
  diff <- (end / start - 1) * 1000

  return(c(start = start,
           end = end,
           average = mean(c(start, end)),
           'diff[\u2030]' = diff))
}

GetDateTime <- function(line.sep.data) {
  sims.date <- MySplit(line.sep.data[1, 1])[2]
  sims.time <- MySplit(line.sep.data[2, 1])[2]
  sims.posix <- as.numeric(as.POSIXct(paste(sims.date, sims.time),
                           format = '%m/%d/%Y %I:%M %p',
                           tz = 'America/Chicago'))

  return(c(date = sims.date, time = sims.time, posix = sims.posix))
}

GetComment <- function(line.sep.data) {
  return(gsub('\t', ' ', gsub('\"', '', sub('\r', '', line.sep.data[8, 1]))))
}

GetPosition <- function(line.sep.data) {
  r <- try(grep('^X POSITION', line.sep.data[, 1]))
  sep <- MySplit(line.sep.data[r, 1])
  return(c(x = as.numeric(sep[2]), y = as.numeric(sep[4])))
}

GetFileNames <- function(line.sep.data) {
  r <- try(grep('^ACQUISITION FILE NAME', line.sep.data[, 1]))
  sep <- MySplit(line.sep.data[r, 1])
  acq.file <- sep[2]
  sep <- MySplit(line.sep.data[r + 1, 1])
  cond.file <- sep[2]

  return(c(aquisition = acq.file, condition = cond.file))
}

GetCPSRange <- function(line.sep.data) {
  offset <- 4
  block.limits <- try(grep('^#block', line.sep.data[, 1]))
  block.limits[1] <- as.numeric(block.limits[1]) + offset
  block.limits[2] <- as.numeric(block.limits[2]) - offset
  block.limits[3] <- as.numeric(block.limits[3]) + offset

  return(block.limits)
}

GetCycleNumber <- function(line.sep.data) {
  block.limits <- GetCPSRange(line.sep.data)
  cycle <- block.limits[2] - block.limits[1] + 1

  return(cycle)
}

GetBlockNumber <- function(line.sep.data) {
  r <- try(grep('^CUMULATED RESULTS', line.sep.data[, 1]))
  sep <- strsplit(as.character(line.sep.data[r, 1]), '\t')[[1]]

  return (as.numeric(sep[3]))
}

GetCPS2 <- function(line.sep.data) {
  block.limits <- GetCPSRange(line.sep.data)
  tmp.lab <- MySplit(line.sep.data[block.limits[1] - 2, 1])
  column.labels <- c(c('N.Block', 'N.Cycle'),
                     c(tmp.lab[2:length(tmp.lab)], 'Time'))
  ar <- array(NA, c(block.limits[2] - block.limits[1] + 1,
              length(column.labels)))
  for (row.num in block.limits[1]:block.limits[2]) {
    sep <- as.numeric(MySplit(line.sep.data[row.num, 1]))
    r <- row.num - block.limits[1] + 1
    sep.len <- length(sep)
    for (c in 1:sep.len) {
      ar[r, c] <- sep[c]
    }
    ar[r, sep.len + 1] <- as.numeric(
      MySplit(line.sep.data[block.limits[3] + r - 1, 1])[3])
  }
  d <- data.frame(ar)
  names(d) <- column.labels

  return(d)
}

GetCPS <- function(line.sep.data) {
  block.limits <- GetCPSRange(line.sep.data)
  # parse cps data
  d1 <- d2 <- d3 <- c()
  for (i in seq(block.limits[1], block.limits[2])) {
    tab.sep.data <- as.numeric(gsub('\\s+', '',
                               strsplit(as.character(line.sep.data[i, 1]),
                               '\t')[[1]]))
    if (length(tab.sep.data) > 0 ) {
      d1 <- c(d1, tab.sep.data[3])
      d2 <- c(d2, tab.sep.data[4])
      d3 <- c(d3, tab.sep.data[5])
    }
  }
  cps <- data.frame(V1 = d1, V2 = d2, V3 = d3)

  return(cps)
}

TableParseWOColName <- function(line.sep.data, marker.start, offset.start) {
  out <- c()
  row.num.start <- try(grep(paste0('^', marker.start), line.sep.data[, 1], ))
  if (!length(row.num.start)) {
    return(FALSE)
  }
  row.num.start <- row.num.start + offset.start
  row.num.end <- FindEndRow(line.sep.data, row.num.start)
  for (r in seq(row.num.start, row.num.end)) {
    sep <- MySplit(line.sep.data[r, 1])
    if (length(sep) == 1) {
      sep <- strsplit(sep[1], '\\s+:\\s+?')[[1]]
    } else {
      sep[1] <- sub('\\s:$', '', sep[1])
    }
    sep[1] <- sub(':$', '', sep[1])
    out[[sep[1]]] <- Sanitize(sep[2])
  }

  return(out)
}

TableParseWColName <- function(line.sep.data, marker.start, offset.start) {
  row.num.start <- try(grep(paste0('^', marker.start), line.sep.data[, 1]))
  if (!length(row.num.start)) {
    return(FALSE)
  }
  row.num.start <- row.num.start + offset.start
  row.num.end <- FindEndRow(line.sep.data, row.num.start)
  row.labels <- c()
  column.labels <- MySplit(line.sep.data[row.num.start - 2, 1])
  column.labels <- c('', column.labels[column.labels != ''])
  column.len    <- length(column.labels) - 1  # w/o row labels
  ar <- array(NA, c(row.num.end - row.num.start + 1, column.len))

  for (r in seq(row.num.start, row.num.end)) {
    tab.sep.data <- MySplit(line.sep.data[r, 1])
    row.labels <- c(row.labels, tab.sep.data[1])
    for (c in seq(column.len)) {
      ar[r - row.num.start + 1, c] <- tab.sep.data[c + 1]
    }
  }
  df <- data.frame(ar)
  names(df) <- column.labels[2:length(column.labels)]
  row.names(df) <- row.labels

  return(df)
}

FindEndRow <- function(lines, row.start) {
  flag <- TRUE
  row.num <- row.start
  while(isTRUE(flag)) {
    row.num <- row.num + 1
    flag <- as.numeric(nchar(as.character(lines[row.num, 1]))) > 0
  }

  return(row.num - 1)
}

Sanitize <- function(obj) {
  if (grepl('[^0-9eE\\-\\+\\.]', obj)) {
    as.character(obj)
  } else {
    as.numeric(obj)
  }
}

GetDelta <- function(mass1, mass2, scale) {
  return(1000 * ((mass2 / mass1) / as.numeric(scale) - 1))
}

MySplit <- function(line) {
  gsub('\\s{2,}', ' ',
       gsub('^\\s+|\\s+$', '', strsplit(as.character(line), '\t')[[1]]))
}
