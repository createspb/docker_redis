FROM phusion/baseimage:0.9.16
MAINTAINER Create Digital <hello@createdigital.me>

ENV HOME /root
CMD ["/sbin/my_init"]

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

ENV REDIS_VERSION 3.0.0
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.0.tar.gz
ENV REDIS_DOWNLOAD_SHA1 c75fd32900187a7c9f9d07c412ea3b3315691c65

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN buildDeps='gcc libc6-dev make'; \
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps

# Sentry service
RUN mkdir /etc/service/redis
ADD run_redis.sh /etc/service/redis/run
RUN chmod 755 /etc/service/redis/run

ADD redis.conf /etc/redis/redis.conf

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

