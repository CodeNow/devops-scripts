FROM java:openjdk-7-jre

ENV NEO4J_HOME /neo4j

WORKDIR /
RUN \
  wget -q -O neo4j-2.2.0.tar.gz http://neo4j.com/artifact.php?name=neo4j-community-2.2.0-unix.tar.gz && \
  mkdir -p /neo4j && \
  tar xf neo4j-2.2.0.tar.gz && \
  mv neo4j-community-2.2.0/* /neo4j/ && \
  rm neo4j-2.2.0.tar.gz
WORKDIR /neo4j

VOLUME /neo4j-data

EXPOSE 7474 7473

CMD ["bash", "start.sh"]
