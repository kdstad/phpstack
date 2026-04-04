# phpstack

> [!NOTE]
> Issues and PR's will not be accepted on this repo as it is provided as-is for our own projects. You are welcome to fork this project and make your own modifications.

Minimal, reusable PHP-FPM and HTTPD container images for running modern PHP applications.

This repository provides a small set of base images built for consistency, performance, and portability across container platforms (Docker, Kubernetes, and others).
While primarily used for PrestaShop, the images are intentionally generic and can be used for any PHP-based application.

## License

This repository contains Dockerfiles and scripts under different licenses:

- **PHP (FPM) images**: MIT License — see [8.1-fpm/LICENSE](8.1-fpm/LICENSE) and [8.5-fpm/LICENSE](8.5-fpm/LICENSE)
- **HTTPD image**: Apache License 2.0 — see [httpd/LICENSE](httpd/LICENSE)
