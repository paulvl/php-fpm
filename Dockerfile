FROM debian:jessie

# Install dotdeb repo, PHP, composer and selected extensions
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get -y --no-install-recommends install -y --force-yes \
    php5-cli \
    php5-fpm \
    php5-apcu \
    php5-curl \
    php5-json \
    php5-mcrypt \
    php5-readline \
    php5-memcached \
    php5-mysql \
    php5-pgsql \
    php5-redis \
    php5-sqlite \
    php5-gd \
    php5-gmp \
    php5-memcache \
    php5-odbc \
    php5-twig \
    sqlite3 \
    libsqlite3-dev \
    git \
    curl \
    vim \
    nano \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean

# Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash

ENV NVM_DIR=/root/.nvm

# Install stable node
RUN . ~/.nvm/nvm.sh \
    && nvm install stable \
    && nvm use stable \
    && nvm alias stable \
    && npm install -g gulp bower

# Source the bash
RUN . ~/.bashrc

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Configure FPM to run properly on docker
RUN sed -i "/listen = .*/c\listen = [::]:9000" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;access.log = .*/c\access.log = /proc/self/fd/2" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;clear_env = .*/c\clear_env = no" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/pid = .*/c\;pid = /run/php/php5-fpm.pid" /etc/php5/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php5/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php5/fpm/php-fpm.conf \
    && usermod -u 1000 www-data

EXPOSE 9000

WORKDIR "/var/www"