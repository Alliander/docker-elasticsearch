FROM docker.elastic.co/elasticsearch/elasticsearch:5.4.1

COPY /config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

