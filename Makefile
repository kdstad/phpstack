DOCKER=/usr/bin/docker

.PHONY: httpd-test
httpd-test:
	cd httpd && $(DOCKER) build -t phpstack-httpd:latest -f Dockerfile .
	$(DOCKER) run --rm -p 8080:80 phpstack-httpd:latest

.PHONY: httpd-shell
httpd-shell:
	cd httpd && $(DOCKER) run --rm -it phpstack-httpd:latest /bin/sh
