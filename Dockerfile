FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository ppa:certbot/certbot \
  && apt-get update \
  && apt-get install -y zip python-pip certbot \
  && pip install --upgrade pip && pip install awscli

ADD route53letsencrypt.sh /usr/local/bin/

RUN groupadd -r autocert && useradd -r -g autocert autocert && mkdir autocerts && chown -R autocert:autocert /autocerts

USER autocert

WORKDIR /autocerts

ENTRYPOINT ["route53letsencrypt.sh"]