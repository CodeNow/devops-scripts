FROM dockerfile/java:openjdk-7-jre

ENV NEO4J_HOME /neo4j

WORKDIR /
RUN \
  wget -q -O neo4j-2.1.6.tar.gz http://neo4j.com/artifact.php?name=neo4j-community-2.1.6-unix.tar.gz && \
  mkdir -p /neo4j && \
  tar xf neo4j-2.1.6.tar.gz && \
  mv neo4j-community-2.1.6/* /neo4j/ && \
  rm neo4j-2.1.6.tar.gz
WORKDIR /neo4j

## install lsof (for neo4js start)
RUN \
  apt-get update && \
  apt-get install -y lsof && \
  rm -rf /var/lib/apt/lists/*

VOLUME /neo4j-data

EXPOSE 7474

CMD ["bash", "start.sh"]
