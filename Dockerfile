# Use an ARM64-compatible base image
FROM arm64v8/ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils wget curl vim make tzdata openjdk-11-jdk maven awscli

# Install Scala using Coursier for ARM64
RUN curl -fL "https://github.com/VirtusLab/coursier-m1/releases/latest/download/cs-aarch64-pc-linux.gz" | gzip -d > cs && \
    chmod +x cs && \
    ./cs setup -y
ENV PATH="$PATH:/root/.local/share/coursier/bin"
RUN cs install scala:2.12.17 && cs install scalac:2.12.17

# Download and setup Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \
    tar -xvzf hadoop-3.3.5.tar.gz && \
    mv hadoop-3.3.5 /usr/local/hadoop-3.3.5

# Download and setup Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-without-hadoop.tgz && \
    tar -xvzf spark-3.3.2-bin-without-hadoop.tgz && \
    mv spark-3.3.2-bin-without-hadoop /usr/local/spark-3.3.2-bin-without-hadoop

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV HADOOP_HOME=/usr/local/hadoop-3.3.5
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV SCALA_HOME=/root/.local/share/coursier/bin
ENV SPARK_HOME=/usr/local/spark-3.3.2-bin-without-hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SCALA_HOME:$SPARK_HOME/bin
RUN echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> ~/.bash_aliases
RUN echo JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64 >> /usr/local/hadoop-3.3.5/etc/hadoop/hadoop-env.sh

# Set working directory
ADD . /app/
WORKDIR /app/
