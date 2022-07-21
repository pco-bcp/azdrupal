FROM docker.io/bitnami/php-fpm:8.0 AS builder
RUN install_packages git patch composer
COPY . /app/
WORKDIR /app
RUN composer install

FROM docker.io/bitnami/php-fpm:8.0 AS php
RUN install_packages mariadb-client vim
RUN echo -e "\n\n; Allow environment variables to reach the FPM worker process.\nclear_env = no" >> /opt/bitnami/php/etc/php-fpm.d/www.conf
ENV PATH=$PATH:/app/vendor/bin
COPY --from=builder /app /app/
COPY ./docker/settings.php /app/html/sites/default/

FROM docker.io/bitnami/nginx:latest as web
USER root
RUN install_packages vim
#COPY ./docker/nginx-local.conf /opt/bitnami/nginx/conf/server_blocks/drupal.conf
COPY ./docker/nginx-azure.conf /opt/bitnami/nginx/conf/server_blocks/drupal.conf
COPY --from=builder /app /app/
