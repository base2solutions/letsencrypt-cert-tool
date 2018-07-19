FROM alpine:edge

RUN apk -v --update add \
        python \
        py-pip \
        certbot \
        bash \
        && \
    apk add --no-cache --virtual openssl-dev qt-dev openssl \
    && \
    pip install --upgrade awscli==1.15.40 && \
    pip install --upgrade requests-toolbelt && \
    apk -v --purge del py-pip \
    && \
    rm /var/cache/apk/* \
    && \
    rm -f /usr/lib/python2.7/distutils/command/*.exe

ADD route53letsencrypt.sh /bin/

RUN addgroup -g 1000 -S autocert && adduser -u 1000 -S autocert -G autocert && mkdir autocerts && chown -R autocert:autocert /autocerts

# Backwards compatibility for existing deployments
RUN ln -s /bin/route53letsencrypt.sh /usr/local/bin/route53letsencrypt.sh

USER autocert

WORKDIR /autocerts

ENTRYPOINT ["route53letsencrypt.sh"]