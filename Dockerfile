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
  && apt-get install -y systemd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

RUN wget --quiet -c https://github.com/containous/traefik/releases/download/v2.0.0/traefik_v2.0.0_linux_amd64.tar.gz -O - | tar -xz \
  && mv traefik /usr/bin \
  && chmod +x /usr/bin/traefik

RUN mkdir -p /etc/traefik

RUN chmod 644 traefik.toml \
    && mv traefik.toml $TRAEFIK_CONFIG_DIR

RUN chmod 644 dynamic_conf.toml \
    && mv dynamic_conf.toml $TRAEFIK_CONFIG_DIR

RUN chmod 644 traefik.service \
    &&chown root:root traefik.service \
    && mv traefik.service /etc/systemd/system

RUN systemctl daemon-reload
RUN service traefik start

VOLUME [ "/sys/fs/cgroup" ]
