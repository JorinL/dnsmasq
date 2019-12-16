FROM alpine:edge
#FORK https://hub.docker.com/r/jpillora/dnsmasq/dockerfile
LABEL maintainer="dev@jpillora.com"

EXPOSE 69/udp
EXPOSE 53/udp
EXPOSE 53/tcp
EXPOSE 8080/tcp

# webproc release settings
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
RUN rm /etc/resolv.conf
RUN echo -e -n "nameserver 127.0.0.1" >> /etc/resolv.conf
RUN echo -e -n "search pxe.svc.cluster.local svc.cluster.local cluster.local fritz.box" >> /etc/resolv.conf
RUN echo -e -n "options ndots:5" >> /etc/resolv.conf
#run!
ENTRYPOINT ["webproc","--config","/etc/dnsmasq/dnsmasq.conf","--","dnsmasq","--no-daemon"]
