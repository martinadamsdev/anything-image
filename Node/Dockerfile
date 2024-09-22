FROM alpine:3.20

ENV NODE_VERSION=20.17.0

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
    && ARCH='' OPENSSL_ARCH='linux*' \
    && alpineArch="$(apk --print-arch)" \
    && case "${alpineArch##*-}" in \
        x86_64) ARCH='x64'; CHECKSUM="913547514c21152f09d46b8b140d30dd5ea40d2e3ac4ddc6ff3e12a666bec482"; OPENSSL_ARCH=linux-x86_64 ;; \
        x86) OPENSSL_ARCH=linux-elf ;; \
        aarch64) OPENSSL_ARCH=linux-aarch64 ;; \
        arm*) OPENSSL_ARCH=linux-armv4 ;; \
        ppc64le) OPENSSL_ARCH=linux-ppc64le ;; \
        s390x) OPENSSL_ARCH=linux-s390x ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
      esac \
    && curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # Remove unused OpenSSL headers to save ~34MB. See this NodeJS issue: https://github.com/nodejs/node/issues/46451
    && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} + \
    && apk del .build-deps \
    # smoke tests
    && node --version \
    && npm --version \
    && rm -rf /tmp/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["node"]