FROM debian:stretch

# Install dependencies

RUN apt-get update && apt-get install -y gcc make build-essential \
    libxml2-dev  libcurl4-gnutls-dev libpcre3-dev libbz2-dev libjpeg-dev \
    libpng16-16  libfreetype6-dev  libmcrypt-dev libmhash-dev \
    freetds-dev default-libmysqlclient-dev unixodbc-dev libxslt1-dev wget curl libxpm-dev ldap-utils libldap2-dev

RUN cd /usr/local/include/ && ln -s /usr/include/x86_64-linux-gnu/curl/

# Installing Apache 2.2.9

RUN cd /usr/src && wget -c -t 3 -O ./httpd-2.2.9.tar.gz http://archive.apache.org/dist/httpd/httpd-2.2.9.tar.gz \
&& tar xvfz httpd-2.2.9.tar.gz && cd httpd-2.2.9 && ./configure --prefix=/usr/local/apache2 --enable-mods-shared=all \
&& make && make install

# PHP sources & patches download

RUN wget -c -t 3 -O ./php-5.2.17.tar.gz http://museum.php.net/php5/php-5.2.17.tar.gz \
    && wget -c -t 3 -O ./libxml29_compat.patch https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt \
    && wget -c -t 3 -O ./debian_patches_disable_SSLv2_for_openssl_1_0_0.patch https://bugs.php.net/patch-display.php\?bug_id\=54736\&patch\=debian_patches_disable_SSLv2_for_openssl_1_0_0.patch\&revision=1305414559\&download\=1 \
    && wget -c -t 3 -O - http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz | gunzip > ./php-5.2.17-fpm-0.5.14.patch

# Patching PHP

RUN tar xvfz php-5.2.17.tar.gz && cd php-5.2.17  && patch -p0 -b < ../libxml29_compat.patch \
    && patch -p1 -b < ../debian_patches_disable_SSLv2_for_openssl_1_0_0.patch \
    && patch -p1 < ../php-5.2.17-fpm-0.5.14.patch


# Installing PHP 5.2.17

RUN php-5.2.17/configure \
   --prefix=/usr/share/php52 \
    --datadir=/usr/share/php52 \
    --mandir=/usr/share/man \
    --bindir=/usr/bin/php52 \
    --with-xpm-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --includedir=/usr/include \
    --with-config-file-path=/etc/php/apache2-php5.2 \
    --with-config-file-scan-dir=/etc/php/apache2-php5.2/ext-active \
    --with-apxs2=/usr/local/apache2/bin/apxs \
    --disable-debug \
    --with-regex=php \
    --disable-rpath \
    --disable-static \
    --disable-posix \
    --with-pic \
    --with-layout=GNU \
    --with-pear=/usr/share/php \
    --enable-calendar \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-bcmath \
    --with-bz2 \
    --enable-ctype \
    --without-gdbm \
    --with-iconv \
    --enable-exif \
    --enable-ftp \
    --enable-cli \
    --with-gettext \
    --enable-mbstring \
    --with-pcre-regex \
    --enable-shmop \
    --enable-sockets \
    --enable-wddx \
    --enable-fastcgi \
    --enable-force-cgi-redirect \
    --with-mcrypt \
    --with-zlib \
    --enable-pdo \
    --with-curl \
    --enable-inline-optimization \
    --enable-xml \
    --enable-json \
    --enable-mbregex \
    --with-mhash \
    --enable-zip \
    --with-gd \
    --with-jpeg-dir=/usr/lib \
    --with-png-dir=/usr/lib \
    --enable-gd-native-ttf \
    --with-freetype-dir=/usr \
    --with-ldap \
    --with-kerberos=/usr \
    --with-imap-ssl \
    --without-sqlite \
    --with-sqlite \
    --without-pdo-sqlite \
    --enable-soap \
    --with-pdo-sqlite \
    --with-pdo-mysql \
    --with-mysql \
    --with-mysqli \
    --with-mysqli=/usr/bin/mysql_config \
    && make -j "$(nproc)" \
    && make install

# Cleaning 

RUN apt-get purge -y \
    gcc make wget \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -Rf /tmp/pear && rm -Rf /php-5.2*

COPY php.ini /etc/php/apache2-php5.2/
COPY httpd.conf /usr/local/apache2/conf/


EXPOSE 80

CMD ["/usr/local/apache2/bin/apachectl", "-D", "FOREGROUND"]




