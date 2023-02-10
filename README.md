# dockerhero-workspace

https://github.com/johanvanhelden/dockerhero

## Available tags
- `php8.2`
- `php8.1`
- `php8.0`
- `php7.4` -> this tag is not maintained and only used for backward compatibility
- `php7.3` -> this tag is not maintained and only used for backward compatibility
- `php7.2` -> this tag is not maintained and only used for backward compatibility
- `php7.1` -> this tag is not maintained and only used for backward compatibility
- `latest` -> this tag is not maintained and only used for backward compatibility

## Building and publishing

Ensure you are logged in locally to hub.docker.com using `docker login` and have access to the hub repository.
(note: your username is used, not your email address).

```
$ docker build ./ --tag johanvanhelden/dockerhero-workspace:TAG
$ docker push johanvanhelden/dockerhero-workspace:TAG
```

Replace `TAG` with the tag you are working on.

## Development

If you want to test a new feature, create a new tag for it. This way, it can not introduce issues in the production image if something is not working properly.

Once it works, delete the custom tag and introduce it into `latest`

## Testing the image locally

```
$ docker-compose up --build
$ docker exec --user=dockerhero -it dockerhero-workspace-testing bash
```

## Enabled PHP modules
```
bcmath
calendar
Core
ctype
curl
date
dom
exif
FFI
fileinfo
filter
ftp
gd
gettext
hash
iconv
igbinary
imagick
imap
intl
json
libxml
mbstring
memcached
msgpack
mysqli
mysqlnd
openssl
pcntl
pcov
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
random
readline
redis
Reflection
session
shmop
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
sysvmsg
sysvsem
sysvshm
tokenizer
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib
```
