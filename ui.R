
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(
  
  #Creates the navbar set-up
  navbarPage(
    id = 'mainPage',
    windowTitle = "MEDJED",
    
    #Stylesheet
    theme = "ogtheme.css", 
    #theme = "C:/Users/cmmann/Downloads/iastate-theme-1.4.67/iastate-theme/css/base.css",
    
    #Page title box
    tags$div("MEDJED v1.0.1", 
             style = "color:white"),
    
    
    ########ABOUT TAB#################################################
    tabPanel(tags$div("About MEDJED", style = "color:white"),
             titlePanel(""),
             
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href = "http://ll-g2f.gdcb.iastate.edu/gss/", target = "_blank", tags$img(src = "GSS logo small.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.iastate.edu/",   target = "_blank", tags$img(src = "isu-logo-alt.png",     width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.mayoclinic.org", target = "_blank", tags$img(src = "MC_stack_4c_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", 
                                    target = "_blank", 
                                    tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%"))))
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
               p(paste0("Input your target sequence of interest.", 
                        "Your sequence must have an even number of nucleotides, with the cut site occurring between the middle-most nucleotides.")),
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
               p(""),
               p("Your target sequence: "),
               textOutput("targetSequence"),
               p(""),
               #p("MEDJED predicted percentage of MMEJ events for this target: "),
               textOutput("predictionPercentage")
               
             ))
             
    ),
    
    ##########FUNDING Tab#############################################
    tabPanel(tags$div("Funding", style = "color:white"),
             titlePanel(""),
             #Sidebar panel with links
             column(2, wellPanel(
               #Sidebar panel with links
               tags$div(tags$span(a(href = "http://ll-g2f.gdcb.iastate.edu/gss/", target = "_blank", tags$img(src = "GSS logo small.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.iastate.edu/",   target = "_blank", tags$img(src = "isu-logo-alt.png",     width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.mayoclinic.org", target = "_blank", tags$img(src = "MC_stack_4c_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", 
                                    target = "_blank", 
                                    tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.nih.gov/", target = "_blank", tags$img(src = "nihlogo.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://dill-picl.org", target = "_blank", tags$img(src = "lawlab_web_wiki_header.png", width = "100%"))))
             )),
             
             #Text area in center of page
             column(9, wellPanel(
               tags$p("This webtool was created and is maintained by funding through ", a(href = "https://projectreporter.nih.gov/project_info_description.cfm?aid=9276155&icde=37715852", target = "_blank", 'NIH R24 OD020166: Development of Tools for Site-directed Analysis of Gene Function'), " and is a joint effort by ", a(href = "https://www.iastate.edu/", target = "_blank", 'Iowa State University'), " and ", a(href = "https://www.mayoclinic.org/", target = "_blank", " The Mayo Clinic.")),
               tags$p("This server is generously hosted by the", a(href = "https://dill-picl.org/", target = "_blank", 'Lawrence-Dill Plant Informatics and Computation (Dill-PICL) Lab'), "at Iowa State University.")
             ),
             
             wellPanel(
               p("Project abstract: "),
               p("The overarching goal of this application is to create tools and efficient methods to define genes that can promote human health. While a tremendous amount of data has been cataloged on gene mutation and changes in gene expression associated with complex human disease, our understanding of those genes that could be co-opted to restore patient health is lacking. To address this need and test for genes that when restored to wild type function promote health, we propose develop mutagenic, revertible and conditional alleles that provide spatial and temporal control of gene expression. The ability to make site-specific, untagged mutant alleles in zebrafish and other models has been greatly advanced by custom nucleases that include TALENs and CRISPR/Cas9 systems. These systems operate on the same principle: they are designed to bind to specific sequences in the genome and create a double strand break. The goals of this proposal leverage the activities of TALEN and CRISPR/Cas9 technologies to make site-specific double strand breaks. First, we propose to develop a suite of vectors to make integration alleles that are highly mutagenic and allow production of conditional and revertible alleles. Second, we propose to develop methods to generate predictable alleles in zebrafish at TALEN- and CRISPR/Cas9-induced double strand break sites by invoking the microhomology mediated end-joining pathway. Third, leveraging our preliminary data, we propose to improve methods for homology directed repair with oligonucleotides to create disease associated alleles in zebrafish and for site-specific integration using homologous recombination at TALENs and CRISPR/Cas9 cut sites. Fourth, we propose use single-strand annealing at TALENs and CRISPR/Cas9 cut sites to promote precise transgene integration to make tagged and highly mutagenic allele. These tools and techniques will have direct implications for providing precise gene editing techniques to assess the roles of genes in disease and their ability to promote health following disease progression. While we will develop these methodologies in zebrafish due to their ease of gene delivery, we anticipate these methodologies will not only enhance the efficiency of gene editing but will be readily adaptable for use in other model organisms and large animals. In our opinion, this will have important implications for modeling human disease and health in animal systems by greatly enhancing the ability to make predictible alleles, small nucleotide polymorphisms similar to those associated with human disease, and conditional alleles to test for the ability of a gene to restore health.")
             ))
    ),
    ##########HOW TO CITE Tab#########################################
    tabPanel(tags$div("How to Cite", style = "color:white"),
             titlePanel(""),
             
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href = "http://ll-g2f.gdcb.iastate.edu/gss/", target = "_blank", tags$img(src = "GSS logo small.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.iastate.edu/",   target = "_blank", tags$img(src = "isu-logo-alt.png",     width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.mayoclinic.org", target = "_blank", tags$img(src = "MC_stack_4c_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", 
                                    target = "_blank", 
                                    tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%"))))
             )),
             
             #Text area in center of page
             column(9, wellPanel(
               p("When the paper is published, citation goes here..."))
             )
    ),
    
    ##########CONTACT US Tab##########################################
    tabPanel(tags$div("Report Bugs or Contact Us", style = "color:white"),
             titlePanel(""),
             
             #Sidebar panel with links
             column(2, wellPanel(
               tags$div(tags$span(a(href = "http://ll-g2f.gdcb.iastate.edu/gss/", target = "_blank", tags$img(src = "GSS logo small.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.iastate.edu/",   target = "_blank", tags$img(src = "isu-logo-alt.png",     width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.mayoclinic.org", target = "_blank", tags$img(src = "MC_stack_4c_DAC.png", width = "100%")))),
               tags$br(),
               tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", 
                                    target = "_blank", 
                                    tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%"))))
             )),
             
             
             #Text area in center of page
             column(9, 
                    wellPanel(
                      p("Please use the form below, or email us directly at GeneSculptSuite@gmail.com, to report issues and request support.")
                    ),
                    
                    tags$iframe(id = "googleform", 
                                src = "https://docs.google.com/forms/d/e/1FAIpQLSeq9aDRj6EOCskBwPsA2PFQ2LsKxT4v85-rGTlYQOk0n8X2Gw/viewform?usp=pp_url&entry.358268393&entry.1646278736=MEDJED&entry.1934309806&entry.565411344&entry.754537383&entry.826100992",
                                width = 760,
                                height = 2000,
                                frameborder = 0,
                                marginheight = 0)
                    
             )
    ),
    
    
    ##########Changelog#############################################
    tabPanel(
      tags$div("Changelog", style = "color:white"),
      titlePanel(""),
      #Sidebar panel with links
      column(2, wellPanel(
        tags$div(tags$span(a(href = "http://ll-g2f.gdcb.iastate.edu/gss/", target = "_blank", tags$img(src = "GSS logo small.png", width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href = "https://www.iastate.edu/",   target = "_blank", tags$img(src = "isu-logo-alt.png",     width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href = "https://www.mayoclinic.org", target = "_blank", tags$img(src = "MC_stack_4c_DAC.png", width = "100%")))),
        tags$br(),
        tags$div(tags$span(a(href = "https://www.genomewritersguild.org/", 
                             target = "_blank", 
                             tags$img(src = "genome-writers-guild-logo_DAC.png", width = "100%"))))
      )),
      
      column(9,
             wellPanel(
               includeHTML("www/changelog.html")
             )
             
      )
    )
  )
)
