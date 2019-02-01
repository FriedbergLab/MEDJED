
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(
  
  #Creates the navbar set-up
  navbarPage(
    id          = 'mainPage',
    windowTitle = "MEDJED",
    
    #Stylesheet
    theme = "ogtheme.css", 
    
    #Page title box
    tags$div("MEDJED v1.1.2", 
             style = "color:white"),
    
    ########ABOUT TAB#################################################
    tabPanel(tags$div("About"),
             titlePanel(""),
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href   = "http://ll-g2f.gdcb.iastate.edu/gss/", 
                                    target = "_blank", tags$img(src = "GSS logo small.png",                width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.iastate.edu/",   
                                    target = "_blank", tags$img(src = "isu-logo-alt.png",                  width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.mayoclinic.org", 
                                    target = "_blank", tags$img(src = "MC_stack_4c_DAC.png",               width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.genomewritersguild.org/", 
                                    target = "_blank", tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://github.com/Dobbs-Lab/MEDJED",
                                    target = "_blank", tags$img(src = "GitHub_Logo.png",                   width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://hub.docker.com/r/cmmann/medjed", 
                                    target = "_blank", tags$img(src = "Docker_Logo.png",                   width = "100%"))))
             )),
             
             #Text area in center of page
             column(9, wellPanel(
               
               #Display page instructions
               includeHTML("www/about.html")
             ))
    ),
    
    ##########SUBMIT JOB TAB###################################
    tabPanel(id = "predict",
             tags$div("Submit"),
             titlePanel(""),
             
             ##Sidebar############################################################
             #Adds a sidebar for users to pre-populate fields with an example, and reset the form
             column(2, wellPanel(
               class = "examplePanel",
               #Cut/Paste cDNA example; input$example
               actionLink("example", label = "[Example Input]"),
               
               tags$br(),
               tags$br(),
               
               #Reset Button; input$reset
               actionLink("reset",   label = "Reset Form")
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
               h3("Submit Sequence to MEDJED"),
               p(paste0("Input your target sequence of interest (we recommend 50-80 bases, but you can input up to 200. ", 
                        "Your sequence must have an even number of nucleotides, with the cut site occurring between the middle-most nucleotides. ")),
               p("For example, the sequence below consists of 50 nucleotides, and the expected cut site (lightning bolt) occurs between bases 25 and 26."),
               
               img(src = "helpImage.png", width = "100%"),
               
               p("Use the 'Example' link in the panel to the left to pre-populate the form with this example sequence."),
               textAreaInput("targetSeq",
                             label = "",
                             value = "",
                             placeholder = "Paste target sequence here..."),
               
               #),
               
               textOutput("validTargetSeq"),
               
               #Submit button
               actionButton("submit", label = "Submit"),
               tags$br(),
               tags$br(),
               p("Your target sequence: "),
               uiOutput("targetSequence"),
               tags$br(),
               textOutput("predictionPercentage")
             ))
    ),
    
    ##########FUNDING Tab#############################################
    tabPanel(
      tags$div("Funding"),
      titlePanel(""),
      
      #Sidebar panel with links
      column(2, wellPanel(
        #Sidebar panel with links
        tags$div(tags$span(a(href   = "http://ll-g2f.gdcb.iastate.edu/gss/", 
                             target = "_blank", tags$img(src = "GSS logo small.png",                width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.iastate.edu/",   
                             target = "_blank", tags$img(src = "isu-logo-alt.png",                  width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.mayoclinic.org", 
                             target = "_blank", tags$img(src = "MC_stack_4c_DAC.png",               width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.genomewritersguild.org/", 
                             target = "_blank", tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://github.com/Dobbs-Lab/MEDJED",
                             target = "_blank", tags$img(src = "GitHub_Logo.png",                   width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://hub.docker.com/r/cmmann/medjed", 
                             target = "_blank", tags$img(src = "Docker_Logo.png",                   width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href = "https://www.nih.gov/", 
                             target = "_blank", tags$img(src = "nihlogo.png",                       width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href = "https://dill-picl.org", 
                             target = "_blank", tags$img(src = "lawlab_web_wiki_header.png",        width = "100%"))))
      )),
      
      column(9, wellPanel(
        includeHTML("www/funding.html")
      ))
    ),
    
    ##########HOW TO CITE Tab#########################################
    tabPanel(tags$div("How to Cite"),
             titlePanel(""),
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href   = "http://ll-g2f.gdcb.iastate.edu/gss/", 
                                    target = "_blank", tags$img(src = "GSS logo small.png",                width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.iastate.edu/",   
                                    target = "_blank", tags$img(src = "isu-logo-alt.png",                  width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.mayoclinic.org", 
                                    target = "_blank", tags$img(src = "MC_stack_4c_DAC.png",               width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.genomewritersguild.org/", 
                                    target = "_blank", tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://github.com/Dobbs-Lab/MEDJED",
                                    target = "_blank", tags$img(src = "GitHub_Logo.png",                   width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://hub.docker.com/r/cmmann/medjed", 
                                    target = "_blank", tags$img(src = "Docker_Logo.png",                   width = "100%"))))
             )),
             
             #Text area in center of page
             column(9, wellPanel(
               p("Manuscript is in prep. Citation will be available soon."))
             )
    ),
    
    ##########CONTACT US Tab##########################################
    tabPanel(tags$div("Report Bugs or Contact Us"),
             titlePanel(""),
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href   = "http://ll-g2f.gdcb.iastate.edu/gss/", 
                                    target = "_blank", tags$img(src = "GSS logo small.png",                width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.iastate.edu/",   
                                    target = "_blank", tags$img(src = "isu-logo-alt.png",                  width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.mayoclinic.org", 
                                    target = "_blank", tags$img(src = "MC_stack_4c_DAC.png",               width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://www.genomewritersguild.org/", 
                                    target = "_blank", tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://github.com/Dobbs-Lab/MEDJED",
                                    target = "_blank", tags$img(src = "GitHub_Logo.png",                   width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href   = "https://hub.docker.com/r/cmmann/medjed", 
                                    target = "_blank", tags$img(src = "Docker_Logo.png",                   width = "100%"))))
             )),
             
             #Text area in center of page
             column(9, 
                    wellPanel(
                      p("Please use the form below, or email us directly at GeneSculptSuite@gmail.com, to report issues and request support.")
                    ),
                    
                    tags$iframe(id           = "googleform", 
                                src          = paste0("https://docs.google.com/forms/d/e/1FAIpQLSeq9aDRj6EOCskBwPsA2PFQ2LsKxT4v85-rGTlYQOk0n8X2Gw/",
                                                      "viewform?usp=pp_url&entry.358268393&entry.1646278736=MEDJED&entry.1934309806&entry.",
                                                      "565411344&entry.754537383&entry.826100992"),
                                width        = 760,
                                height       = 2000,
                                frameborder  = 0,
                                marginheight = 0)
             )
    ),
    
    ##########Changelog#############################################
    tabPanel(
      tags$div("Changelog"),
      titlePanel(""),
      
      #Sidebar panel with links
      column(2, wellPanel(
        tags$div(tags$span(a(href   = "http://ll-g2f.gdcb.iastate.edu/gss/", 
                             target = "_blank", tags$img(src = "GSS logo small.png",                width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.iastate.edu/",   
                             target = "_blank", tags$img(src = "isu-logo-alt.png",                  width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.mayoclinic.org", 
                             target = "_blank", tags$img(src = "MC_stack_4c_DAC.png",               width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://www.genomewritersguild.org/", 
                             target = "_blank", tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://github.com/Dobbs-Lab/MEDJED",
                             target = "_blank", tags$img(src = "GitHub_Logo.png",                   width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href   = "https://hub.docker.com/r/cmmann/medjed", 
                             target = "_blank", tags$img(src = "Docker_Logo.png",                   width = "100%"))))
      )),
      
      column(9,
             wellPanel(
               includeHTML("www/changelog.html")
             )
      )
    )
  )
)
