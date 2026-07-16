FROM debian:bookworm

ARG KOHA_COMMON_DEB_URL
ARG KOHA_VERSION=24.05
ARG PKG_URL=https://debian.koha-community.org/koha

LABEL maintainer="tomascohen@theke.io"

RUN    apt update \
    && apt install -y \
            apache2 \
            libapache2-mpm-itk \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            supervisor \
            locales \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

# We need a local set
RUN    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

RUN if [ "${PKG_URL}" = "https://debian.koha-community.org/koha" ]; then \
        mkdir -p --mode=0755 /etc/apt/keyrings ; \
        curl -fsSL https://debian.koha-community.org/koha/gpg.asc \
             -o /etc/apt/keyrings/koha.asc; \
        echo "deb [signed-by=/etc/apt/keyrings/koha.asc] ${PKG_URL} ${KOHA_VERSION} main" | tee /etc/apt/sources.list.d/koha.list \
    ; else \
        echo "deb ${PKG_URL} ${KOHA_VERSION} main" | tee /etc/apt/sources.list.d/koha.list \
    ; fi

# Install Koha
RUN echo ${KOHA_COMMON_DEB_URL}
RUN if [ -z "${KOHA_COMMON_DEB_URL}" ]; then \
        if [ -d "/debs" ]; then \
            echo "[INFO] === Installing from debs/" ; \
            ls /debs ; \
            echo "[INFO] === ^^^ ===" ; \
            apt update \
              && apt install -y \
                /debs/*.deb \
        ; else \
            echo "[INFO] === Installing from the Debian repo" ; \
            apt update \
              && apt install -y koha-common \
        ; fi \
    ; else \
        echo "[INFO] === Installing from the Debian repo and overwriting with ${KOHA_COMMON_DEB_URL}" ; \
        apt update \
         && apt install -y koha-common \
         && wget ${KOHA_COMMON_DEB_URL} \
         && dpkg -i koha-common*.deb \
         && rm -f koha-common*.deb \
    ; fi \
      && rm -rf /var/cache/apt/archives/* \
      && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite \
            headers \
            proxy_http \
            cgi \
    && a2dissite 000-default \
    && echo "Listen 8081\nListen 8080" > /etc/apache2/ports.conf

# Adjust apache configuration files
RUN sed -e "s/unix.*\/\/localhost/http\:\/\/koha\:5000/g" /etc/koha/apache-shared-intranet-plack.conf > /etc/koha/apache-shared-intranet-plack.conf.new \
    && sed -e "s/unix.*\/\/localhost/http\:\/\/koha\:5000/g" /etc/koha/apache-shared-opac-plack.conf  > /etc/koha/apache-shared-opac-plack.conf.new \
    && mv /etc/koha/apache-shared-intranet-plack.conf.new /etc/koha/apache-shared-intranet-plack.conf \
    && mv /etc/koha/apache-shared-opac-plack.conf.new /etc/koha/apache-shared-opac-plack.conf

RUN mkdir /docker

COPY scripts/entrypoint.sh /docker/entrypoint.sh
COPY scripts/run.sh        /docker/run.sh
COPY scripts/es_indexer.sh /docker/es_indexer.sh
COPY scripts/worker.sh     /docker/worker.sh

COPY templates /docker/templates

WORKDIR /docker

EXPOSE 8080 8081

ENTRYPOINT ["/docker/entrypoint.sh"]

CMD [ "/docker/run.sh" ]
