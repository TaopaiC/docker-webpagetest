FROM ubuntu:15.10
MAINTAINER TaopaiC <pctao.tw@gmail.com>

RUN apt-get update && \
    apt-get install -y apache2 php5-gd php5-curl php-apc libapache2-mod-php5 \
                       imagemagick libjpeg-progs libimage-exiftool-perl sqlite3 \
                       ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

ENV WPT_VERSION 2.19

RUN DIR=$(mktemp -d) && \
  cd ${DIR} && \
  curl -L -Os https://github.com/WPO-Foundation/webpagetest/archive/WebPageTest-${WPT_VERSION}.tar.gz  && \
  tar xvf WebPageTest-${WPT_VERSION}.tar.gz && \
  cd webpagetest-WebPageTest-${WPT_VERSION} && \
  cp -r www/*  /var/www/html/ && \
  rm -rf ${DIR}

RUN a2enmod expires headers rewrite php5

RUN sed -ri '\
  s/zlib.output_compression = Off/zlib.output_compression = On/g; \
  s/upload_max_filesize = 2M/upload_max_filesize = 10M/g; \
  s/post_max_size = 8M/post_max_size = 15M/g; \
  s/memory_limit = 128M/memory_limit = -1/g' /etc/php5/apache2/php.ini

RUN mkdir -p \
  /var/www/html/tmp \
  /var/www/html/dat \
  /var/www/html/results \
  /var/www/html/work/jobs \
  /var/www/html/work/video \
  /var/www/html/logs \
  /var/log/webpagetest \
  /data/archive && \
  chown www-data:www-data \
  /var/www/html/tmp \
  /var/www/html/dat \
  /var/www/html/results \
  /var/www/html/work/jobs \
  /var/www/html/work/video \
  /var/www/html/logs \
  /var/log/webpagetest \
  /data/archive && \
  chmod 775 \
  /var/www/html/tmp \
  /var/www/html/dat \
  /var/www/html/results \
  /var/www/html/work/jobs \
  /var/www/html/work/video \
  /var/www/html/logs \
  /var/log/webpagetest \
  /data/archive

COPY locations.ini /var/www/html/settings/locations.ini
COPY connectivity.ini /var/www/html/settings/connectivity.ini
COPY settings.ini /var/www/html/settings/settings.ini

VOLUME ["/var/www/html/results", "/data/archive"]
EXPOSE 80

CMD ["/usr/sbin/httpd", "-k", "start", "-D", "FOREGROUND"]