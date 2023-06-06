FROM ubuntu

# apt 
RUN apt update

ARG DEBIAN_FRONTEND=noninteractive
RUN apt upgrade -y \
&& apt install --no-install-recommends -y \
apache2 \
curl \
cron \
ca-certificates \
php8.1 php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath \
&& apt-get clean

# apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

COPY apache/* /etc/apache2/sites-available/
RUN a2dissite 000-default.conf
RUN a2ensite app.conf
RUN rm -rf /var/www/html

# set up cron
COPY crontab /hello-cron
COPY entrypoint.sh /entrypoint.sh

RUN crontab hello-cron
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set up composer
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# set up the app
COPY ./app/. /var/www

RUN mv /var/www/.env.example /var/www/.env
RUN chmod +x /var/www/deploy.sh

# create user
RUN adduser --disabled-password --shell /bin/bash --gecos "User" wfa
RUN usermod -aG www-data wfa
RUN chown -R wfa:www-data /var/www
# switch to wfa user
USER wfa

WORKDIR /var/www

# artisan commands
RUN composer install --no-interaction --prefer-dist --optimize-autoloader
RUN ./deploy.sh > /dev/null 2>&1 &

# switch back to root, set to www-data /var/www
USER root
RUN chown -R www-data:www-data /var/www

# expose ports
EXPOSE 80
EXPOSE 443

# run commands after container
CMD ["apachectl", "-D",  "FOREGROUND"]