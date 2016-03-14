FROM php:7.0-fpm
MAINTAINER Jabsouliman <benjamin.souliman@gmail.com>

# Install Tools
RUN apt-get update && apt-get -y install build-essential \
        htop \
        libcurl3 \
        libcurl3-dev \
        librecode0 \
        libsqlite3-0 \
        libxml2 \
        curl \
        wget \
        python \
        vim \
        nano \
        cron \
        git \
        unzip \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c \
        ca-certificates --no-install-recommends

# Install PHP 7 Extension
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libsqlite3-dev \
        libssl-dev \
        libcurl3-dev \
        libxml2-dev \
        libzzip-dev \
        libldap2-dev  \
        libicu-dev \
        libxslt-dev \
        libc-client-dev \
        libkrb5-dev \
    && docker-php-ext-install calendar bcmath iconv json mcrypt mbstring phar curl ftp intl pdo_mysql hash session simplexml tokenizer xml xmlrpc zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap

# Install Supervisor
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
RUN curl https://bootstrap.pypa.io/ez_setup.py -o - | python
RUN easy_install supervisor

# Set up composer variables
RUN mkdir -p /data/containers/php7-fpm/composer
ENV COMPOSER_BINARY=/usr/local/bin/composer \
    COMPOSER_HOME=/data/containers/php7-fpm/composer
ENV PATH $PATH:$COMPOSER_HOME

# Install composer system-wide
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar $COMPOSER_BINARY && \
    chmod +x $COMPOSER_BINARY

# Prepare Config
RUN mkdir -p /etc/supervisord/
RUN mkdir /var/log/supervisord

COPY supervisor/supervisor.conf /etc/supervisord.conf
COPY supervisor/service/* /etc/supervisord/

COPY php.fpm.ini /etc/php7/fpm/php.ini
COPY php.cli.ini /etc/php7/cli/php.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /data/www_project
WORKDIR /data/www_project

# Expose Ports & Volumes
EXPOSE 9000
VOLUME ["/data"]
