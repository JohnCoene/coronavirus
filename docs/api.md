# API

## Interactive

The package provides an API with `run_api`. Install the latest version (`0.1.0` or above) and run the command below. Make sure you do so from the directory where your `_coronavirus.yml` configuration file is located, a database is required in order for the API to run.

```r
run_api()                                                                              
#> Starting server to listen on port 3000
#> Running the swagger UI at http://127.0.0.1:3000/__swagger__/
```

Visit the URL on printed in the console to explore the api.

## Deploy

You can deploy the application using docker. First copy the necessary files with the `copy_api_files` functions.

```r
copy_api_files()
```

This creates two files `api.R` and `Dockerfile`, you can then build the image with.

```r
docker build -t coronavirus .
```

Once built you can launch the API with:

```r
docker run -p 80:8000 -d coronavirus
```

Where `80` is the port of your machine.
