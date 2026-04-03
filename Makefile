DOCKER=/usr/bin/docker

.PHONY: httpd-test
httpd-test:
	cd httpd && $(DOCKER) build -t phpstack-httpd:latest -f Dockerfile .
	$(DOCKER) run --rm -p 8080:80 phpstack-httpd:latest

.PHONY: httpd-shell
httpd-shell:
	cd httpd && $(DOCKER) run --rm -it phpstack-httpd:latest /bin/sh

.PHONY: php-fpm-test
php-fpm-test:
	cd 8.5-fpm && $(DOCKER) build -t phpstack-8.5-fpm:latest -f Dockerfile .
	$(DOCKER) run --rm -p 9000:9000 phpstack-8.5-fpm:latest

.PHONY: php-fpm-shell
php-fpm-shell:
	cd 8.5-fpm && $(DOCKER) run --rm -it phpstack-8.5-fpm:latest /bin/sh
