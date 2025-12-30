FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Optional but common:
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]
