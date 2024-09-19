#!/bin/sh
set -e

# 初始化数据库
/usr/local/bin/initdb --locale=en_US.UTF-8 -D /var/lib/postgresql/data

# 启动 PostgreSQL
/usr/local/bin/pg_ctl -D /var/lib/postgresql/data -o "-c listen_addresses='*'" -w start

# 设置 postgres 用户的密码
psql -c "ALTER USER postgres PASSWORD 'postgres';"

# 停止 PostgreSQL
/usr/local/bin/pg_ctl -D /var/lib/postgresql/data -m fast -w stop

# 启动 PostgreSQL
/usr/local/bin/postgres -D /var/lib/postgresql/data
