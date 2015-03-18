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
  # ''
  tmpData <- read.csv(ascfile, header = FALSE, blank.lines.skip = FALSE,
                      as.is = FALSE, fill = FALSE, quote = '', sep = '`')

  # get line numbers for cps data
  limits <- try(grep('^#block', tmpData[,1], ignore.case = TRUE))
  limits[1] = as.numeric(limits[1]) + 3
  limits[2] = as.numeric(limits[2]) - 3

  # get cycle number
  cycle <- limits[2] - limits[1] - 1

  # get comment
  comment <- gsub('\t', ' ', gsub('\"', '', sub('\r', '', tmpData[8, 1])))

  # parse cps data
  d1 <- d2 <- d3 <- c()
  for (i in seq(limits[1], limits[2])) {
    tmpSepData <- as.numeric(
      gsub('\\s+', '', strsplit(as.character(tmpData[i, 1]), '\t')[[1]])
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
