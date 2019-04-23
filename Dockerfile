FROM openanalytics/r-base

MAINTAINER Carla Mann "genesculptsuitehelp@gmail.com"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0

# install package dependencies for MEDJED
RUN R -e "install.packages(c('shiny', 'stringr', 'randomForest', 'ggplot2', 'DT'), repos='https://cloud.r-project.org/')" -e 'source("http://bioconductor.org/biocLite.R")' -e 'biocLite("Biostrings")'

# Copy MEDJED to image
RUN mkdir /root/medjed/
COPY / /root/medjed

COPY Rprofile.site /usr/lib/R/etc/

#Expose this port
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/medjed/', port = 3838)"]
