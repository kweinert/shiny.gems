VERSION 0.8
FROM rocker/r-ver:4.3.2

WORKDIR /pkg

install-deps:
	# Installiere Systemabhängigkeiten für R und pak
	RUN apt-get update && apt-get install -y \
		build-essential \
		libssl-dev \
		libcurl4-openssl-dev \
		&& rm -rf /var/lib/apt/lists/*

	# Installiere pak von CRAN
	RUN R -e "install.packages('pak', repos='https://cloud.r-project.org/')"

	# Konfiguriere P3M als Repository für Binärpakete (Ubuntu 22.04 "jammy" als Beispiel)
	RUN echo "options(repos = c(CRAN = 'https://p3m.dev/cran/__linux__/jammy/latest'))" >> /usr/local/lib/R/etc/Rprofile.site
	
	# Installiere weitere Pakete als Binaries über pak
    RUN R -e "pak::pkg_install(c('shiny', 'tinytest'))"
    
install-img:
	FROM +install-deps
	SAVE IMAGE install-img:latest

# Kopiere das R-Paket und baue es
build:
    FROM +install-deps
    COPY . /pkg
    RUN R CMD build .
    SAVE ARTIFACT *.tar.gz AS LOCAL ./build/

# Führe R CMD check auf dem gebauten Paket aus
check:
    FROM +install-deps
    COPY +build/*.tar.gz .
    RUN R -e "pak::pkg_install(dir('.', pattern='*.tar.gz', full.names=TRUE), dependencies=TRUE)"
    RUN R CMD check --as-cran --no-tests --no-build-vignettes --no-manual *.tar.gz
    SAVE ARTIFACT *.Rcheck/00* AS LOCAL ./check/
