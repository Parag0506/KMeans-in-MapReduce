# AdCluster Insights: KMeans Clustering for Advertising Data

This project utilizes Java with the MapReduce framework to perform KMeans clustering on advertising performance data, aiming to categorize key phrases based on performance metrics like bid amounts, impressions, clicks, and ad ranks. The purpose is to uncover underlying patterns in advertising strategies, offering insights that could potentially guide advertisers towards more impactful methodologies.

![alt text](graphics/2336b0cb-2fd6-499e-9d74-4ef5bda88807.webp)

### Input Format

Input Format
The input dataset should be in a tab-separated format with the following fields:

- Day of the data record
- Anonymized account ID of the advertiser
- Rank of the advertisement
- Anonymized keyphrase (a list of anonymized keywords)
- Average bid for the keyphrase
- Number of impressions (times the ad was shown)
- Number of clicks (times users interacted with the ad)

### Initial Centroids File Format

The file specified by <centroids-path> should contain initial centroid values, one centroid per line, with values comma-separated:

```sh
bid,impressions,clicks,rank
```

## Output

The MapReduce job outputs recalculated centroid values after processing the dataset. Each line in the output file represents a centroid with its updated values, formatted as follows:

```sh
centroid_id    avg_bid,impressions,clicks,rank
```

## Table of Contents
- [Prerequisites](#prerequisites)
- [Local Installation](#local-installation)
  - [macOS and Ubuntu](#macos-and-ubuntu)
- [Docker Deployment](#docker-deployment)
- [Running the Application](#running-the-application)
- [AWS Deployment](#aws-deployment)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [Acknowledgement](#acknowledgments)
- [Contact](#contact)
- [License](#license)

## Prerequisites
Before you begin, ensure you have the following installed:
- Java JDK 11
- Apache Maven
- Apache Hadoop 3.x
- Apache Spark 3.x
- Docker (optional for Docker deployment)
- AWS CLI (configured for AWS deployment)

## Local Installation
### macOS and Ubuntu

#### Step 1: Install Common Utilities and Packages
- **macOS:**
  ```bash
  brew install wget curl vim make
  # tzdata is generally not required for macOS, as timezone handling is built into the OS
  ```
- **Ubuntu:**
  ```bash
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends apt-utils wget curl vim make
  sudo apt-get install -y tzdata
  ```

#### Step 2: Install Java JDK 11
- **macOS:**
  ```bash
  brew install openjdk@11
  ```
- **Ubuntu:**
  ```bash
  sudo apt update
  sudo apt install -y openjdk-11-jdk
  ```
#### Step 3: Set JAVA_HOME Environment Variable
- **Add to your .bashrc or .zshrc file:**
  ```bash
  export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
  # For macOS, adjust JAVA_HOME accordingly:
  export JAVA_HOME=/usr/local/opt/openjdk@11
  ```

#### Step 4: Install Maven
- **macOS and Ubuntu:**
  ```bash
  brew install maven # macOS
  sudo apt install maven # Ubuntu
  ```
#### Step 5: Install AWS CLI
- **macOS:**
  ```bash
  brew install awscli
  ```
- **Ubuntu:**
  ```bash
  sudo apt-get install -y awscli
  ```
#### Step 6: Install Scala using Coursier (For Future implementation)
- **Common for both OS:**
  ```bash
  curl -fLo cs https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz
  gunzip cs
  chmod +x cs
  ./cs setup -y
  ./cs install scala:2.12.17 scalac:2.12.17
  ```

#### Step 7: Install Hadoop
- **Common for both OS:**
  ```bash
  wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz
  tar -xzf hadoop-3.3.5.tar.gz -C /usr/local
  sudo mv /usr/local/hadoop-3.3.5 /usr/local/hadoop
  ```

#### Step 8: Install Spark [For Spark Code to be added in future]
- **Common for both OS:**
  ```bash
    wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-without-hadoop.tgz
    tar -xzf spark-3.3.2-bin-without-hadoop.tgz -C /usr/local
    sudo mv /usr/local/spark-3.3.2-bin-without-hadoop /usr/local/spark
  ```

#### Step 9: Set Environment Variables
- **Add the following lines to your shell configuration file (.bashrc, .zshrc, etc.):**
  ```bash
    export HADOOP_HOME=/usr/local/hadoop
    export SPARK_HOME=/usr/local/spark
    export SCALA_HOME=$HOME/.local/share/coursier/bin
    export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin
  ```
## Docker Deployment
#### Building the Docker Image
- **For ARM64 architecture:**
  ```bash
    docker build -t kmeans-project .
  ```
- **For AMD64 architecture (adjust Dockerfile as needed):**
  ```bash
    docker build -f DockerfileAMD -t kmeans-project .
  ```

#### Running the Container
  ```bash
    docker run -it --name kmeans-container kmeans-project
  ```
#### Accessing the Container
  ```bash
    docker exec -it kmeans-container bash
  ```
## Running the Application
#### Using Makefile
Ensure your Makefile is properly set up to handle tasks from compilation to cleanup:

- **Compile the project:**
```bash
    make jar
```

- **Run KMeans locally or within Docker:**
```bash
    make run-kmeans
```

- **Clean up generated output files:**
```bash
    make clean-local-output
```

## AWS Deployment

#### Setup and Configuration
- **Configure your AWS CLI and ensure your credentials are set up:**
```bash
    # Make sure to add your AWS Credentials for the following locations:-
    ~/.aws/config
    ~/.aws/credentials
```

#### Launch and Manage EMR Cluster
- **Create a bucket on S3:**
```bash
    make make-bucket
```
- **Upload the dataset to S3 Bucket:**
```bash
    make upload-input-aws
```
- **Upload the app jar to S3 Bucket:**
```bash
    make upload-app-aws
```
- **Deploy the application on AWS EMR:**
```bash
    make aws
```
- **Download results from AWS S3 after execution:**
```bash
    make download-output-aws
```

## Cleanup
#### Local and AWS Resource Management
- **Local cleanup:**
```bash
    make clean-local-output
```
- **AWS cleanup (to avoid unnecessary charges):**
```bash
    make delete-output-aws
    aws emr terminate-clusters --cluster-ids <cluster-id>
```

## Contributing
Contributions to enhance the project are welcome. Please create a branch for your contributions.

## Acknowledgments

- Yahoo! for providing the Search Marketing Advertiser Bid-Impression-Click dataset. A4 - Yahoo Data Targeting User Modeling, Version 1.0 (Hosted on AWS)(3.7Gb)
- Apache Hadoop and Apache Maven communities for their open-source software.

## Contact

Parag Ghorpade - [Github Profile](https://github.com/Parag0506)

Feel free to reach out for any questions or contributions to the project.

## License
Distributed under the MIT License. See LICENSE for more information.