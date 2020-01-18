# dockerhero-workspace

https://github.com/johanvanhelden/dockerhero

## Available tags
- `php7.3`
- `php7.2`
- `php7.1` -> this tag is not maintained and only used for backward compatibility
- `latest` -> this tag is not maintained and only used for backward compatibility

## Building and publishing

Ensure you are logged in locally to hub.docker.com using `docker login` and have access to the hub repository.
(note: your username is used, not your email address).

```
$ docker build ./ --tag johanvanhelden/dockerhero-workspace:TAG
$ docker push johanvanhelden/dockerhero-workspace:TAG
```

Replace `TAG` with the tag you are working on.

## Development

If you want to test a new feature, create a new tag for it. This way, it can not introduce issues in the production image if something is not working properly.

Once it works, delete the custom tag and introduce it into `latest`

## Testing the image locally

```
$ docker-compose up --build
$ docker exec --user=dockerhero -it dockerhero-workspace-testing bash
```
