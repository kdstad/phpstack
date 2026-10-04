# syntax=docker/dockerfile:1.2
FROM docker.io/library/php:8.1-fpm-alpine3.22@sha256:65802aa6e89b89d3378f04913bd3d397dc572325bd6337a75fb8d4fb5e7fe86b

ENV TZ=Europe/Copenhagen

# upgrade the image and create a system user (appuser) for the php-fpm process
RUN set -x && \
	apk upgrade --no-cache && apk add --no-cache tzdata && \
	cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
		echo "${TZ}" > /etc/timezone && \
	addgroup -g 1082 -S appuser && adduser -u 1082 -h /var/www -H -D -S -G appuser appuser

# configure php-fpm pool
# Ref. https://github.com/docker-library/php/blob/master/8.1/alpine3.22/fpm/Dockerfile
RUN set -eux; \
	sed -ri \
		-e 's!^(user)\s*=\s*www-data\s*$!\1 = appuser!g' \
		-e 's!^(group)\s*=\s*www-data\s*$!\1 = appuser!g' \
		-e 's!^(pm)\s*=\s*dynamic\s*$!\1 = ondemand!g' \
		-e 's!^(pm\.max_children)\s*=.*$!\1 = 10!g' \
		-e '/^access\.log\s*=/d' \
		-e '/^pm\.start_servers\s*=/d' \
		-e '/^pm\.min_spare_servers\s*=/d' \
		-e '/^pm\.max_spare_servers\s*=/d' \
		-e '/^\[www\]/a pm.process_idle_timeout = 10s\npm.max_requests = 200\nrequest_terminate_timeout = 120\nrequest_slowlog_timeout = 10s\nslowlog = /proc/self/fd/2' \
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
		echo; \
		echo 'opcache.enable = 1'; \
		echo 'opcache.memory_consumption = 256'; \
		echo 'opcache.interned_strings_buffer = 32'; \
		echo 'opcache.max_accelerated_files = 20000'; \
		echo '; set validate_timestamps=0 for more speed, but then reload php-fpm after module/theme changes'; \
		echo 'opcache.validate_timestamps = 1'; \
		echo 'opcache.revalidate_freq = 60'; \
		echo; \
		echo '; faster file path lookups'; \
		echo 'realpath_cache_size = 4096K'; \
		echo 'realpath_cache_ttl = 600'; \
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
		pcre-dev \
	; \
	docker-php-ext-configure gd \
		--with-jpeg --with-freetype --with-webp --with-xpm --with-avif; \
	docker-php-ext-install -j$(nproc) \
		bcmath \
		gd \
		intl \
		mysqli \
		opcache \
		pdo_mysql \
		zip \
	; \
	pecl install imagick memcached redis ; \
	docker-php-ext-enable imagick memcached redis; \
	apk del .build-deps
