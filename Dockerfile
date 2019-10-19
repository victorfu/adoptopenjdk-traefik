FROM adoptopenjdk:11-jre-hotspot
LABEL maintainer "Victor Fu <supergothere@gmail.com>"

ENV TRAEFIK_BIN=/usr/bin/traefik
ENV TRAEFIK_CONFIG_DIR=/etc/traefik
ENV TRAEFIK_CONFIG=$TRAEFIK_CONFIG_DIR/traefik.toml
ENV TRAEFIK_DYNAMIC_CONFIG=$TRAEFIK_CONFIG_DIR/dynamic_conf.toml
ENV TRAEFIK_SERVICE=/etc/systemd/system/traefik.service

COPY traefik.toml .
COPY dynamic_conf.toml .
COPY traefik.service .

RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y systemd

RUN echo "Installing traefik into /usr/bin"
RUN wget -c https://github.com/containous/traefik/releases/download/v2.0.0/traefik_v2.0.0_linux_amd64.tar.gz -O - | tar -xz
RUN mv traefik /usr/bin

RUN echo "Creating traefik configuration directory"
RUN mkdir -p /etc/traefik

RUN echo "Installing traefik.toml into /etc/traefik"
RUN chmod 644 traefik.toml
RUN mv traefik.toml $TRAEFIK_CONFIG_DIR

RUN echo "Installing dynamic_conf.toml into /etc/traefik"
RUN chmod 644 dynamic_conf.toml
RUN mv dynamic_conf.toml $TRAEFIK_CONFIG_DIR

RUN echo "Installing traefik as systemd service"
RUN mv traefik.service /etc/systemd/system
RUN systemctl daemon-reload
RUN service traefik start
RUN systemctl enable traefik.service
