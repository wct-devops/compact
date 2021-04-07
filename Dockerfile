FROM 10.45.80.1/public/alpine:3.11
COPY src /root

ADD comply.sh /usr/local/bin/comply.sh

RUN chmod +x /root/*.sh \
&& chmod +x /root/tar-split \
&& mkdir -p /root/run \
&& chmod +x /usr/local/bin/comply.sh \
&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
&& apk add --no-cache \
    docker-cli \
    squashfs-tools \
    python \
    -U tzdata \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& rm -rf /var/cache/apk/* \
     /usr/bin/docker-containerd \
     /usr/bin/docker-containerd-ctr \
     /usr/bin/docker-containerd-shim \
     /usr/bin/docker-init \
     /usr/bin/docker-proxy \
     /usr/bin/docker-runc \
     /usr/bin/containerd* \
     /usr/bin/runc \
     /usr/bin/ctr \
     /usr/bin/dockerd \
&& find /usr/ -name "*.pyc" -delete
ENTRYPOINT ["/usr/local/bin/comply.sh"]
