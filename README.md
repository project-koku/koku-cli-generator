# koku-cli-generator

koku-cli-generator defines a Docker image for generating and publishing a CLI based on [Koku](https://github.com/project-koku/koku/)'s current OpenAPI specification. When run, this image will perform the following operations:

- download the latest openapi.json from the [Koku](https://github.com/project-koku/koku/) API
- locally clone the remote [koku-cli](https://github.com/project-koku/koku-cli/) repository
- create a release in github
- use openapi-generator to generate clients using the downloaded openapi.json
- push clients to the release

 The koku-cli-generator image is automatically built and pushed to the Docker hub repository [infinitewarp/koku-cli-generator](https://hub.docker.com/r/infinitewarp/koku-cli-generator).

## Building koku-cli-generator

### Travis CI

Travis CI automatically builds the Docker image with each new push to [koku-cli-generator](https://github.com/project-koku/koku-cli-generator/). You can observe build logs on [travis-ci.org](https://travis-ci.org/project-koku/koku-cli-generator/builds/).

New commits to master will cause Travis CI to push an updated image with the "latest" tag to Docker hub. New tags will cause Travis CI to push an updated image with a tag name matching the git tag name to Docker hub.

### Local development

If you want to build a local Docker image for development or testing:

```sh
docker build -t infinitewarp/koku-cli-generator:latest .
```

## Running koku-cli-generator

koku-cli-generator requires several environment variables to be set in order to access the Koku API and push updated client code to GitHub. See the example `.env.example` file or recreate this list in your environment:

```sh
API_JSON_URL # URL from which to fetch Koku's openapi.json
API_AUTH_USERNAME # HTTP basic username for authentication to Koku API
API_AUTH_PASSWORD # HTTP basic password for authentication to Koku API
GITHUB_USERNAME # GitHub username for pushing updated code
GITHUB_PASSWORD # GitHub password for pushing updated code
```

Running with an env file:

```sh
docker run --env-file=.env infinitewarp/koku-cli-generator:latest
```
