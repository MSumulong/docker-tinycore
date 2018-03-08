FROM alpine

ARG TCL_VER_MAJOR
ARG TCL_ARCH

ADD tce-load.patch /tmp/
RUN apk add --no-cache curl \
    && curl -SLO http://www.tinycorelinux.net/$TCL_VER_MAJOR.x/$TCL_ARCH/release/distribution_files/rootfs.gz \
    && mkdir rootfs \
    && cd rootfs \
    && gzip -dc ../rootfs.gz | cpio -id \
    && rm -f ../rootfs.gz \
    && cd usr/bin \
    && patch < /tmp/tce-load.patch \
    && cd ../.. \
    && rm -f /tmp/tce-load.patch \
    && tar cf - . | gzip -c > /tmp/rootfs.tar.gz \
    && cd .. \
    && rm -rf rootfs

CMD ["/bin/true"]
