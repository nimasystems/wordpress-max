ARG WORDPRESS_VERSION=6.9.0
ARG UID=1000
ARG GID=1000
ARG LIBCURL_VERSION=4

FROM wordpress:${WORDPRESS_VERSION}-apache AS build

ARG LIBCURL_VERSION

USER root

# install deps
RUN apt -y update && apt -y upgrade && apt -y install \
    autoconf \
    pkg-config \
    gcc \
    make \
    curl \
    wget \
    imagemagick \
    zip \
    unzip \
    git \
    libc-dev \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libonig-dev \
    libcurl$LIBCURL_VERSION \
    libcurl${LIBCURL_VERSION}-openssl-dev \
    libpng-dev \
    liblz4-1 \
    liblz4-dev \
    libyaml-dev \
    libyaml-0-2 \
    libssh2-1-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libsodium-dev \
    libmemcached-dev \
    libpcre2-dev \
    libssl-dev \
    libyaml-dev \
    libkrb5-dev \
    zlib1g-dev \
    libgd-dev \
    libmagick++-dev \
    libsodium-dev \
    libmemcached-dev

RUN pecl channel-update pecl.php.net \
    && pecl install redis yaml libsodium apcu

FROM wordpress:${WORDPRESS_VERSION}-apache AS runtime

ARG UID
ARG GID
ARG LIBCURL_VERSION

ENV APACHE_RUN_USER=$UID
ENV APACHE_RUN_GROUP=$GID

LABEL maintainer="Martin Kovachev <miracle@nimasystems.com>"

USER root

COPY conf/php/php.ini /usr/local/etc/php/php.ini
COPY conf/php/conf.d/apcu.ini /usr/local/etc/php/conf.d/apcu.ini
COPY conf/php/conf.d/redis.ini /usr/local/etc/php/conf.d/redis.ini
COPY conf/php/conf.d/yaml.ini /usr/local/etc/php/conf.d/yaml.ini

COPY conf/apache/web.conf /etc/apache2/conf-enabled/web.conf
COPY conf/apache/wordpress-htaccess.conf /etc/apache2/conf-enabled/wordpress-htaccess.conf

# copy all prebuilt extensions
COPY --from=build /usr/local/lib/php/extensions/no-debug-non-zts-20230831 /usr/local/lib/php/extensions/no-debug-non-zts-20230831

# install deps
RUN apt -y update && apt -y install \
    wget \
    unzip \
    ncurses-bin \
    curl \
    vim \
    ncdu \
    mc \
    lynx \
    imagemagick \
    optipng \
    gifsicle \
    gettext \
    htmldoc \
    webp \
    jpegoptim \
    zip \
    unzip \
    git \
    python3 \
    pip \
    ca-certificates \
    libcurl$LIBCURL_VERSION \
    libfreetype6 \
    libzip5 \
    libsodium23 \
    liblz4-1 \
    libyaml-0-2 \
    libmemcached11 \
    libmemcached-tools

RUN pip3 install pandas numbers_parser --break-system-packages

RUN apt-get install -y acl locales \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'bg_BG.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'it_IT.UTF-8 UTF-8' >> /etc/locale.gen \
    && /usr/sbin/locale-gen

RUN groupadd -g "$GID" app \
    && useradd -g "$GID" -u "$UID" -d /var/www/html -s /bin/bash app \
    && mkdir -p /.config/mc /.cache/mc /.local/share/mc

# install wp-cli \
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info

# install wp-cli bash completions \
RUN wget https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
    && cat wp-completion.bash >> /var/www/html/.bashrc \
    && rm -rf wp-completion.bash

WORKDIR /var/www/html

RUN chown -R app:app /var/www/html

USER $UID:$GID

FROM runtime AS runtime-prod
