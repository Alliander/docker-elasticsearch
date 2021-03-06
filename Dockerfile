FROM docker.elastic.co/elasticsearch/elasticsearch:6.6.0

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-s3

COPY /config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
