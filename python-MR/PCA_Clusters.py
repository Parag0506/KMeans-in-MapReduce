import pandas as pd
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import numpy as np

# Initialize lists to hold parsed data
cluster_ids = []
centroids = []
keyphrases = []

# Parse the KMeans output file
with open("./output/consolidated_output.txt", "r") as file:
    for line in file:
        # Remove leading/trailing whitespace and split the cluster info and keyphrases part
        cluster_info, keyphrases_str = line.strip().split("\t", 1)

        # Extract the centroid ID and coordinates from cluster_info
        # First, remove the brackets and split by comma to isolate the centroid ID
        centroid_id_str, centroid_values_str = cluster_info[1:-1].split(", [", 1)
        centroid_id = int(centroid_id_str)  # Convert centroid ID to int

        # Convert the string representation of centroid values to a list of floats
        centroid_values = list(map(float, centroid_values_str[:-1].split(", ")))

        # Store the parsed data
        cluster_ids.append(centroid_id)
        centroids.append(centroid_values)

        keyphrases.append(keyphrases_str.strip('[]"').split('", "'))

# Now, convert these lists into a DataFrame
df_clusters = pd.DataFrame(
    {"Cluster ID": cluster_ids, "Centroid": centroids, "Keyphrases": keyphrases}
)

# Extract the centroids for PCA
centroids_matrix = np.array(df_clusters["Centroid"].tolist())

# Perform PCA
pca = PCA(n_components=2)
reduced_centroids = pca.fit_transform(centroids_matrix)

# Plot the reduced centroids
plt.figure(figsize=(10, 6))
for i, (x, y) in enumerate(reduced_centroids):
    plt.scatter(x, y, label=f"Cluster {i}")

plt.xlabel("PCA 1")
plt.ylabel("PCA 2")
plt.title("PCA of Cluster Centroids")
plt.legend()
plt.show()
