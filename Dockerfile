FROM ubuntu:18.04

RUN apt-get update

#Nodejs
RUN apt-get install curl -y
RUN apt-get install -my wget gnupg build-essential libpng-dev
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install nodejs -y

# Apache
RUN apt-get install apache2 -y
RUN a2enmod rewrite
RUN a2enmod headers

# PHP
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install php-curl php7.2 php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-mysql php7.2-mbstring php7.2-zip php7.2-fpm php7.2-xml php7.2-gd php7.2-xdebug libapache2-mod-php -y

#Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '8a6138e2a05a8c28539c9f0fb361159823655d7ad2deecb371b04a83966c61223adc522b0189079e3e9e277cd72b8897') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# Xdebug
RUN echo "xdebug.idekey = PHPSTORM" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.default_enable=1" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_autostart = 1" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_port = 9001" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_handler = dbgp" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_host = $(getent hosts docker.for.mac.localhost | awk '{ print $1 }')" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini \
    &&  echo "xdebug.remote_connect_back=1" /etc/php/7.2/apache2/conf.d/20-xdebug.ini

# Page setup
WORKDIR /var/www/html

CMD cd /etc/apache2/sites-available && \
		a2ensite * && \
		apachectl -D FOREGROUND
