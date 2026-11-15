# syntax=docker/dockerfile:1.2
FROM docker.io/library/httpd:2.4-trixie@sha256:32e9403360ab2f1047523e72f256527fb9aee68b342abf6ad03f0d629157f3d9

ENV PHP_FPM_HOST=php
ENV PHP_FPM_PORT=9000

ENV TZ=Europe/Copenhagen

# upgrade the image and create a system user (appuser) for the httpd process
RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata; \
	rm -rf /var/lib/apt/lists/*; \
	ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
		echo "${TZ}" > /etc/timezone; \
	useradd --uid 1082 --user-group --no-create-home --home-dir /var/www --shell /usr/sbin/nologin appuser

COPY conf.d/zz-phpstack.conf "$HTTPD_PREFIX/conf/extra/zz-phpstack.conf"
COPY conf.d/zz-securityheaders.conf "$HTTPD_PREFIX/conf/extra/zz-securityheaders.conf"

# Ref. https://github.com/docker-library/httpd/blob/master/2.4/Dockerfile
RUN set -eux; \
	touch "$HTTPD_PREFIX/conf/extra/redirects.conf"; \
	sed -ri \
		-e 's!^(\s*User)\s+www-data\s*$!\1 appuser!g' \
		-e 's!^(\s*Group)\s+www-data\s*$!\1 appuser!g' \
		-e 's/#LoadModule proxy_module/LoadModule proxy_module/' \
		-e 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' \
		-e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
		-e 's/#LoadModule remoteip_module/LoadModule remoteip_module/' \
		-e 's/#LoadModule expires_module/LoadModule expires_module/' \
		-e 's/#LoadModule deflate_module/LoadModule deflate_module/' \
		-e 's|DocumentRoot "/usr/local/apache2/htdocs"|DocumentRoot "/var/www/html"|' \
		-e 's|DirectoryIndex index.html|DirectoryIndex index.html index.php|' \
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

WORKDIR /var/www/html

RUN set -eux; \
	cp -v "$HTTPD_PREFIX/htdocs/index.html" index.html
