#
# This is the alpine linux work with tengine docker images
# @author tekintian
# @url http://github.com/tekintian/alpine-tengine
# @tengineTENGINE_VERSION  http://tengine.taobao.org/download.html
#

FROM tekintian/alpine:3.8-B20181221

LABEL maintainer="TekinTian <tekintian@gmail.com>"

#Tengine http://tengine.taobao.org/download.html
ENV TENGINE_VERSION 2.2.3

COPY /zoneinfo/* /usr/share/zoneinfo/

# build persistent deps
# persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
		openssl \
		pcre \
		zlib \
		jemalloc \
		geoip

RUN \
	addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -h /var/cache/nginx -s /sbin/nologin -G www-data www-data \
# install make Dependence
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		jemalloc-dev \
		geoip-dev \
		tzdata \
		wget \
		tar \
		gzip \
# compile & install 
	&& (cd /tmp \ 
	&& wget http://tengine.taobao.org/download/tengine-$TENGINE_VERSION.tar.gz  \
	&& tar -zxf tengine-$TENGINE_VERSION.tar.gz ) \
	&& (cd /tmp/tengine-$TENGINE_VERSION \
	&& ./configure \
		--prefix=/etc/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--sbin-path=/usr/sbin/nginx \
		--dso-path=/etc/nginx/modules \
		--dso-tool-path=/usr/sbin/dso_tool \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/lock/nginx.lock \
		--user=www-data \
		--group=www-data \
		--http-log-path=/var/log/nginx/access.log \
		--error-log-path=/var/log/nginx/error.log \
		--http-client-body-temp-path=/var/lib/nginx/client-body \
		--http-proxy-temp-path=/var/lib/nginx/proxy \
		--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
		--http-scgi-temp-path=/var/lib/nginx/scgi \
		--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
		--with-imap \
		--with-imap_ssl_module \
		--with-ipv6 \
		--with-pcre-jit \
		--with-http_dav_module \
		--with-http_geoip_module=shared \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_memcached_module=shared \
		--with-http_realip_module \
		--with-http_secure_link_module=shared \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-http_stub_status_module \
		--with-http_addition_module \
		--with-http_degradation_module \
		--with-http_flv_module=shared \
		--with-http_mp4_module=shared\
		--with-http_sub_module=shared \
		--with-http_sysguard_module=shared \
		--with-http_reqstat_module=shared \
		--with-file-aio \
		--with-mail \
		--with-mail_ssl_module \
		--with-http_concat_module=shared \
		--with-jemalloc --with-debug \
	&& make install \
	&& chown www-data:www-data /var/log/nginx \
	&& chmod 750 /var/log/nginx \
	&& install -d /var/lib/nginx /var/www/public \
	&& chown www-data:www-data /var/www/public) \
# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
# Remove unneeded packages/files
	&& apk del .build-deps \
	&& rm -rf /etc/localtime \
    &&  mkdir -p /usr/share/zoneinfo/Asia \
    && ln -s /usr/share/zoneinfo/PRC /etc/localtime \
    && ln -s /usr/share/zoneinfo/PRC /usr/share/zoneinfo/Asia/Shanghai \
    && echo "Asia/Shanghai" > /etc/timezone \
	&& rm -rf ~/* ~/.git ~/.gitignore ~/.travis.yml ~/.ash_history \
	&& rm -rf /tmp/* \
	&& rm -rf /var/cache/apk/*

COPY public/tz.php /var/www/public/tz.php
COPY public/index.html /var/www/public/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY fastcgi.conf /etc/nginx/fastcgi.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

VOLUME /var/www

WORKDIR /var/www

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]