# 使用官方的 Alpine 镜像作为构建阶段的基础镜像
FROM alpine as builder

# 定义 Redis 下载 URL
ARG REDIS_TAR_URL=https://download.redis.io/redis-stable.tar.gz

# 更新包管理器并安装构建所需的依赖项
RUN apk update && \
    apk add --no-cache --virtual .build-deps build-base linux-headers tar wget make gcc && \
    # 下载 Redis 源码包并保存为 redis.tar.gz
    wget -O redis.tar.gz ${REDIS_TAR_URL} && \
    # 创建目标目录 /redis 并解压 Redis 源码包到该目录
    mkdir -p /redis && \
    tar -xzf redis.tar.gz -C /redis --strip-components=1

# 设置工作目录为解压后的 Redis 源码目录
WORKDIR /redis

# 编译 Redis 源码
RUN make

# 使用最小化的 Alpine 镜像作为最终的运行时镜像
FROM alpine

# 从构建阶段复制编译后的 Redis 二进制文件到运行时镜像中
COPY --from=builder /redis/src/redis-server /usr/local/bin/
COPY --from=builder /redis/src/redis-cli /usr/local/bin/

# 创建 Redis 配置和数据目录
RUN mkdir /etc/redis && mkdir /data

# 从构建阶段复制 Redis 示例配置文件到运行时镜像中
COPY --from=builder /redis/redis.conf /etc/redis/

# 暴露 Redis 默认端口 6379
EXPOSE 6379

# 设置 Redis 数据目录环境变量
ENV REDIS_DATA_DIR=/data

# 运行 Redis 服务器，并指定配置文件
CMD ["redis-server", "/etc/redis/redis.conf"]
