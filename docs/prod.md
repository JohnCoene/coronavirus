# Application

Deploying the application requires a Postgres database.

## Setup

Create the required config file to run the crawler. You should only have to do this once.

```r
library(coronavirus)

# create and fill config file
create_config()
```

Fill in the config file created with the credentials to a Postgres database and optionally a free [newsapi.org](https://newsapi.org) token, then run the crawler. The config file should look like.

```yaml
database:
  name: database-name
  host: 123.123.123.12
  user: me
  password: my-password
newsapi:
  key: xxXx6X43X12YXx4Xx0XxXx7y # from newsapi.org
```

Every time you want to update the data, re-run `crawl_coronavirus`, it collects fresh data and overwrites everything.

```r
# crawl data
crawl_coronavirus()
```

Finally launch the app.

```r
# launch the dashboard
run_app()
```

## Deploy

You can deploy on whatever server you like, install R and the [Shiny Community server](https://rstudio.com/products/shiny/download-server/), then install the package from the terminal. Note that This also works on [shinyapps.io](https://www.shinyapps.io/) though you will need to host the database elsewhere. However, docker might be the easiest.

### Docker

The easiest was is to use docker, pull the container.

```bash
docker pull jcoenep/corona
```

Then run it as follows to copy the config file to said container.

```bash
docker run -v "$(pwd)"/_coronavirus.yml:/_coronavirus.yml -p 3000:80 jcoenep/corona
```

Then visit `localhost:3000`.

### With R

Deploy on a [Shiny Community server](https://rstudio.com/products/shiny/download-server/).

```bash
sudo su - -c "R -e \"install.packages('remotes')\""
sudo su - -c "R -e \"remotes::install_github('JohnCoene/coronavirus')\""
```

Once this done create a directory under `/srv/shiny-server/`, where you can create the config file.

```bash
cd /srv/shiny-server
mkdir coronavirus
cd ./coronavirus
R -e "coronavirus::create_config()"
vi _coronavirus.yml
```

Fill in the config file and create the app.

```bash
echo "coronavirus::run_app()" > app.R 
```

You can then visit `http://my.server.ip:3838/coronavirus`, you can change the port in the `/etc/shiny-server/shiny-server.conf` file, change it to `80` to have your app at `http://my.server.ip/coronavirus`.

Note that it's always a good idea to recrawl the data with `crawl_coronavirus` after reinstalling the package, in the event it requires changes database-side.

That is the dashboard set up and running, go to the [data](data.md) section to see how to create a cronjob to automatically update the data.

Open an issue if you have problems deploying, I'm more than happy helping.

Go to the next section on [embeds](/embeds) to host your own embedded charts.
