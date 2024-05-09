# MapReduce Clustering with PCA Visualization

This project applies the K-means clustering algorithm to segment anonymized keyphrase data based on performance metrics such as average bids, impressions, clicks, and rank using a MapReduce framework. The clusters are then visualized using Principal Component Analysis (PCA) for easy interpretation.

## Getting Started

### Prerequisites

- Python 3.x
- KMeans
- NumPy
- pandas
- scikit-learn
- matplotlib

### Installation

Install the required Python packages using pip:

```sh
pip install KMeans numpy pandas scikit-learn matplotlib
```

### Running the MapReduce Job

- Prepare your centroids file (initial_centroids.txt) with your initial guesses for the centroids. The centroids should be in CSV format with each centroid on its own line.

- Run the MapReduce job using the following command:

```sh
python MR_Cluster.py --centroids ./initial_centroids.txt --line-limit 1000 ./input/ydata-ysm-keyphrase-bid-imp-click-v1_0 -o ./output
```

This command will run the MR_Cluster.py script, which processes the first 1000 lines of ydata-ysm-keyphrase-bid-imp-click-v1_0. The output will be saved to the ./output directory.

#### Arguments

- --centroids: Path to the centroids file.
- --line-limit: (Optional) Maximum number of lines to process from the input file.

### Combine the output files into a single file using the following command:

```sh
cat ./output/part-* > ./output/consolidated_output.txt
```

### Post-Processing for PCA Visualization

After running the MapReduce job, you can visualize the resulting clusters using PCA.

1. Execute the PCA visualization script:

```sh
python PCA_Clusters.py
```

This script takes the output from the MapReduce job, applies PCA to reduce the dimensions, and plots the centroids of the clusters.

## Files Description

- `MR_Cluster.py`: The main MapReduce script that performs K-means clustering.
- `PCA_Clusters.py`: The Python script for visualizing clusters using PCA.
- `initial_centroids.txt`: The initial centroids for the K-means algorithm.
- `./input/ydata-ysm-keyphrase-bid-imp-click-v1_0`: The input dataset containing keyphrase performance data.
- `./output/consolidated_output.txt`: The output file containing the cluster assignments.

## Authors

Parag Ghorpade ghorpade.p@northeastern.edu

## Acknowledgments

Yahoo! Webscope Program for providing the dataset.
The KMeans and Python community for the libraries and tools.
