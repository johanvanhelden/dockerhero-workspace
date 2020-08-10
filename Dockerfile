FROM phusion/baseimage:master-amd64

LABEL maintainer="Johan van Helden <johan@johanvanhelden.com>"

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

# Set environment variables
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

ARG NODE_VERSION=10.*
ENV NODE_VERSION ${NODE_VERSION}
ENV NVM_DIR /home/dockerhero/.nvm

ENV PUID=1000
ENV PGID=1000

ARG TZ=Europe/Amsterdam
ENV TZ ${TZ}

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

# Install "PHP Extentions", "libraries", "Software's"
RUN apt-get update && \
    apt-get install -y \
    mysql-client \
    pkg-config \
    php7.2-bcmath \
    php7.2-cli \
    php7.2-common \
    php7.2-curl \
    php7.2-json \
    php7.2-xml \
    php7.2-imap \
    php7.2-intl \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-pgsql \
    php7.2-soap \
    php7.2-sqlite \
    php7.2-sqlite3 \
    php7.2-zip \
    php7.2-memcached \
    php7.2-gd \
    php7.2-redis \
    php7.2-xdebug \
    php7.2-dev \
    php7.2-imagick \
    php-pear \
    wget \
    make \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    libsqlite3-dev \
    xz-utils \
    sqlite3 \
    git \
    curl \
    vim \
    nano \
    postgresql-client \
    git \
    mercurial \
    zip \
    unzip \
    vim \
    bash-completion \
    xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps \
    locales-all \
    && apt-get clean

# Disable Xdebug per default
RUN sed -i 's/^zend_extension=/;zend_extension=/g' /etc/php/7.2/cli/conf.d/20-xdebug.ini

# Install the Oracle client
RUN mkdir /opt/oracle \
    && cd /opt/oracle

RUN wget -O /opt/oracle/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip https://github.com/johanvanhelden/dockerhero-oracle/raw/master/19.5/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip && \
    wget -O /opt/oracle/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip https://github.com/johanvanhelden/dockerhero-oracle/raw/master/19.5/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip && \
    unzip /opt/oracle/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle && \
    unzip /opt/oracle/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle && \
    rm -rf /opt/oracle/*.zip

RUN ln -s /opt/oracle/instantclient_19_5/libclntshcore.so.19.1 /opt/oracle/instantclient_19_5/libclntshcore.so

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_19_5:${LD_LIBRARY_PATH}

RUN echo 'instantclient,/opt/oracle/instantclient_19_5/' | pecl install oci8

RUN echo 'extension=oci8.so' > /etc/php/7.2/cli/conf.d/30-oci8.ini

# Install the PDO_OCI extension
ADD pdo_oci /opt/oracle/pdo_oci
RUN cd /opt/oracle/pdo_oci && phpize && ./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient_19_5,19.5 && make && make install
RUN echo 'extension=pdo_oci.so' > /etc/php/7.2/cli/conf.d/30-pdo_oci.ini

#Install chrome - needed for Laravel Dusk
RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && apt-get install -y google-chrome-stable

# Add a non-root user to prevent files being created with root permissions on host machine.
RUN groupadd -g $PGID dockerhero && \
    useradd -u $PUID -g dockerhero -m dockerhero

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Composer for Laravel/Codeigniter
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install nvm (A Node Version Manager)
USER dockerhero
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.6/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias ${NODE_VERSION} && \
    npm install -g gulp @vue/cli

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

# Add NVM binaries to root's .bashrc
USER root
RUN echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/dockerhero/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

#Install Yarn
USER dockerhero
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    curl -o- -L https://yarnpkg.com/install.sh | bash; \
    echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc

# Add Yarn binaries to root's .bashrc
USER root
RUN echo "" >> ~/.bashrc && \
    echo 'export YARN_DIR="/home/dockerhero/.yarn"' >> ~/.bashrc && \
    echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.bashrc

# Copy artisan autocompleter to the proper folder
COPY ./artisan-autocompletion.sh /etc/bash_completion.d/artisan

# Add an artisan alias to .bashrc
RUN echo "" >> /home/dockerhero/.bashrc && \
    echo 'alias artisan="php artisan"' >> /home/dockerhero/.bashrc

# Clean up
USER root
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set default work directory
WORKDIR /var/www/projects
