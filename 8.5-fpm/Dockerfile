# syntax=docker/dockerfile:1.2
FROM php:8.5-fpm-alpine3.23@sha256:0b842919dc0aaed33eb5d57c7002f9f2d0120972d59db610cb6bdb69ad7624f0

# upgrade the image and create a system user that allows host-user to write to the document root without using root permissions.
RUN set -x && \
	apk upgrade --no-cache && \
	addgroup -g 1082 -S phpstack && adduser -u 1082 -D -S -G phpstack phpstack && \
	mkdir -p /home/phpstack/public_html && \
	echo "<?php echo 'Welcome to phpstack'; ?>" > /home/phpstack/public_html/index.php

COPY zz-phpstack.ini /usr/local/etc/php/conf.d/zz-phpstack.ini

# configure php-fpm pool
# Ref. https://github.com/docker-library/php/blob/master/8.5/alpine3.23/fpm/Dockerfile
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
	grep 'pm = ondemand' /usr/local/etc/php-fpm.d/www.conf
