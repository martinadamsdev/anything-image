# 使用官方的 Alpine 镜像作为构建阶段的基础镜像
FROM alpine as builder

# 定义 PostgreSQL 版本
ARG POSTGRES_VERSION=16.3

# 安装构建 PostgreSQL 所需的依赖项
RUN apk update && \
    apk add --no-cache \
        build-base \
        linux-headers \
        bash \
        tar \
        wget \
        bison \
        flex \
        perl \
        python3 \
        icu-dev \
        readline-dev \
        libxml2-dev \
        libxslt-dev \
        zlib-dev \
        shadow

# 创建 postgres 用户和组
RUN addgroup -S postgres && adduser -S postgres -G postgres

# 下载并解压 PostgreSQL 源码包
RUN wget https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.gz && \
    tar -xzf postgresql-${POSTGRES_VERSION}.tar.gz

# 设置工作目录为解压后的 PostgreSQL 源码目录
WORKDIR /postgresql-${POSTGRES_VERSION}

# 配置、编译并安装 PostgreSQL
RUN ./configure --prefix=/usr/local --with-icu --with-libxml --with-libxslt && \
    make -j$(nproc) && \
    make install

# 使用 scratch 作为运行时镜像
FROM scratch

# 复制必要的目录并设置权限
COPY --from=builder /usr/local /usr/local
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /bin/sh /bin/sh
COPY --from=builder /bin/chmod /bin/chmod
COPY --from=builder /bin/chown /bin/chown
COPY --from=builder /bin/mkdir /bin/mkdir
COPY --from=builder /bin/cp /bin/cp
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /lib/libc.musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1
COPY --from=builder /usr/lib/libicutu.so.74.2 /usr/lib/libicutu.so.74.2
COPY --from=builder /usr/lib/libicui18n.so.74 /usr/lib/libicui18n.so.74
COPY --from=builder /usr/lib/icu /usr/lib/icu
COPY --from=builder /usr/lib/libicutu.so /usr/lib/libicutu.so
COPY --from=builder /usr/lib/libicuuc.so.74 /usr/lib/libicuuc.so.74
COPY --from=builder /usr/lib/pkgconfig/icu-i18n.pc /usr/lib/pkgconfig/icu-i18n.pc
COPY --from=builder /usr/lib/pkgconfig/icu-uc.pc /usr/lib/pkgconfig/icu-uc.pc
COPY --from=builder /usr/lib/pkgconfig/icu-io.pc /usr/lib/pkgconfig/icu-io.pc
COPY --from=builder /usr/lib/libicui18n.so /usr/lib/libicui18n.so
COPY --from=builder /usr/lib/libicui18n.so.74.2 /usr/lib/libicui18n.so.74.2
COPY --from=builder /usr/lib/libicudata.so /usr/lib/libicudata.so
COPY --from=builder /usr/lib/libicutu.so.74 /usr/lib/libicutu.so.74
COPY --from=builder /usr/lib/libicuio.so.74.2 /usr/lib/libicuio.so.74.2
COPY --from=builder /usr/lib/libicudata.so.74.2 /usr/lib/libicudata.so.74.2
COPY --from=builder /usr/lib/libicuuc.so.74.2 /usr/lib/libicuuc.so.74.2
COPY --from=builder /usr/lib/libicudata.so.74 /usr/lib/libicudata.so.74
COPY --from=builder /usr/lib/libicutest.so.74.2 /usr/lib/libicutest.so.74.2
COPY --from=builder /usr/lib/libicuio.so /usr/lib/libicuio.so
COPY --from=builder /usr/lib/libicutest.so.74 /usr/lib/libicutest.so.74
COPY --from=builder /usr/lib/libicuuc.so /usr/lib/libicuuc.so
COPY --from=builder /usr/lib/libicutest.so /usr/lib/libicutest.so
COPY --from=builder /usr/lib/libicuio.so.74 /usr/lib/libicuio.so.74
COPY --from=builder /usr/sbin/icupkg /usr/sbin/icupkg
COPY --from=builder /usr/bin/icuinfo /usr/bin/icuinfo
COPY --from=builder /usr/bin/icuexportdata /usr/bin/icuexportdata
COPY --from=builder /usr/bin/icu-config /usr/bin/icu-config
COPY --from=builder /usr/share/icu /usr/share/icu
COPY --from=builder /usr/lib/libreadline.so.8 /usr/lib/libreadline.so.8
COPY --from=builder /usr/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
COPY --from=builder /usr/local/lib/libpq.so.5 /usr/local/lib/libpq.so.5
COPY --from=builder /usr/lib/libxml2.so.2 /usr/lib/libxml2.so.2
COPY --from=builder /lib/libz.so.1 /lib/libz.so.1
COPY --from=builder /usr/lib/liblzma.so.5 /usr/lib/liblzma.so.5
COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1

# 设置环境变量
ENV PATH=/usr/local/bin:$PATH

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh

# 暴露 PostgreSQL 默认端口
EXPOSE 5432

USER root
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql && \
  mkdir -p /tmp && chown -R postgres:postgres /tmp && \
  echo "host all all 0.0.0.0/0 trust" > /usr/local/share/postgresql/pg_hba.conf

# 切换到 postgres 用户
USER postgres

# 设置入口点
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]