FROM php:8.1-apache
RUN a2enmod rewrite
# 安装相关拓展
RUN apt update && apt install imagemagick libmagickwand-dev -y \
    && pecl install imagick \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install php-pgsql \
    && docker-php-ext-enable imagick 
RUN pecl install redis \
    && docker-php-ext-enable redis
RUN { \
    echo 'post_max_size = 100M;';\
    echo 'upload_max_filesize = 100M;';\
    echo 'max_execution_time = 600S;';\
    echo 'extension=redis.so';\
    } > /usr/local/etc/php/conf.d/docker-php-upload.ini; 
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    \
    mkdir /var/www/data; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www

COPY ./ /var/www/lsky/
# COPY ./apache2.conf /etc/apache2/
COPY ./000-default.conf /etc/apache2/sites-enabled/
COPY entrypoint.sh /
# COPY ./docker-php.conf /etc/apache2/conf-enabled
WORKDIR /var/www/html/
VOLUME /var/www/html
EXPOSE 80
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl","-D","FOREGROUND"]
