# Use official R Shiny Server image as base
FROM rocker/shiny:4.4.3

# Install system dependencies for mermaid-cli, plotly, and R packages
RUN apt-get update && apt-get install -y \
    libfontconfig1-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    pandoc \
    curl \
    && apt-get remove -y nodejs nodejs-doc libnode-dev || true && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js v20 from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && \
    npm -v

# Install mermaid-cli globally
RUN npm install -g @mermaid-js/mermaid-cli && \
    mmdc --version

# Install additional R packages
RUN R -e "install.packages(c('rmarkdown', 'knitr', 'titanic', \
	'khroma', 'vcd', 'grid', 'ggplot2', 'remotes', 'plotly', \
	'colorspace', 'reactable', 'echarts4r', 'paletteer'), \
	repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('kweinert/shiny.gems')"
RUN R -e "if (!require('plotly')) stop('plotly not installed')"

# Copy Shiny app files
COPY ./inst/examples /srv/shiny-server/

# Expose Shiny server port
EXPOSE 3838

# Start Shiny server
CMD ["/usr/bin/shiny-server", "--log-level=DEBUG"]
