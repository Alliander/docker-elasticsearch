FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.1

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-s3
