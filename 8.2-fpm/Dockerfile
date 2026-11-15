# syntax=docker/dockerfile:1.2
FROM docker.io/library/php:8.2-fpm-trixie@sha256:8438f8ea8465dda86393dd84f91da5a02cd5555e494a1000a98112c830669299

ENV TZ=Europe/Copenhagen

# upgrade the image and create a system user (appuser) for the php-fpm process
RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata; \
	rm -rf /var/lib/apt/lists/*; \
	ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
		echo "${TZ}" > /etc/timezone; \
	useradd --uid 1082 --user-group --no-create-home --home-dir /var/www --shell /usr/sbin/nologin appuser

# configure php-fpm pool
# Ref. https://github.com/docker-library/php/blob/master/8.2/trixie/fpm/Dockerfile
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
	grep 'pm = ondemand' /usr/local/etc/php-fpm.d/www.conf; \
	{ \
		echo "session.cookie_httponly=1"; \
		echo "session.cookie_secure=1"; \
		echo "session.cookie_samesite=Lax"; \
		echo; \
		echo "session.upload_progress.enabled=0"; \
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
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		libavif-dev \
		libfreetype-dev \
		libicu-dev \
		libjpeg62-turbo-dev \
		libmagickwand-dev \
		libmemcached-dev \
		libpng-dev \
		libwebp-dev \
		libxpm-dev \
		libzip-dev \
		zlib1g-dev \
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
	pecl install imagick memcached redis; \
	docker-php-ext-enable imagick memcached redis; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# remove build dependencies but keep the runtime libraries the extensions link against
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f \( -executable -o -name '*.so' \) -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
# ignore dpkg diversion lines and keep only package names
		| awk 'sub(":$", "", $1) { print $1 }' \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
# smoke test
	php --version; \
	php -m | grep -qi '^imagick$'; \
	php -m | grep -qi '^memcached$'; \
	php -m | grep -qi '^redis$'
