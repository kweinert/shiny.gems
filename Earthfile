VERSION 0.8
FROM rocker/r-ver:4.3.2  # Offizielles R-Docker-Image mit R 4.3.2

WORKDIR /app

# Installiere grundlegende R-Tools für Paketentwicklung
install-deps:
    RUN apt-get update && apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev
    RUN R -e "install.packages(c('devtools', 'roxygen2'), repos='https://cran.r-project.org')"

# Kopiere dein R-Paket (falls schon vorhanden)
copy-source:
    COPY . /app
    SAVE ARTIFACT /app AS LOCAL ./output

# Beispiel: Baue und teste ein R-Paket
build:
    FROM +install-deps
    DO +COPY-SOURCE
    RUN R CMD build .
    SAVE ARTIFACT *.tar.gz AS LOCAL ./build
