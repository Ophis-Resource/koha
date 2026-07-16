# koha-docker

Docker implementation of Koha

## Design considerations

This container image is designed to be as close as possible to a packages install. What service is
run in the container depends on environment variables being set.

The services themselves are launched by a `supervisord` instance. This is not ideal, but it was a good
starting point back in 2019. FIXME: processes should be triggered in foreground instead of relying
on `supervisord`.

Having a working container image is crucial for future enhancements. As we say: perfect is the enemy of possible.

## Building

Building the image is fairly simple. For example, if you wanted to build an image for Koha v24.05.05, you would run:

```shell
export KOHA_VERSION=24.05
export FULL_KOHA_VERSION=24.05.05
docker build --build-arg KOHA_VERSION=$KOHA_VERSION -t koha/base:$FULL_KOHA_VERSION .
```

The build process will set the Debian repository and pull the latest packages from the `$KOHA_VERSION`
component.

You can specify a URL pointing to your own `koha-common` package, by using `$KOHA_COMMON_DEB_URL` variable
like this:


```bash
export KOHA_COMMON_DEB_URL="https://custom.repo/koha/montgomery-v24.05.05-03/koha-common_24.05.05.montgomery.03-1_all.deb"
export KOHA_VERSION=24.05
export FULL_KOHA_VERSION="24.05.05.montgomery.03"
docker build --build-arg KOHA_VERSION=$KOHA_VERSION -t koha/base:$FULL_KOHA_VERSION .
```

### OPTIONAL: Only use custom packages

The above process would dowload all required `koha*.deb` packages from the community repository
and  *optionally* use a custom `koha-common` package from a URL.

If you are building a pipeline and prefer to provide all the packages locally, all you need to do is
create a `debs/` directory in the project's root, and put the `.deb` packages there.

```bash
mkdir -p debs/
cp some/path/*.deb debs/
export KOHA_VERSION=24.05
export FULL_KOHA_VERSION=24.05.05
docker build --build-arg KOHA_VERSION=$KOHA_VERSION -t koha/base:$FULL_KOHA_VERSION .
```

## How to use

```bash
git clone https://gitlab.com/koha-community/docker/koha-docker.git --depth 1 --branch main
cd koha-docker
docker-compose up -d
```

## Configure

See the default [environment file](https://gitlab.com/koha-community/docker/koha-docker/-/raw/main/env/defaults.env?ref_type=heads)
for configuration options.
