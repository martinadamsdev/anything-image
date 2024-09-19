# 阶段1: 构建阶段，下载并编译 Node.js
FROM alpine AS builder

ENV NODE_VERSION=20.17.0

# 安装构建 Node.js 所需的依赖工具，包括 ninja
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    g++ \
    make \
    python3 \
    libgcc \
    libstdc++ \
    linux-headers \
    curl \
    ninja \
    curl -fsSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz" \
    && curl -fsSLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt" \
    && grep " node-v$NODE_VERSION.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.gz" \
    cd "node-v$NODE_VERSION" \
    && ./configure --ninja \
    && ninja -C out/Release -j$(getconf _NPROCESSORS_ONLN) \
    && DESTDIR=/usr/local ninja -C out/Release install

# # 阶段2: 生成精简版运行时镜像
# FROM alpine:3.18 AS runtime

# # 安装 Node.js 运行时所需的依赖
# RUN apk add --no-cache libgcc libstdc++

# # 从构建阶段复制 Node.js 的二进制文件
# COPY --from=build /usr/local /usr/local

# # 创建非 root 用户
# RUN addgroup -S node && adduser -S node -G node

# # 切换到非 root 用户
# USER node

# # 设置工作目录
# WORKDIR /app

# # 默认命令：启动 Node.js REPL 或应用
# CMD ["node"]