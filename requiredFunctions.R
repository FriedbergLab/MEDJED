#' findDeletions
#'
#' This function takes an identifier, sequence context, and single 
#' stranded guide RNA sequence and returns a data frame containing
#' potential MMEJ events
#'
#' @param seq   A sequence containing a DSB target and some surrounding context; cut must be in center of sequence
#' @param sgRNA The CRISPR guide RNA target, minus the PAM sequence
#' @param cutI  Gives the index of the beginning of the cutsite's downstream sequence in the event of an ambiguous PAM (i.e., "CCN" upstream AND "NGG" downstream of sgRNA match in seq)
#' 
#' @return A data frame containing the unique potential MMEJ events
#'
#' @examples
#' findDeletions("GTGGCCGACGGGCTCATCACCACGCTCCATTATCCAGCCCCAAAGCGCAA", "TGGGGCTGGATAATGGAGCG", cutI = 26)
#'
#' @export

# 

findDeletions <- function(id, seq){
  #Capitalize sequences to avoid case sensitive search issues
  seq <- toupper(seq)
  cutIndex <- nchar(seq)/2 + 1
  
  #Create a data frame to hold information about predicted potential MMEJ events
  #For instance, given sequence "GTGGCCGACGGGCTCATCACCACGCTCCATTATCCAGCCCCAAAGCGCAA":
  #The first row of this frame (before sorting) will look like:
  #
  #This won't be here:GTGGCCGACGGGCTCATCACCACGCTCCATTATCCAGCCCCAAAGCGCAA     #Wildtype sequence for comparison
  #deletedSeqContext: GTGGC---------------------------------CCCAAAGCGCAA     #Visualization of deletion pattern
  #microhomology:        GC                                                  #The microhomology sequence (aligned to the sequence for comparison; actuall just char vector)
  #startDel:       6                                                         #The index of the first "-" deletion
  #endDel:         38                                                        #The index of the last "-" deletion
  #mhStart1:       4                                                         #The index of the first character in the left hand mh arm
  #mhEnd1:         5                                                         #The index of the last character in the left hand mh arm
  #mhStart2:       37                                                        #The index of the first character in the right hand mh arm
  #mhEnd2:         38                                                        #The index of the last character in the right hand mh arm
  #deletedSeq:             CGACGGGCTCATCACCACGCTCCATTATCCAGC                 #The deleted sequence (aligned to sequence for comparison)
  #delLength:      33                                                        #length of deletedSeq
  #mhLength:       2                                                         #Length of microhomology
  #GC:             1                                                         #GC content of microhomology; percentage from 0 to 1
  #distToCut:      20                                                        #Distance from the last nucleotide before the deletion to the location of the ds cut
  #outOfFrame:     0                                                         #Whether the deletion produces an out of frame mutation (0 = no, 1 = yes)
  
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
  
  
  #Get the portion of the sequence occurring after the cut site
  seqDS <- substr(seq, cutIndex, nchar(seq))
  
  #Create all possible substrings from cutsite to beginning of sequence, and search for them in sequence downstream of cutsite (identif MH)
  for(i in 1:(cutIndex-1)){
    
    for(j in i:(cutIndex-1)){
      
      #Check to make sure i is not equal to j
      if(i < j){
        
        #Generates a sliding window of possible substrings across all 
        subSeq <- substr(seq, i, j)
        
        #Finds substring locations (if they exist) in downstream sequence
        #Create a regexp search pattern with lookahead capabilities - so the with the query "CC", the sequence "CCC" would produce a match at 1 AND 2, and not just 1
        location <- stringr::str_locate_all(seqDS, paste0("(?=", subSeq, ")")) 
        #Workaround for the weird way str_locate_all handles lookahead matching
        location <- list(start = location[[1]][,2] + 1, end = location[[1]][,2] + (nchar(subSeq) - 1))
        
        #If there are 1 or more microhomology sections downstream:
        if(length(location[[1]]) != 0){
          
          #For each possible downstream instance:
          for(k in 1:length(location[[1]])){
            
            #Calculate where the deleted section will start (1 nucleotide after the end of the left hand mh section):
            delSeqStart <- j + 1
            #Calculate where the deleted section will end (index of the last character of the right hand mh section):
            delSeqEnd   <- cutIndex + location[[2]][k] - 1
            
            #Calculate the length of the deletion:
            dL <- nchar(substr(seq, delSeqStart, delSeqEnd + 1))
            
            #Create '-' spacer for deletedSeqContext
            context <- seq
            str_sub(context, delSeqStart, delSeqEnd + 1) <- paste(rep("-", dL), collapse = '')
            
            #Determine Out of Frame - is the length of the deleted sequence divisible by 3?
            if(dL %% 3 != 0){
              oof <- 1
            }else{
              oof <- 0
            }
            
            #Create a temporary data frame for the information
            tempDF <- data.frame(id                = id,
                                 seq               = seq,
                                 deletedSeqContext = context,
                                 microhomology     = subSeq,
                                 startDel          = delSeqStart,
                                 endDel            = delSeqEnd + location[[2]][k],
                                 mhStart1          = i,
                                 mhEnd1            = j,
                                 mhStart2          = cutIndex + location[[1]][k],
                                 mhEnd2            = cutIndex + location[[2]][k],
                                 deletedSeq        = substr(seq, delSeqStart, delSeqEnd + 1),
                                 delLength         = dL, 
                                 mhLength          = nchar(subSeq),
                                 GC                = sum(str_count(subSeq, c("G", "C", "g", "c")))/nchar(subSeq),
                                 distToCut         = cutIndex - delSeqStart,
                                 outOfFrame        = oof,
                                 patternScore      = exp(-dL/20)*(nchar(subSeq)+sum(str_count(subSeq, c("G", "C", "g", "c"))))*100,
                                 stringsAsFactors  = FALSE)
            
            #Add temp data frame to end of current data frame
            delFrame <- rbind(delFrame, tempDF)
          }
          
        } else {
          #If the current MH search isn't found, stop looking for longer versions including it (for efficiency)
          i <- i + 1
          
        }
      }
    }
  }
  
  #Eliminate identical rows
  delFrameU <- unique(delFrame)
  
  #Create a list of "redundant" rows - rows containing a microhomology and deletion pattern pattern wholly contained within a larger mh
  removal <- list()
  
  #Redundancy removal
  for(m in 1:nrow(delFrameU)){
    
    #Search each microhomology for the current microhomology
    hits <- grep(delFrameU$microhomology[m], delFrameU$microhomology)
    hits <- hits[which(hits!=m)]
    
    if(length(hits > 0)){
      for(n in hits){
        #Detect if the mh pattern is wholly contained within another pattern
        if((delFrameU$mhStart1[m] >= delFrameU$mhStart1[n]) && 
           (delFrameU$mhStart2[m] >= delFrameU$mhStart2[n]) && 
           (delFrameU$mhEnd1[m]   <= delFrameU$mhEnd1[n])   && 
           (delFrameU$mhEnd2[m]   <= delFrameU$mhEnd2[n])){
          
          #Detect if the deletion patterns are the same
          if(((delFrameU$mhStart1[m] - delFrameU$mhStart1[n]) == (delFrameU$mhStart2[m] - delFrameU$mhStart2[n])) && 
             ((delFrameU$mhEnd1[m]   - delFrameU$mhEnd1[n])   == (delFrameU$mhEnd2[m]   - delFrameU$mhEnd2[n]))){
            
            #If they are the same - add to the removal list
            removal <- c(removal, m)
          }
        }
      }
    }
  }
  
  #Remove redundant entries from removal list
  removal <- unlist(unique(removal))
  
  #Order for outputting nicely
  uFrame <- delFrameU[-removal,]
  uFrame1 <- uFrame[order(-nchar(uFrame$microhomology), uFrame$endDel),]
  
  return(uFrame1)
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
                            maxDelLength       = max(uFrame$delLength)/nchar(uFrame$seq),
                            minDelLength       = min(uFrame$delLength)/nchar(uFrame$seq),
                            meanDelLength      = mean(uFrame$delLength)/nchar(uFrame$seq),
                            medianDelLength    = median(uFrame$delLength)/nchar(uFrame$seq),
                            stDevDelLength     = sd(uFrame$delLength)/nchar(uFrame$seq),
                            maxMHLength        = max(uFrame$mhLength)/nchar(uFrame$seq),
                            minMHLength        = min(uFrame$mhLength)/nchar(uFrame$seq),
                            meanMHLength       = mean(uFrame$mhLength)/nchar(uFrame$seq),
                            medianMHLength     = median(uFrame$mhLength)/nchar(uFrame$seq),
                            stDevMHLength      = sd(uFrame$mhLength)/nchar(uFrame$seq),
                            maxGC              = max(uFrame$GC)/nchar(uFrame$seq),
                            minGC              = min(uFrame$GC)/nchar(uFrame$seq),
                            meanGC             = mean(uFrame$GC)/nchar(uFrame$seq),
                            medianGC           = median(uFrame$GC)/nchar(uFrame$seq),
                            stDevGC            = sd(uFrame$GC)/nchar(uFrame$seq),
                            maxDistC           = max(uFrame$distToCut)/nchar(uFrame$seq),
                            minDistC           = min(uFrame$distToCut)/nchar(uFrame$seq),
                            meanDistC          = mean(uFrame$distToCut)/nchar(uFrame$seq),
                            medianDistC        = median(uFrame$distToCut)/nchar(uFrame$seq),
                            stDevDistC         = sd(uFrame$distToCut)/nchar(uFrame$seq),
                            perOutOfFrame      = sum(uFrame$outOfFrame)/nrow(uFrame), 
                            sequenceGC         = sum(str_count(uFrame$seq[1], c("G", "C", "g", "c")))/nchar(uFrame$seq[1]),
                            mhScoreNorm        = sum(uFrame$patternScore)/nchar(uFrame$seq),
                            oofScore           = (sum(uFrame$patternScore[which(uFrame$outOfFrame == 1)])/sum(uFrame$patternScore))*100,
                            maxPatternScore    = max(uFrame$patternScore)/nchar(uFrame$seq),
                            minPatternScore    = min(uFrame$patternScore)/nchar(uFrame$seq),
                            meanPatternScore   = mean(uFrame$patternScore)/nchar(uFrame$seq),
                            medianPatternScore = median(uFrame$patternScore)/nchar(uFrame$seq),
                            stDevPatternScore  = sd(uFrame$patternScore)/nchar(uFrame$seq),
                            stringsAsFactors = FALSE)
  return(unique(returnFrame))
}



