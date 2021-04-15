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
    php7.4-bcmath \
    php7.4-cli \
    php7.4-common \
    php7.4-curl \
    php7.4-json \
    php7.4-xml \
    php7.4-imap \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-pgsql \
    php7.4-soap \
    php7.4-sqlite \
    php7.4-sqlite3 \
    php7.4-zip \
    php7.4-memcached \
    php7.4-gd \
    php7.4-redis \
    php7.4-xdebug \
    php7.4-dev \
    php7.4-imagick \
    php-pear \
    wget \
    make \
    libaio1 \
    libaio-dev \
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
RUN sed -i 's/^zend_extension=/;zend_extension=/g' /etc/php/7.4/cli/conf.d/20-xdebug.ini

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
    nvm install 10 && \
    nvm install 12 && \
    nvm install 14 && \
    nvm use 14 && \
    nvm alias default 14 && \
    npm install -g @vue/cli

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
