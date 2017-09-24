FROM wordpress:4.8.1-php7.1-apache

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends less libxml2-dev mysql-client ssh wget subversion git\
    && docker-php-ext-install soap \
    && rm -rf /var/lib/apt/lists/*

# install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/pear/

# setting xdebug
RUN { \
      echo ''; \
      echo 'xdebug.remote_enable=1'; \
      echo 'xdebug.remote_port="9000"'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN a2enmod expires proxy proxy_http rewrite

VOLUME /var/www/html

# install wp-cli
RUN curl -sSL -o /usr/local/bin/wp "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /etc/wp-cli \
    && chown www-data:www-data /etc/wp-cli

# setting wp-cli
RUN { \
      echo 'path: /var/www/html'; \
      echo 'url: project.dev'; \
      echo 'apache_modules:'; \
      echo '  - mod_rewrite'; \
    } > /etc/wp-cli/config.yml

RUN echo "export WP_CLI_CONFIG_PATH=/etc/wp-cli/config.yml" > /etc/profile.d/wp-cli.sh

# install phpunit
RUN wget https://phar.phpunit.de/phpunit-6.3.0.phar && \
    chmod +x phpunit-6.3.0.phar && \
    mv phpunit-6.3.0.phar /usr/local/bin/phpunit

# install composer
RUN wget https://getcomposer.org/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer