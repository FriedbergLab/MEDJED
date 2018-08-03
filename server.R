library(shiny)
library(stringr)
library(randomForest)
library(ggplot2)

source("requiredFunctions.R")

shinyServer(function(input, output, session) {
  
  #Load medjedModel
  medjedModel <- readRDS("medjedModel2017-07-12.rds")
  
  ####VALIDATION: ####
  #Check validity of input target sequence
  validTargetSeq <- reactive({
    if(!is.null(input$targetSeq)){
      validate(
        need(!str_detect(toupper(input$targetSeq), "[^ACGT]"), 
             paste0("Error: Input target sequence contains non-standard nucleotides. ",
                    "Allowed nucleotides are A, C, G, and T.")
        )
      )
      
      if((nchar(input$targetSeq) %% 2) != 0){
        validate(
          need((nchar(input$targetSeq) %% 2) == 0,
               paste0("Error: There are ", 
                      nchar(input$targetSeq), 
                      " nucleotides in the pasted sequence. ",
                      "There must be an even number of nucleotides in the input sequence."))
        )
        
      } else if(input$targetSeq == ""){
        validate(
          need(input$targetSeq != "", paste0(""))
        )
        
      } else {
        validate(

          need(nchar(input$targetSeq) <= 200,
               paste0("Error: Please input 200 or less nucleotides of context. We recommend 50-80 bp.")
          ),
          
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
    if(is.null(validTargetSeq())){
      delFrame <- findDeletionsRevised("inputSequence", input$targetSeq)
      fv <- generateFeatureVector(delFrame)
    }
    
    prediction <- randomForest:::predict.randomForest(medjedModel, fv[, c(4, 8, 10, 12, 27, 31)], type = "response")
    
    printPrediction(prediction)
  })
  
  ####Print Outputs: ####
  printPrediction <- function(prediction){
    
    output$targetSequence <- renderUI({
      HTML(paste("<p style = 'word-wrap: break-word;'>", input$targetSeq, "</p>"))
    })
    
    output$predictionPercentage <- renderText({
      paste0("MEDJED predicts ", format(round(prediction*100, 2), nsmall = 2), "% of deletion events for this target sequence will be due to MMEJ repair.")
    })
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
  }
  
  resetOutputs <- function(){
    #Clear the output regions
    output$predictionPercentage <- renderText({
      ""
    })
  }
})
