# syntax=docker/dockerfile:1.2
FROM php:8.1-fpm-alpine3.21@sha256:a84e0422af72d9a60a8f73756b622bcd37c5a8f85609e43e0a6e16c0a1a7820e

# upgrade the image and create a system user that allows host-user to write to the document root without using root permissions.
RUN set -x && \
	apk upgrade --no-cache && \
	addgroup -g 1082 -S phpstack && adduser -u 1082 -D -S -G phpstack phpstack && \
	mkdir -p /home/phpstack/public_html && \
	echo "<?php phpinfo(); ?>" > /home/phpstack/public_html/index.php

# configure php-fpm pool
# Ref. https://github.com/docker-library/php/blob/6485b53a1da0f2c4c5b564808de75ae62c023286/8.1/alpine3.21/fpm/Dockerfile
RUN set -eux; \
	sed -ri \
		-e 's!^(user)\s*=\s*www-data\s*$!\1 = phpstack!g' \
		-e 's!^(group)\s*=\s*www-data\s*$!\1 = phpstack!g' \
		-e 's!^(pm)\s*=\s*dynamic\s*$!\1 = ondemand!g' \
		-e 's!^(pm\.max_children)\s*=.*$!\1 = 80!g' \
		-e '/^pm\.start_servers\s*=/d' \
		-e '/^pm\.min_spare_servers\s*=/d' \
		-e '/^pm\.max_spare_servers\s*=/d' \
		-e '/^\[www\]/a pm.process_idle_timeout = 10s\npm.max_requests = 200\nrequest_terminate_timeout = 600' \
		/usr/local/etc/php-fpm.d/www.conf; \
	grep 'user = phpstack' /usr/local/etc/php-fpm.d/www.conf; \
	grep 'pm = ondemand' /usr/local/etc/php-fpm.d/www.conf && \
	{ \
		echo 'max_execution_time = 300'; \
		echo 'max_input_time = 600'; \
		echo 'max_input_vars = 10000'; \
		echo; \
		echo 'memory_limit = 1024M'; \
		echo; \
		echo 'post_max_size = 250M'; \
		echo 'upload_max_filesize = 250M'; \
	} > "$PHP_INI_DIR/conf.d/zz-phpstack.ini"

RUN set -eux; \
	apk add --no-cache \
		freetype \
		icu-libs \
		imagemagick \
		libjpeg-turbo \
		libmemcached \
		libpng \
		libzip \
	; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		freetype-dev \
		icu-dev \
		imagemagick-dev \
		libjpeg-turbo-dev \
		libmemcached-dev \
		libpng-dev \
		libzip-dev \
		zlib-dev \
	; \
	docker-php-ext-configure gd --with-jpeg --with-freetype; \
	docker-php-ext-install -j$(nproc) \
		bcmath \
		gd \
		intl \
		mysqli \
		pdo_mysql \
		zip \
	; \
	pecl install imagick memcached; \
	docker-php-ext-enable imagick memcached; \
	apk del .build-deps
