#' findDeletionsRevised
#' 
#' @param seq         DNA sequence
#' @param cutPosition Position to be cut in the DNA sequence
#' @param weight      deletion length weight factor
#'
#' @return
#' @export
#'
#' @examples

findDeletionsRevised <- function(id, seq, weight = 20.0){
  cutIndex <- nchar(seq) / 2
  
  # Define microhomology length to be used
  mhL <- 2
  
  # Make sequence uppercase
  seq <- toupper(seq)
  
  # Split the sequence into upstream and downstream of the cut site
  upstream   <- substring(seq, 1,                    nchar(seq) / 2)
  downstream <- substring(seq, (nchar(seq) / 2) + 1, nchar(seq))
  
  # Get all common substrings between upstream and downstream sections of sequence
  commonSubstrings <- allsubstr(upstream, downstream, mhL)
  
  # Check if there are 2bp or > MH
  if(length(commonSubstrings) > 0){ 
    
    # Find all upstream matches to common substrings
    matchLocsUp       <- stack(sapply(commonSubstrings, Biostrings::gregexpr2, text = upstream))
    matchLocsUp$ind   <- as.character(matchLocsUp$ind)
    
    # Find all downstream matches to common substrings
    matchLocsDown     <- stack(sapply(commonSubstrings, Biostrings::gregexpr2, text = downstream))
    matchLocsDown$ind <- as.character(matchLocsDown$ind)
    
    # Find all the starting and ending locations of the common substrings in the upstream portion
    upStart   <- matchLocsUp$values
    upEnd     <- matchLocsUp$values + nchar(matchLocsUp$ind) - 1
    
    # Do the same for the downstream
    downStart <- matchLocsDown$values + nchar(upstream)
    downEnd   <- matchLocsDown$values + nchar(matchLocsDown$ind) + nchar(upstream)
    
    # Store microhomologies in data frames
    mhDFup <- data.frame(seq              = matchLocsUp$ind,
                         upStart          = upStart,
                         upEnd            = upEnd,
                         stringsAsFactors = FALSE
    )
    
    mhDFdown <- data.frame(seq              = matchLocsDown$ind,
                           downStart        = downStart,
                           downEnd          = downEnd,
                           stringsAsFactors = FALSE
    )
    
    # Order the data frames
    mhDFup   <-   mhDFup[order(nchar(mhDFup$seq),   mhDFup$seq),   ]
    mhDFdown <- mhDFdown[order(nchar(mhDFdown$seq), mhDFdown$seq), ]
    
    # Merge the two data frames
    mhDF <- suppressMessages(plyr::join(mhDFup, mhDFdown))
    
    # Get the lengths of all the deletions
    leng <- mhDF$downEnd - (mhDF$upEnd + 1)
    
    # Get the microhomologies
    mh   <- mhDF$seq
    
    # Create the deletion sequences
    delSeqCon <- unlist(lapply(1:nrow(mhDF), function(x) paste0(substring(seq, 1, mhDF$upEnd[x]),
                                                                paste(rep('-', leng[x]), collapse = ''),
                                                                substring(seq, mhDF$downEnd[x], nchar(seq)))))
    
    # Get the pattern that would be seen if the deletion ocurred
    delPattern <- gsub('-', '', delSeqCon, fixed = TRUE)
    
    # Get the sequence deleted
    delSeqs <- unlist(lapply(1:nrow(mhDF), function(x) substring(seq, mhDF$upEnd[x] + 1, mhDF$downEnd[x])))
    
    # Whether the deletion is out of frame
    oof     <- unlist(lapply(leng, function(x) (if(x %% 3 != 0){1} else {0})))
                
    # Distance to the cut site
    distC   <- unlist(lapply(1:nrow(mhDF), function(x) (cutIndex + 1) - (mhDF$upEnd[x] + 1)))
    
    # Create a data frame to hold information about predicted potential MMEJ events
    # For instance, given sequence "GTGGCCGACGGGCTCATCACCACGCTCCATTATCCAGCCCCAAAGCGCAA":
    # The first row of this frame (before sorting) will look like:
    #
    # This won't be here:GTGGCCGACGGGCTCATCACCACGCTCCATTATCCAGCCCCAAAGCGCAA     # Wildtype sequence for comparison
    # deletedSeqContext: GTGGC---------------------------------CCCAAAGCGCAA     # Visualization of deletion pattern
    # microhomology:        GC                                                  # The microhomology sequence (aligned to the sequence for comparison; actually just char vector)
    # startDel:       6                                                         # The index of the first "-" deletion
    # endDel:         38                                                        # The index of the last "-" deletion
    # mhStart1:       4                                                         # The index of the first character in the left hand mh arm
    # mhEnd1:         5                                                         # The index of the last character in the left hand mh arm
    # mhStart2:       37                                                        # The index of the first character in the right hand mh arm
    # mhEnd2:         38                                                        # The index of the last character in the right hand mh arm
    # deletedSeq:             CGACGGGCTCATCACCACGCTCCATTATCCAGC                 # The deleted sequence (aligned to sequence for comparison)
    # delLength:      33                                                        # length of deletedSeq
    # mhLength:       2                                                         # Length of microhomology
    # GC:             1                                                         # GC content of microhomology; percentage from 0 to 1
    # distToCut:      20                                                        # Distance from the last nucleotide before the deletion to the location of the ds cut
    # outOfFrame:     0                                                         # Whether the deletion produces an out of frame mutation (0 = no, 1 = yes)
    
    delFrame <- data.frame(id                = rep(id, length(delSeqs)),
                           seq               = rep(seq, length(delSeqs)),
                           deletedSeqContext = delSeqCon,
                           delPattern        = delPattern,
                           microhomology     = mh, 
                           startDel          = mhDF$upEnd + 1, 
                           endDel            = mhDF$downEnd, 
                           mhStart1          = mhDF$upStart, 
                           mhEnd1            = mhDF$upEnd,
                           mhStart2          = mhDF$downStart,
                           mhEnd2            = mhDF$downEnd,
                           deletedSeq        = delSeqs,
                           delLength         = leng, 
                           mhLength          = nchar(mhDF$seq),
                           GC                = (stringr::str_count(mh, 'G') + stringr::str_count(mh, 'C')) / nchar(mh),
                           distToCut         = distC,
                           outOfFrame        = oof,
                           patternScore      = (100 * (round(1 / exp((leng) / weight), 3)) * 
                                                  (stringr::str_count(mh, 'G') + stringr::str_count(mh, 'C') + nchar(mh))),
                           stringsAsFactors  = FALSE)
    
    # Order the data frame by microhomology length, and then by pattern score
    delFrameOrd <- delFrame[order(-nchar(delFrame$microhomology), -delFrame$patternScore),]
    
    # Find instances where two microhomologies produce the same deletion pattern; leave the longest microhomology with the largest pattern score
    dupes <- sapply(1:nrow(delFrameOrd), function(x) unlist(sapply(1:x, function(y){
      if(x != y){
        if(delFrameOrd$delPattern[x] == delFrameOrd$delPattern[y]){
          TRUE
        } else {
          FALSE
        }
      } else {
        FALSE
      }
    })))
    
    # Find which instances have a match
    dupeDrop <- sapply(dupes, function(x) any(x))
    
    # Remove the duplicates
    dupeDropList      <- which(dupeDrop)
    delFrameOrdDeDupe <- delFrameOrd[-dupeDropList,]
    
    # Order the data frame based on pattern score
    delFrame <- delFrameOrdDeDupe[order(-delFrameOrdDeDupe$patternScore), ]
    
  } else {
    
    #Create empty return frame if no MHs detected
    delFrame <- data.frame(id                = as.character(),
                           seq               = as.character(),
                           deletedSeqContext = as.character(),
                           microhomology     = as.character(), 
                           startDel          = as.numeric(), 
                           endDel            = as.numeric(), 
                           mhStart1          = as.numeric(), 
                           mhEnd1            = as.numeric(),
                           mhStart2          = as.numeric(),
                           mhEnd2            = as.numeric(),
                           deletedSeq        = as.character(),
                           delLength         = as.numeric(), 
                           mhLength          = as.numeric(),
                           GC                = as.numeric(),
                           distToCut         = as.numeric(),
                           outOfFrame        = as.numeric(),
                           patternScore      = as.numeric(),
                           stringsAsFactors  = FALSE)
    
  }
  
  return(delFrame)
}

#' allsubstr
#'
#' @param upstream   upstream section of DNA sequence 
#' @param downstream downstream section of DNA sequence
#'
#' @return
#' @export
#'
#' @examples

allsubstr <- function(upstream, downstream, mh = 3){
  #Create empty string to hold upstream strings
  upstreamStrings   <- list()
  
  #Create empty string to hold downstream strings
  downstreamStrings <- list()
  
  #Generate all possible substrings of length >= 3 in the upstream and downstream strings
  for(i in mh:nchar(upstream)){
    upstreamStrings   <- c(upstreamStrings,   unique(substring(upstream,   1:(nchar(upstream)   - i + 1), i:nchar(upstream))))
    downstreamStrings <- c(downstreamStrings, unique(substring(downstream, 1:(nchar(downstream) - i + 1), i:nchar(downstream))))
  }
  
  #Find the intersection (common strings) between the upstream and downstream section
  commonStrings <- intersect(unlist(upstreamStrings), unlist(downstreamStrings))
  
  return(commonStrings)
} 

#' generateFeatureVector
#'
#' This function takes a data frame containing potential MMEJ
#' events (as generated by findDeletions) and returns a data frame
#' with one row containing the calculated features
#'
#' @param uFrame A data frame containing the unique potential MMEJ events
#' 
#' @return A data frame containing feature vectors calculated from uFrame
#'
#' @examples
#' 
#'
#' @export

generateFeatureVector <- function(uFrame){
  #Calculate information about predicted deletions
  returnFrame <- data.frame(id                 = uFrame$id,
                            sequence           = uFrame$seq,
                            maxDelLength       = max(   uFrame$delLength)    / nchar(uFrame$seq),
                            minDelLength       = min(   uFrame$delLength)    / nchar(uFrame$seq),
                            meanDelLength      = mean(  uFrame$delLength)    / nchar(uFrame$seq),
                            medianDelLength    = median(uFrame$delLength)    / nchar(uFrame$seq),
                            stDevDelLength     = sd(    uFrame$delLength)    / nchar(uFrame$seq),
                            
                            maxMHLength        = max(   uFrame$mhLength)     / nchar(uFrame$seq),
                            minMHLength        = min(   uFrame$mhLength)     / nchar(uFrame$seq),
                            meanMHLength       = mean(  uFrame$mhLength)     / nchar(uFrame$seq),
                            medianMHLength     = median(uFrame$mhLength)     / nchar(uFrame$seq),
                            
                            stDevMHLength      = sd(uFrame$mhLength)         / nchar(uFrame$seq),
                            
                            maxGC              = max(   uFrame$GC)           / nchar(uFrame$seq),
                            minGC              = min(   uFrame$GC)           / nchar(uFrame$seq),
                            meanGC             = mean(  uFrame$GC)           / nchar(uFrame$seq),
                            medianGC           = median(uFrame$GC)           / nchar(uFrame$seq),
                            stDevGC            = sd(    uFrame$GC)           / nchar(uFrame$seq),
                            
                            maxDistC           = max(   uFrame$distToCut)    / nchar(uFrame$seq),
                            minDistC           = min(   uFrame$distToCut)    / nchar(uFrame$seq),
                            meanDistC          = mean(  uFrame$distToCut)    / nchar(uFrame$seq),
                            medianDistC        = median(uFrame$distToCut)    / nchar(uFrame$seq),
                            stDevDistC         = sd(    uFrame$distToCut)    / nchar(uFrame$seq),
                            
                            perOutOfFrame      = sum(   uFrame$outOfFrame)   / nrow(uFrame), 
                            
                            sequenceGC         = sum(str_count(uFrame$seq[1], c("G", "C", "g", "c"))) / nchar(uFrame$seq[1]),
                            
                            mhScoreNorm        = sum(   uFrame$patternScore) / nchar(uFrame$seq),
                            
                            oofScore           = (sum(  uFrame$patternScore[which(uFrame$outOfFrame == 1)]) / sum(uFrame$patternScore)) * 100,
                            
                            maxPatternScore    = max(   uFrame$patternScore) / nchar(uFrame$seq),
                            minPatternScore    = min(   uFrame$patternScore) / nchar(uFrame$seq),
                            meanPatternScore   = mean(  uFrame$patternScore) / nchar(uFrame$seq),
                            medianPatternScore = median(uFrame$patternScore) / nchar(uFrame$seq),
                            stDevPatternScore  = sd(    uFrame$patternScore) / nchar(uFrame$seq),
                            
                            stringsAsFactors = FALSE)
  return(unique(returnFrame))
}
