# syntax=docker/dockerfile:1.2@sha256:e2a8561e419ab1ba6b2fe6cbdf49fd92b95912df1cf7d313c3e2230a333fdbcc
FROM php:8.5-fpm-alpine3.21@sha256:4fc80abd462e721895c4024aa93da50a640bb7cb50fbfe49eae9d5ec9ba4c136

ENV TZ=Europe/Copenhagen

# upgrade the image and create a system user (appuser) for the php-fpm process
RUN set -x && \
	apk upgrade --no-cache && apk add --no-cache tzdata && \
	cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
		echo "${TZ}" > /etc/timezone && \
	addgroup -g 1082 -S appuser && adduser -u 1082 -h /var/www -H -D -S -G appuser appuser

# configure php-fpm pool
# Ref. https://github.com/docker-library/php/blob/master/8.5/alpine3.23/fpm/Dockerfile
RUN set -eux; \
	sed -ri \
		-e 's!^(user)\s*=\s*www-data\s*$!\1 = appuser!g' \
		-e 's!^(group)\s*=\s*www-data\s*$!\1 = appuser!g' \
		-e 's!^(pm)\s*=\s*dynamic\s*$!\1 = ondemand!g' \
		-e 's!^(pm\.max_children)\s*=.*$!\1 = 80!g' \
		-e '/^access\.log\s*=/d' \
		-e '/^pm\.start_servers\s*=/d' \
		-e '/^pm\.min_spare_servers\s*=/d' \
		-e '/^pm\.max_spare_servers\s*=/d' \
		-e '/^\[www\]/a pm.process_idle_timeout = 10s\npm.max_requests = 200\nrequest_terminate_timeout = 600' \
		/usr/local/etc/php-fpm.d/www.conf \
		/usr/local/etc/php-fpm.d/docker.conf \
	; \
	grep 'user = appuser' /usr/local/etc/php-fpm.d/www.conf; \
	grep 'pm = ondemand' /usr/local/etc/php-fpm.d/www.conf && \
	{ \
		echo "session.cookie_httponly=1"; \
		echo "session.cookie_secure=1"; \
		echo "session.cookie_samesite=Lax"; \
		echo; \
		echo "date.timezone=${TZ}"; \
		echo; \
		echo 'max_execution_time = 300'; \
		echo 'max_input_time = 600'; \
		echo 'max_input_vars = 10000'; \
		echo; \
		echo 'memory_limit = 1024M'; \
		echo; \
		echo 'post_max_size = 250M'; \
		echo 'upload_max_filesize = 250M'; \
		echo; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT'; \
		echo 'log_errors = On'; \
		echo; \
		echo 'expose_php = Off'; \
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
		libwebp \
		libxpm \
		libavif \
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
		libwebp-dev \
		libxpm-dev \
		libavif-dev \
	; \
	docker-php-ext-configure gd \
		--with-jpeg --with-freetype --with-webp --with-xpm --with-avif; \
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
