# MEDJED
This is a repository for the MEDJED microhomology mediated end-joining repair prediction tool.

You can run MEDJED online through a web interface here: http://ll-g2f.gdcb.iastate.edu/medjed/
 

### If you already have R and/or RStudio installed, you can jump to [here](https://github.com/Dobbs-Lab/MEDJED#run-medjed-locally) to immmediately start running MEDJED locally.

### If you are having issues running MEDJED locally, please check the [Troubleshooting](https://github.com/Dobbs-Lab/MEDJED#troubleshooting) section before requesting help.
 

# [How to Run MEDJED Locally](#run-medjed-locally)
You will need to have the ability to install software on the computer you are using to run MEDJED locally; this may require administrator privileges. 

[1. Download and Install R](https://github.com/Dobbs-Lab/MEDJED#1-download-and-install-r)

[2. Download and Install RStudio](https://github.com/Dobbs-Lab/MEDJED#2-download-and-install-rstudio-optional) (optional)

[3. Run MEDJED locally](https://github.com/Dobbs-Lab/MEDJED#3-run-medjed-locally)

[Troubleshooting](https://github.com/Dobbs-Lab/MEDJED#troubleshooting)

## [1. Download and Install R](#1-download-and-install-r)
MEDJED requires the latest version of R in order to run offline. 

Download R for your appropriate operating system:

Windows: https://mirror.las.iastate.edu/CRAN/bin/windows/

 You should select the "base" option, or click "install R for the first time".
 

Mac OS: https://mirror.las.iastate.edu/CRAN/bin/macosx/

 Scroll down to the "Files" section, and find the R pkg file that lists your operating system (El Capitan, Mavericks, Snow Leopard, etc). Select the R-3.x.x.pkg file corresponding to your system - pay special attention to the "Important" section under R-3.4.3.pkg if you have "El Capitan"; you may want to consider using R-3.3.3.pkg if you don't want to install additional tools to support running R 3.4.3 on "El Capitan".


Linux/Unix: https://mirror.las.iastate.edu/CRAN/bin/linux/

 Find your Unix distro, and folow the instructions in the directory.
 

Once you have downloaded the R installer, run it to install R. You may be required to enter administrator credentials; if you do not have these credentials, talk to your institution's IT department to have them install the software.


If you need additional help installing R, please check the installation instructions for your operating system:

Windows:    https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installing-R-under-Windows

Mac OS:     https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installing-R-under-macOS

Linux/Unix: https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installing-R-under-Unix_002dalikes



## [2. Download and Install RStudio](#2-download-and-install-rstudio-optional) (optional)
MEDJED does not require the use of the RStudio development environment, but if you are interested in examining or modifying the MEDJED code, we recommend you do so in RStudio. 

You can download RStudio for free here: https://www.rstudio.com/products/rstudio/download/#download

After downloading the RStudio installer, follow the installation instructions. If you have both R and RStudio installed, you should only do the following steps in RStudio.



## [3. Run MEDJED locally](#run-medjed-locally)
You can run this RShiny web app in R (or RStudio) by opening up an R or RStudio session.

You can copy and paste the code blocks below into your R/RStudio console to run them.

(Please read [this discussion](https://www.lifehacker.com.au/2016/05/be-careful-when-you-copy-and-paste-code-from-the-internet/) on why you should not generally copy/paste/run code directly from internet pages to your console; you're probably safe on GitHub, but you should not get in the habit of copying and pasting code directly into your console or terminal windows. Paste what you've copied into NotePad or a similar program, and then copy/paste from there to your console once you know the code is safe.)



### [Run this code ONLY THE FIRST TIME you run this tool on a computer, or when you need to update these packages:](#install-code)

```
#Install packages required to run MEDJED; you can also run this code to update these packages

#Install CRAN packages
install.packages(c("shiny", "stringr", "randomForest", "ggplot2"))
```

### Run this code every time you want to use the tool, including the first time:

```
#Load Shiny in the R/RStudio Environment
library(shiny)

#Retrieve, load, and run MEDJED from GitHub
runGitHub("MEDJED", "Dobbs-Lab")
```

You're all set!
