#!/bin/sh
set -e

# 如果是以 "-" 开头的命令，或者找不到命令，则将其作为 node 参数执行
if [ "${1#-}" != "${1}" ] || ! command -v "$1" > /dev/null; then
  set -- node "$@"
fi

exec "$@"
