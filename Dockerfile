FROM phusion/baseimage:latest

MAINTAINER Johan van Helden <johan@johanvanhelden.com>

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

# Set environment variables
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

ARG NODE_VERSION=6.*
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
    apt-get install -y --force-yes \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-json \
        php7.0-xml \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-pgsql \
        php7.0-soap \
        php7.0-sqlite \
        php7.0-sqlite3 \
        php7.0-zip \
        php7.0-memcached \
        php7.0-gd \
        pkg-config \
        php-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        libsqlite3-dev \
        sqlite3 \
        git \
        curl \
        vim \
        nano \
        postgresql-client \
    && apt-get clean

# Add a non-root user to prevent files being created with root permissions on host machine.
RUN groupadd -g $PGID dockerhero && \
    useradd -u $PUID -g dockerhero -m dockerhero

# Install usefull tools
RUN apt-get update && apt-get install -y \
        git \
        mercurial \
        zip \
        vim \
        bash-completion

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
    npm install -g gulp bower vue-cli

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
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc \
    
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
