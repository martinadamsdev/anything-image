# 使用 Alpine 作为基础镜像，并命名为 base
FROM alpine as builder

# 定义 Nginx、OpenSSL 和 zlib 及 PCRE 的版本号
ARG NGINX_VERSION=1.27.0
ARG OPENSSL_VERSION=3.3.1
ARG ZLIB_VERSION=1.3.1
ARG PCRE_VERSION=10.44

# 更新包管理器并安装构建所需的依赖项
RUN apk update && \
    apk add --no-cache --virtual .build-deps tar wget gcc g++ make file perl linux-headers ca-certificates && \
    # 下载 Nginx、OpenSSL、zlib 和 PCRE 的源码包
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    wget http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz && \
    wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz && \
    # 解压下载的源码包
    tar zxf nginx-${NGINX_VERSION}.tar.gz && \
    tar zxf openssl-${OPENSSL_VERSION}.tar.gz && \
    tar zxf zlib-${ZLIB_VERSION}.tar.gz && \
    tar zxf pcre2-${PCRE_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    # 配置 Nginx 编译选项，包括 OpenSSL、zlib 和 PCRE 的路径
    ./configure --prefix=/usr/local/nginx \
                --with-cc-opt='-static' \
                --with-ld-opt='-static-libgcc' \
                --sbin-path=/sbin/nginx \
                --pid-path=/run/nginx.pid \
                --lock-path=/var/lock/nginx.lock \
                --conf-path=/etc/nginx/nginx.conf \
                --error-log-path=/dev/stderr \
                --http-log-path=/dev/stdout \
                --with-compat \
                --with-threads \
                --with-file-aio \
                --with-openssl=../openssl-${OPENSSL_VERSION} \
                --with-zlib=../zlib-${ZLIB_VERSION} \
                --with-pcre=../pcre2-${PCRE_VERSION} \
                --with-pcre-jit \
                --with-http_ssl_module \
                --with-http_v2_module \
                --with-http_gunzip_module \
                --with-http_gzip_static_module \
                --with-http_slice_module \
                --with-http_stub_status_module \
                --with-http_realip_module \
                --with-http_auth_request_module \
                --with-http_addition_module \
                --with-http_sub_module \
                --with-stream && \
    # 编译并安装 Nginx
    make && \
    make install

# 创建必要的目录和设置权限
RUN mkdir -p /usr/local/nginx /var/log/nginx /var/run /usr/share/nginx/html /run && \
    chown -R nobody:nobody /var/run /var/log/nginx /run

# 添加 nobody 用户和组，如果已经存在则忽略错误
RUN addgroup -S nobody || true && adduser -S nobody -G nobody || true

# 使用 scratch 作为运行时镜像
FROM scratch

# 精确复制 Nginx 二进制和配置文件到运行时镜像中
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /sbin/nginx /sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /var/log/nginx /var/log/nginx
COPY --from=builder /var/run /var/run
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /run /run
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# 复制必要的库文件
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

# 暴露 Nginx 的默认端口
EXPOSE 80

# 设置 Nginx 为容器的入口点
ENTRYPOINT ["/sbin/nginx", "-g", "daemon off;"]