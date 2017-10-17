FROM openjdk:8u131-jdk-alpine

# Export HTTP & Transport
EXPOSE 9200 9300

ENV ES_VERSION 5.6.3

ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
ENV ES_TARBALL_ASC "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz.asc"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"

# Add user
RUN addgroup -g 1000 elasticsearch && adduser -D -G elasticsearch -s /bin/bash -u 1000 elasticsearch

# Install deps
RUN apk add --no-cache --update bash ca-certificates util-linux
RUN apk add --no-cache -t .build-deps wget gnupg openssl \
  && cd /tmp \
  && echo "===> Install Elasticsearch..." \
  && wget -O elasticsearch.tar.gz "$ES_TARBAL"; \
	if [ "$ES_TARBALL_ASC" ]; then \
		wget -O elasticsearch.tar.gz.asc "$ES_TARBALL_ASC"; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
		gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
		rm -r "$GNUPGHOME" elasticsearch.tar.gz.asc; \
	fi; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$ES_VERSION /elasticsearch \
  && echo "===> Creating Elasticsearch Paths..." \
  && for path in \
  	/elasticsearch/config \
  	/elasticsearch/config/scripts \
  	/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

# Install plugins
RUN /elasticsearch/bin/elasticsearch-plugin install --batch repository-s3 \
  && /elasticsearch/bin/elasticsearch-plugin install --batch x-pack



ENV PATH /elasticsearch/bin:$PATH

# Copy configuration
COPY config /elasticsearch/config

# Copy run script
COPY run.sh /elasticsearch

RUN chmod 755 /elasticsearch/run.sh
RUN chown -R elasticsearch:elasticsearch /elasticsearch

USER elasticsearch

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV CLUSTER_NAME elasticsearch-default
ENV NODE_MASTER false
ENV NODE_DATA false
ENV NODE_INGEST false
ENV HTTP_ENABLE true
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 1
ENV MAX_LOCAL_STORAGE_NODES 1
ENV SHARD_ALLOCATION_AWARENESS ""
ENV SHARD_ALLOCATION_AWARENESS_ATTR ""
ENV MEMORY_LOCK false
ENV DISCOVERY_HOSTS "es-master"
ENV XPACK_SECURITY_ENABLED false

# Volume for Elasticsearch data
VOLUME ["/data"]

ENTRYPOINT ["/elasticsearch/run.sh"]