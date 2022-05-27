FROM alpine:3.14 AS builder
WORKDIR /nginx
ENV NGINX_VERSION 1.22.0
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  wget \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O nginx.tar.gz
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  mkdir /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --with-pcre --with-http_ssl_module && \
  make && make install
RUN adduser -D nginx && \
    chown -R nginx:nginx /usr/local/nginx && \
    chmod -R 755 /usr/local/nginx
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid
RUN sed -i 's/listen       80/listen       8080/g' /usr/local/nginx/conf/nginx.conf
USER nginx
ENTRYPOINT ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
