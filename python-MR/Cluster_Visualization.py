import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import ast

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
        # The format is: [centroid_id, [centroid_coords]]\t[keyphrases]
        # First, remove the brackets and split by comma to isolate the centroid ID
        centroid_id_str, centroid_values_str = cluster_info[1:-1].split(", [", 1)
        centroid_id = int(centroid_id_str)  # Convert centroid ID to int

        # Convert the string representation of centroid values to a list of floats
        centroid_values = list(map(float, centroid_values_str[:-1].split(", ")))

        # Store the parsed data
        cluster_ids.append(centroid_id)
        centroids.append(centroid_values)

        keyphrases.append(keyphrases_str.strip('[]"').split('", "'))

# Plotting
fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")

# Scatter each data point and annotate it
for centroid, cid, kws in zip(centroids, cluster_ids, keyphrases):
    # Plotting the centroid
    ax.scatter(*centroid[:3], label=f"Cluster {cid}")

    # Annotating with the first keyphrase (for simplicity)
    ax.text(*centroid[:3], f"{kws[0]}", color="black")

# Setting labels for axes based on what the dimensions represent
ax.set_xlabel("Average Bid")
ax.set_ylabel("Impressions")
ax.set_zlabel("Clicks")

# Legend and plot title
ax.legend()
ax.set_title("3D Scatter Plot of Cluster Centroids")

plt.show()
