#!/bin/bash

set -e

chown redis:redis /data

exec /sbin/setuser redis /usr/local/bin/redis-server /etc/redis/redis.conf