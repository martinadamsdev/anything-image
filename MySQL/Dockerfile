# 使用官方的 Alpine 镜像作为构建阶段的基础镜像
FROM alpine:latest as builder

# 定义 MySQL 版本
ARG MYSQL_VERSION=8.4.1

# 安装构建 MySQL 所需的依赖项
RUN apk update && apk add --no-cache \
    build-base \
    cmake \
    ncurses-dev \
    openssl-dev \
    bison \
    wget \
    perl \
    libtirpc-dev \
    rpcgen \
    gtest-dev \
    linux-headers \
    gcc \
    g++ \
    tar

# 下载并解压 MySQL 源码包
RUN wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-${MYSQL_VERSION}.tar.gz && \
    tar -xzf mysql-${MYSQL_VERSION}.tar.gz

# 创建构建目录
RUN mkdir -p build

# 进入构建目录，配置 MySQL
WORKDIR /mysql-${MYSQL_VERSION}/build
RUN cmake .. -DWITH_DEBUG=1 DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DFORCE_INSOURCE_BUILD=1 \
-DDOWNLOAD_BOOST=1 -DWITH_BOOST=boost -DCMAKE_INSTALL_PREFIX=/usr/local/mysql

# 设置工作目录为解压后的 MySQL 源码目录
# WORKDIR /mysql-${MYSQL_VERSION}

# 编译 MySQL 并捕获错误输出
# RUN make -j$(nproc) VERBOSE=1 > build.log 2>&1 || (tail -n 100 build.log && exit 1)
RUN make -j$(nproc) VERBOSE=1 -S

# 安装 MySQL
RUN make install

# 使用更小的基础镜像
FROM alpine:latest

# 安装运行 MySQL 所需的依赖项
RUN apk add --no-cache \
    libstdc++ \
    ncurses \
    openssl \
    libtirpc

# 创建 MySQL 用户和组
RUN addgroup -S mysql && adduser -S mysql -G mysql

# 从构建阶段复制 MySQL 安装和必要的库到运行时镜像中
COPY --from=builder /usr/local/mysql /usr/local/mysql

# 创建数据目录并设置权限
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld

# 删除不必要的文件以减少镜像体积
RUN rm -rf /usr/share/man /usr/share/doc /usr/share/info /var/cache/apk/*

# 设置环境变量
ENV PATH=/usr/local/mysql/bin:$PATH
ENV MYSQL_ROOT_PASSWORD=root

# 暴露 MySQL 默认端口
EXPOSE 3306

# 切换到 mysql 用户
USER mysql

# 初始化数据库并启动 MySQL
CMD ["/usr/local/mysql/bin/mysqld", "--user=mysql", "--datadir=/var/lib/mysql", "--initialize-insecure", "--console"]