# Dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y nginx curl && \
    apt-get clean

COPY index.html /var/www/html/index.html

EXPOSE 8889

CMD ["nginx", "-g", "daemon off;"]

