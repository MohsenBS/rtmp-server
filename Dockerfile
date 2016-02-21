FROM debian:jessie
MAINTAINER Mohen Sarmadi "MohsenBS@users.noreply.github.com"
WORKDIR /home/builder/

ENV NGINX_VERSION=1.9.11

RUN apt-get update && \
    apt-get -qq install \
    build-essential unzip wget libpcre3 \
    libpcre3-dev libssl-dev openssl

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvzf  nginx-${NGINX_VERSION}.tar.gz  && \
    rm nginx-${NGINX_VERSION}.tar.gz  && \
    wget https://github.com/arut/nginx-rtmp-module/archive/master.zip && \
    unzip master.zip && \
    rm master.zip

RUN cd ./nginx-${NGINX_VERSION} && \
    ./configure \
    --add-module=../nginx-rtmp-module-master   \
    --user=nginx                               \
    --group=nginx                              \
    --prefix=/etc/nginx                        \
    --sbin-path=/usr/sbin/nginx                \
    --conf-path=/etc/nginx/nginx.conf          \
    --pid-path=/var/run/nginx.pid              \
    --lock-path=/var/run/nginx.lock            \
    --error-log-path=/var/log/nginx/error.log  \
    --http-log-path=/var/log/nginx/access.log  \
    --with-http_gzip_static_module             \
    --with-http_stub_status_module             \
    --with-http_ssl_module                     \
    --with-pcre                                \
    --with-file-aio                            \
    --with-http_realip_module                  \
    --without-http_scgi_module                 \
    --without-http_uwsgi_module                \
    --without-http_fastcgi_module &&           \
    make &&                                    \
    make install

COPY nginx.conf /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443 1935

CMD ["nginx", "-g", "daemon off;"]
