FROM rocker/verse

RUN apt-get update -qq && apt-get install -y \
  git-core \
  libpq-dev \
  libssl-dev \
  libxml2-dev \
  libcurl4-gnutls-dev

RUN install2.r plumber DBI pool yaml RPostgres

COPY _coronavirus.yml _coronavirus.yml
COPY api.R plumber.R

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$registerHooks(list('exit' = function(){pool::poolClose(con)})); pr$run(host='0.0.0.0', port=8000, swagger = TRUE)"]
CMD ["plumber.R"]