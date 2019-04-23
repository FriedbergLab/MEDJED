library(shiny)
library(stringr)
library(randomForest)
library(DT)
library(ggplot2)

source("requiredFunctions.R")

shinyServer(function(input, output, session) {
  
  showOutput <<- FALSE
  
  rValues <- reactiveValues(downloadF       = FALSE,
                            deletionTable   = FALSE,
                            predictorTable  = FALSE,
                            predictionTable = FALSE,
                            systemTime      = FALSE,
                            zipFile         = FALSE)
  
  #Load medjedModel
  medjedModel <- readRDS("medjedModel2017-07-12.rds")
  
  ####VALIDATION: ####
  #Check validity of input target sequence
  validTargetSeq <- reactive({
    if(!is.null(input$targetSeq)){
      validate(
        # Only allow A, C, G, and T
        need(!str_detect(toupper(input$targetSeq), "[^ACGT]"), 
             paste0("Error: Input target sequence contains non-standard nucleotides. ",
                    "Allowed nucleotides are A, C, G, and T.")
        )
      )
      
      # Error message to catch an odd number of nucleotides
      if((nchar(input$targetSeq) %% 2) != 0){
        validate(
          need((nchar(input$targetSeq) %% 2) == 0,
               paste0("Error: There are ", 
                      nchar(input$targetSeq), 
                      " nucleotides in the pasted sequence. ",
                      "There must be an even number of nucleotides in the input sequence."))
        )
        
        # Don't do anything if the box is empty
      } else if(input$targetSeq == ""){
        validate(
          need(input$targetSeq != "", paste0(""))
        )
        
      } else {
        validate(
          
          # Limit the input size
          need(nchar(input$targetSeq) <= 200,
               paste0("Error: Please input 200 or fewer nucleotides of context. We recommend 50-80 bp.")
          ),
          
          # Limit the input size
          need(nchar(input$targetSeq) >= 20,
               paste0("Error: Not enough sequence context to perform calculations. Please input at least 20 nucleotides."))
        )
      }
    }
  })
  
  output$validTargetSeq <- renderText({
    validTargetSeq()
  })
  
  ####FUNCTION CALLS: ####
  observeEvent(input$submit, {
    
    # Generate the deletion patterns and derive the features needed to make predictions on the input sequence
    if(is.null(validTargetSeq())){
      resetOutputs()
      delFrame <- findDeletionsRevised("inputSequence", stripNewLines(input$targetSeq))
      fv <- generateFeatureVector(delFrame)
    }
    
    rValues$systemTime <- Sys.time()

    rValues$zipFile <- gsub("CDT", "", gsub(" ", "_", gsub(":", "_", rValues$systemTime)))
    
    # Make predictions using the medjed model on the new input sequence
    prediction <- randomForest:::predict.randomForest(medjedModel, fv[, c(4, 8, 10, 12, 27, 31)], type = "response")
    
    # Generate a table to output the deletion patterns
    outTable <- delFrame[c("microhomology", "mhLength", "delLength", "deletedSeqContext")]
    
    # Set the download flag to true
    rValues$downloadF <- TRUE
    showOutput <<- TRUE
    rValues$predictionTable <- data.frame("Input Sequence"    = input$targetSeq,
                                          "MEDJED Prediction" = prediction,
                                          stringsAsFactors    = FALSE)
    
    rValues$predictorTable <- fv[,c(4,8,10,12,27,31)]
    rValues$predictorTable <- cbind(data.frame("Input Sequence" = input$targetSeq, stringsAsFactors = FALSE), 
                                    rValues$predictorTable,
                                    data.frame("MEDJED Prediction" = prediction, stringsAsFactors = FALSE))
    names(rValues$predictorTable) <- c("Target Sequence", "Minimum DL", "Maximum ML", "Mean ML", "Standard Deviation of ML", "Maximum PS", "Standard Deviation of PS", "MEDJED Prediction")
    
    # Create a data frame to hold the wildtype sequence
    wtRow <- data.frame(microhomology = "Wildtype",
                        mhLength = 0,
                        delLength = 0,
                        deletedSeqContext = delFrame$seq[1])
    
    # Add the wt sequence to the deletion table
    deletionTable <- rbind(wtRow, outTable)
    
    # Rename the columns in the deletion Table
    names(deletionTable) <- c("Microhomology", "MH Length", "Del. Length", "Del. Pattern")
    
    rValues$deletionTable <- deletionTable
    
    # Output the prediction and the deletion table
    printPrediction(prediction)
    printPredictors(fv[,c(4,8,10,12,27,31)])
    printDataTable(deletionTable)
    
  })
  
  
  ####Print Outputs: ####
  printPrediction <- function(prediction){
    
    if(rValues$downloadF){
      output$targetSequence <- renderUI({
        HTML(paste("<p style = 'word-wrap: break-word;'>", input$targetSeq, "</p>"))
      })
      
      output$predictionPercentage <- renderText({
        paste0("MEDJED predicts ", format(round(prediction*100, 2), nsmall = 2), "% of deletion events for your target sequence will be due to MMEJ repair.")
      })
    } else {
      output$targetSequence <- renderUI({
        ""
      })
      
      output$predictionPercentage <- renderText({
        ""
      })
    }

  }
  
  # Print predictor table
  printPredictors <- function(fv){
    
    if(rValues$downloadF){
      names(fv) <- c("Minimum DL", "Maximum ML", "Mean ML", "Standard Deviation of ML", "Maximum PS", "Standard Deviation of PS")
      fv[,1:6] <- round(fv[,1:6], 4)
      
      # Make the output table
      outFeat <- datatable(fv, 
                           rownames = FALSE, 
                           options = list(columnDefs     = list(list(className = 'dt-center', 
                                                                     targets   = "_all"),
                                                                list(className = 'dt-head-center',
                                                                     targets   = "_all")),
                                          scrollX        = TRUE,
                                          scrollCollapse = TRUE,
                                          "pageLength"   = 100,
                                          sDom = 't'))
      
      # Output the data table
      output$predictors <- DT::renderDataTable(outFeat,
                                               escape   = FALSE)
      
      # Output the data table
      DT::dataTableOutput("predictors")
    } else {
      # Output the data table
      output$predictors <- DT::renderDataTable(NULL)
      
      # Output the data table
      DT::dataTableOutput("predictors")
    }

    
  }
  
  # Print the deletion table
  printDataTable <- function(outTable){
    
    if(rValues$downloadF){
      # Make the output table
      delTable <- datatable(outTable, 
                            rownames = FALSE, 
                            options = list(columnDefs     = list(list(className = 'dt-center', 
                                                                      targets   = "_all")),
                                           scrollX        = TRUE,
                                           scrollCollapse = TRUE,
                                           "pageLength"   = nrow(outTable)),
                            class = "nowrap display")
      
      
      # Output the data table
      output$deletionTable <- DT::renderDataTable(delTable,
                                                  escape   = FALSE)
      
      
      # Output the data table
      DT::dataTableOutput("deletionTable")
    } else {
      output$deletionTable <- DT::renderDataTable(NULL)
      
      DT::dataTableOutput("deletionTable")
    }

    
  }
  
  ####EXAMPLE: ####
  observeEvent(input$example, {
    #Clear inputs/outputs
    reset()
    
    #Input an example into the text box
    updateTextInput(session, "targetSeq", value = "GAGGACAGGAAAACGGACGTAGCTGAACAGGTGCTAGTCGATGCTGATCG")
  })
  
  ####Reset Functions: ####
  #Clear the form
  observeEvent(input$reset, {
    reset()
  })
  
  #Reset function
  reset <- function(){
    #Reset the input to its default value
    updateTextInput(session, "targetSeq", value = NA)

    
    #Clear the output boxes
    resetOutputs()
    
    showOutput <<- FALSE
  }
  
  resetOutputs <- function(){
    
    #Clear the output regions
    output$predictionPercentage <- renderText({
      ""
    })
    
    #output$predictors <- renderText({
    #  ""
    #})
    
    #output$deletionTable <- renderText({
    #  ""
    #})
    
    rValues$downloadF       <- FALSE
    rValues$deletionTable   <- FALSE
    rValues$predictorTable  <- FALSE
    rValues$predictionTable <- FALSE
    rValues$systemTime      <- FALSE
    rValues$zipFile         <- FALSE
    
    printPrediction("")
    printPredictors("")
    printDataTable("")
  }
  
  #### Download Handling ####
  
  #### Download Deletion Table ####
  output$downloadDelTable <- renderUI({
    if(rValues$downloadF){
      downloadButton("downRes", "Download Microhomology Deletion Pattern Table")
    } else {
      ""
    }
  })
  
  output$downRes <- downloadHandler(
    filename = function(){
      #Name file in the form "YYYY-MM-DD_HH-MM-SS_MEDJED_Deletion_Patterns.csv
      paste0(gsub("CDT", "", gsub(" ", "_", rValues$systemTime)), "_MEDJED_Deletion_Patterns.csv")
    },
    
    content = function(file){
      
      # Output the file
      write.table(rValues$deletionTable, file, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")
      
    }
  )
  
  #### Download Prediction ####
  output$downloadPrediction <- renderUI({
    if(rValues$downloadF){
      downloadButton("downPrediction", "Download MEDJED Prediction")
    } else {
      ""
    }
  })
  
  output$downPrediction <- downloadHandler(
    filename = function(){
      #Name file in the form "YYYY-MM-DD_HH-MM-SS_MEDJED_Deletion_Patterns.csv
      paste0(gsub("CDT", "", gsub(" ", "_", rValues$systemTime)), "_MEDJED_Prediction.csv")
    },
    
    content = function(file){
      
      # Output the file
      write.table(rValues$predictionTable, file, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")
      
    }
  )
  
  #### Download Predictors ####
  output$downloadPredictorTable <- renderUI({
    if(rValues$downloadF){
      downloadButton("downPredictorTable", "Download MEDJED Predictor Values")
    } else {
      ""
    }
  })
  
  output$downPredictorTable <- downloadHandler(
    filename = function(){
      #Name file in the form "YYYY-MM-DD_HH-MM-SS_MEDJED_Deletion_Patterns.csv
      paste0(gsub("CDT", "", gsub(" ", "_", rValues$systemTime)), "_MEDJED_Predictors.csv")
    },
    
    content = function(file){
      
      # Output the file
      write.table(rValues$predictorTable, file, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")
      
    }
  )
  
  #### Download all output ####

  output$downloadAll <- renderUI({
    if(rValues$downloadF){
      downloadButton("downAll", "Download All Outputs")
    } else {
      ""
    }
  })
  
  output$downAll <- downloadHandler(
    filename = function(){
      #Name file in the form "YYYY-MM-DD_HH-MM-SS_MEDJED_Outputs.zip
      paste0(rValues$zipFile, "_MEDJED_Outputs.zip")
    },
    content = function(file){

      file1 <- paste0(rValues$zipFile, "_MEDJED_Deletion_Patterns.csv")
      write.table(rValues$deletionTable, file1, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")
      
      file2 <- paste0(rValues$zipFile, "_MEDJED_Prediction.csv")
      write.table(rValues$predictionTable, file2, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")
      
      file3 <- paste0(rValues$zipFile, "_MEDJED_Predictors.csv")
      write.table(rValues$predictorTable, file3, row.names = FALSE, col.names = TRUE, append = FALSE, quote = FALSE, sep = ",")


      zip(file, c(file1, file2, file3))
    }
  )
  
  #### Conditional output display ####
  
  output$showOutput <- reactive({
    if(rValues$downloadF){
      TRUE
    } else {
      FALSE
    }
  })
  
  outputOptions(output, "showOutput", suspendWhenHidden = FALSE)
  
})
