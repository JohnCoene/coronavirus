FROM rocker/r-base

RUN apt-get update -qq && apt-get install -y \
  git \
  libpq-dev \
  libssl-dev \
  libxml2-dev \
  libcurl4-gnutls-dev

RUN install2.r plumber DBI pool purrr yaml RPostgres

COPY _coronavirus.yml _coronavirus.yml
COPY api.R plumber.R

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000, swagger = TRUE)"]
CMD ["plumber.R"]