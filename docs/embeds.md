# Embedded Charts

Embedded charts are hosted in a separate shiny application which can optionally be deployed on your own server too. The `run_app` function takes an `embed_url` argument which defaults to `https://shiny.john-coene/coronavirus-embed` but can be changed to your own if you choose to deploy this api. 

> [!NOTE]
> This also requires a Postgres database setup as well as the config file.

Copy your config file and create a new directory on your server and run the following.

```bash
echo "coronavirus::run_embeds()" > app.R 
```

Then use the url of this application in your `run_app` function.

```r
run_app(embed_url = "http://my-server.com/name-of-directory")
```
