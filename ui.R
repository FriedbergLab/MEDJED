
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)

shinyUI(
  
  #Creates the navbar set-up
  navbarPage(id = 'mainPage',
             #Stylesheet
             theme = "ogtheme.css", 
             #theme = "C:/Users/cmmann/Downloads/iastate-theme-1.4.67/iastate-theme/css/base.css",
             
             #Page title box
             tags$div("MEDJED v1.0.0", 
                      style = "color:white"),
             
             
             ########ABOUT TAB#################################################
             tabPanel(tags$div("About MEDJED", style = "color:white"),
                      titlePanel(""),
                      
                        
                        #Sidebar panel with links
                        column(2,
                               wellPanel(
                          tags$div(tags$span(a(href = "https://www.iastate.edu/", tags$img(src = "isulogo.jpg", width = "90%")))),
                          p(""),
                          tags$div(tags$span(a(href = "https://www.mayoclinic.org", tags$img(src = "mayoclinic.jpeg", width = "50%"))))
                        )),
                        
                        #Text area in center of page
                        column(9, wellPanel(

                          #Display page instructions
                          includeHTML("www/about.html")
                        )
                      )
             ),
             
             ##########SUBMIT JOB TAB###################################
             tabPanel(id = "predict",
                      tags$div("Predict MMEJ Outcomes", style = "color:white"),
                      titlePanel(""),
                      
                      ##Sidebar############################################################
                      #Adds a sidebar for users to pre-populate fields with an example, and reset the form
                      column(2, wellPanel(
                        
                        #Cut/Paste cDNA example; input$example
                        actionLink("example", 
                                   label = "Example"),
                        
                        p(""),
                        
                        #Reset Button; input$reset
                        actionLink("reset", 
                                   label = "Reset Form")
                      )),
                      
                      
                      ####Main Bar#########################################################
                      #Main panel for entering information and submitting job
                      column(9, wellPanel(
                        #Input for target sequence
                        #p("Do you want to..."),
                        #radioButtons("outcomeOp", label = "", choices = list("Identify CRISPR sites within a gene predicted to undergo high MMEJ repair" = 1,
                        #                                                     "Predict MMEJ percentage for a given target site" = 2)),
                        #conditionalPanel(
                        #  condition = "input.outcomeOp == 1",
                        #  
                        #  p("Paste your gene sequence of interest, in PLAIN TEXT format: "),
                        #  textAreaInput("inputGene",
                        #                label = "",
                        #                value = "",
                        #                placeholder = "Paste gene sequenece here...")
                        #),
                        #conditionalPanel(
                        #  condition = "input.outcomeOp == 2",
                          p(paste0("Input your target of interest.", 
                                   "The cut site should occur in the exact center of the sequence.")),

                          p(paste0("Example:")),
                          p("There are 25 bp upstream of the cut site (denoted by \"|\") and 25 bp downstream."),
                          p(tags$div(HTML("GAGGACAGGAAAACGGACGTAGCTG<b>|</b>AAC<b>AGG</b>TGCTAGTCGATGCTGATCGT"))),
                          textAreaInput("targetSeq",
                                        label = "",
                                        value = "",
                                        placeholder = "Paste target sequence here..."),
                        #),
                        
                        
                        
                        
                        textOutput("validTargetSeq"),
                        
                        #Submit button
                        actionButton("submit", label = "Submit"),
                        p(""),
                        p("Your target sequence: "),
                        textOutput("targetSequence"),
                        p(""),
                        #p("MEDJED predicted percentage of MMEJ events for this target: "),
                        textOutput("predictionPercentage")
                        
                      ))
                     
             ),
             
             
             ##########HOW TO CITE Tab#########################################
             tabPanel(tags$div("How to Cite", style = "color:white"),
                      titlePanel(""),
                      
                      
                      #Sidebar panel with links
                      column(2,
                             wellPanel(
                               tags$div(tags$span(a(href = "https://www.iastate.edu/", tags$img(src = "isulogo.jpg", width = "90%")))),
                               p(""),
                               tags$div(tags$span(a(href = "https://www.mayoclinic.org", tags$img(src = "mayoclinic.jpeg", width = "50%"))))
                             )),
                      
                      #Text area in center of page
                      column(9, wellPanel(
                        p("When the paper is published, citation goes here..."))
                      )
             ),
             
             ##########CONTACT US Tab##########################################
             tabPanel(tags$div("Contact Us", style = "color:white"),
                      titlePanel(""),
                      
                      
                      #Sidebar panel with links
                      column(2,
                             wellPanel(
                               tags$div(tags$span(a(href = "https://www.iastate.edu/", tags$img(src = "isulogo.jpg", width = "90%")))),
                               p(""),
                               tags$div(tags$span(a(href = "https://www.mayoclinic.org", tags$img(src = "mayoclinic.jpeg", width = "50%"))))
                             )),
                      
                      #Text area in center of page
                      column(9, wellPanel(
                        p("Please contact us at MEDJEDHelp@gmail.com to report issues and request support."),
                        p("A standalone version of this code may be downloaded at https://github.com/Dobbs-Lab/MEDJED. The R code is provided as-is. You are free to use it in non-commercial applications, provided you cite the authors. Please be aware that you modify the code at your own risk; we are unable to provide support for modified versions.")
                      ))
             ),
             
             ##########FUNDING Tab#############################################
             tabPanel(
               tags$div("Funding", style = "color:white"),
               titlePanel(""),
               #Sidebar panel with links
               column(2,
                 wellPanel(
                 tags$html(tags$div(tags$span(a(href = "https://www.iastate.edu/", "Iowa State University"))),
                           tags$div(tags$span(a(href = "https://www.mayoclinic.org/", "The Mayo Clinic"))),
                           tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", target = "_blank", "Genome Writers Guild"))),
                           tags$div(tags$span(a(href = "https://dill-picl.org", "Dill-PICL Lab"))),
                           tags$div(tags$span(a(href = "https://www.nih.gov/", "National Institutes of Health (NIH)")))
                 ))
               ),
               
               column(9,
                      wellPanel(
               tags$p("This project was funded through NIH R24 OD020166 and is a joint effort by Iowa State University and The Mayo Clinic."),
               tags$p("This server is generously hosted by the", a(href = "https://dill-picl.org/", 'Dill-PICL Lab'), "at Iowa State University.")
                      )
               
               )),
             ##########FUNDING Tab#############################################
             tabPanel(
               tags$div("Changelog", style = "color:white"),
               titlePanel(""),
               #Sidebar panel with links
               column(2,
                      wellPanel(
                        tags$html(tags$div(tags$span(a(href = "https://www.iastate.edu/", "Iowa State University"))),
                                  tags$div(tags$span(a(href = "https://www.mayoclinic.org/", "The Mayo Clinic"))),
                                  tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", target = "_blank", "Genome Writers Guild"))),
                                  tags$div(tags$span(a(href = "https://dill-picl.org", "Dill-PICL Lab"))),
                                  tags$div(tags$span(a(href = "https://www.nih.gov/", "National Institutes of Health (NIH)")))
                        ))
                        
               ),
               
               column(9,
                      wellPanel(
                        includeHTML("www/changelog.html")
                      )
                      
               )
             )
  )
)
  