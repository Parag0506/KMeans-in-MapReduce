# KMeans Clustering for Advertising Data

This project utilizes Java with the MapReduce framework to perform KMeans clustering on advertising performance data, aiming to categorize key phrases based on performance metrics like bid amounts, impressions, clicks, and ad ranks. The purpose is to uncover underlying patterns in advertising strategies, offering insights that could potentially guide advertisers towards more impactful methodologies.

## Getting Started

### Prerequisites

- Java JDK 8 or higher
- Apache Hadoop 3.x environment set up for MapReduce jobs
- Maven for managing project dependencies and building the project

### Installation

1. Clone the repository to your local machine:

```sh
git clone https://github.com/KMeans/project-parag-ghorpade.git
```

2. Navigate to the project directory:

```sh
cd project-parag-ghorpade
```

3. Build the project using Maven:

```sh
mvn clean package
```

This command generates a JAR file in the target/ directory, which can be used to run the MapReduce job.

### Running the MapReduce Job

1. Make sure your Hadoop services are running. If not, start them using the start-dfs.sh and start-yarn.sh scripts in your Hadoop installation.
2. Submit the MapReduce job using the Hadoop jar command. Replace <input-path>, <output-path>, and <centroids-path> with your specific paths:

```sh
hadoop jar target/kmeans-1.0.jar kc.KMeans <input-path> <output-path> <centroids-path>
```

- <input-path>: Path to the input dataset in HDFS.
- <output-path>: HDFS path where the job's output will be saved. This path must not exist before running the job.
- <centroids-path>: Local filesystem path to the file containing initial centroid values.

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

## Acknowledgments

- Yahoo! for providing the Search Marketing Advertiser Bid-Impression-Click dataset.
- Apache Hadoop and Apache Maven communities for their open-source software.

## Contact

Parag Ghorpade - [Github Profile](https://github.com/Parag0506)

Feel free to reach out for any questions or contributions to the project.
