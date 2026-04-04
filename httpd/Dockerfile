# syntax=docker/dockerfile:1.2
FROM httpd:2.4-alpine3.23@sha256:8f26f33a7002658050e9ab2cd6b77502619dfc89d0a6ba2e9e4a202e0ef04596

ENV PHP_FPM_HOST=php
ENV PHP_FPM_PORT=9000

# upgrade the image and create a system user (appuser) for the httpd process
RUN set -x && \
	apk upgrade --no-cache && \
	addgroup -g 1082 -S appuser && adduser -u 1082 -h /var/www -H -D -S -G appuser appuser

COPY conf.d/zz-phpstack.conf "$HTTPD_PREFIX/conf/extra/zz-phpstack.conf"
COPY conf.d/zz-securityheaders.conf "$HTTPD_PREFIX/conf/extra/zz-securityheaders.conf"

# Ref. https://github.com/docker-library/httpd/blob/master/2.4/alpine/Dockerfile
RUN set -eux; \
	touch "$HTTPD_PREFIX/conf/extra/redirects.conf"; \
	sed -ri \
		-e 's!^(\s*User)\s+www-data\s*$!\1 appuser!g' \
		-e 's!^(\s*Group)\s+www-data\s*$!\1 appuser!g' \
		-e 's/#LoadModule proxy_module/LoadModule proxy_module/' \
        -e 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' \
		-e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
		-e 's/#LoadModule remoteip_module/LoadModule remoteip_module/' \
        -e 's|DocumentRoot "/usr/local/apache2/htdocs"|DocumentRoot "/var/www/html"|' \
		-e 's|DirectoryIndex index.html|DirectoryIndex index.html index.php |' \
        -e 's|<Directory "/usr/local/apache2/htdocs">|<Directory "/var/www/html">|' \
		-e '/Options Indexes FollowSymLinks/d' \
		-e 's|AllowOverride None|AllowOverride All|' \
		-e '$a Include conf/extra/redirects.conf' \
		-e '$a Include conf/extra/zz-securityheaders.conf' \
		-e '$a Include conf/extra/zz-phpstack.conf' \
		"$HTTPD_PREFIX/conf/httpd.conf" \
		"$HTTPD_PREFIX/conf/extra/httpd-ssl.conf" \
	; \
	grep -E '^\s*User appuser$' "$HTTPD_PREFIX/conf/httpd.conf"; \
	grep -E '^\s*Group appuser$' "$HTTPD_PREFIX/conf/httpd.conf"; \
	\
# smoke test
	httpd -v
