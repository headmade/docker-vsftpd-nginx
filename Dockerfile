FROM debian:jessie

# install nginx
ENV NGINX_VERSION 1.11.3-1~jessie
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
COPY nginx_host.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443

# install vsftpd
RUN groupadd -g 48 ftp && \
    useradd --no-create-home --home-dir /files -s /bin/false --uid 48 --gid 48 -c 'ftp daemon' ftp
RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd db5.3-util whois \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/vsftpd/empty /etc/vsftpd/user_conf /var/ftp /files && \
    touch /var/log/vsftpd.log && \
    rm -rf /files/ftp
COPY vsftpd*.conf /etc/
COPY vsftpd_virtual /etc/pam.d/
COPY *.sh /

VOLUME ["/files"]

EXPOSE 21 4559 4560 4561 4562 4563 4564

ENTRYPOINT ["/entry.sh"]
CMD ["vsftpd-nginx"]