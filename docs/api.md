# API

The latest version (`0.1.0`) comes with an API that is freely available at [shiny.john-coene.com:8080](http://shiny.john-coene.com:8080/__swagger__/).

> [!NOTE]
> Please kindly try to deploy the application yourself to reduce the load on my server or consider donating as hosting is not free.
> 
> <a class="github-button" href="https://github.com/sponsors/JohnCoene" data-icon="octicon-heart" aria-label="Sponsor @JohnCoene on GitHub">Sponsor</a>

## Endpoints

There is one endpoint for each data source, see the [swagger documentation](http://shiny.john-coene.com:8080/__swagger__/).

- `GET /jhu`: John Hopkins data. Takes two arguments, `type`, the type of case to return `confirm`, `recovered`, or `death`.
- `GET /weixin` Weixin data. Takes no argument.
- `GET /dxy`: DingXianYing data. Takes no argument.

<script async defer src="https://buttons.github.io/buttons.js"></script>

```bash
curl GET http://shiny.john-coene.com:8080/dxy
```

## Interactive

The package provides an API with `run_api`. Install the latest version (`0.1.0` or above) and run the command below. Make sure you do so from the directory where your `_coronavirus.yml` configuration file is located, a database is required in order for the API to run.

```r
run_api()                                                                              
#> Starting server to listen on port 3000
#> Running the swagger UI at http://127.0.0.1:3000/__swagger__/
```

Visit the URL on printed in the console to explore the api.

## Deploy

It's easy to deploy using docker.

1) Pull the container.

```bash
docker pull jcoenep/coronapi
```

2) Then run it by first mounting your config file.

```bash
docker run -v "$(pwd)"/_coronavirus.yml:/_coronavirus.yml -p 3000:8000 jcoenep/coronapi
```

3) Finally, visit `localhost:3000/__swagger__/`

