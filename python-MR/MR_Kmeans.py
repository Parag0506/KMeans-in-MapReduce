from KMeans.job import KMeans
from KMeans.step import MRStep
import numpy as np


class MRKMeansKeyphrase(KMeans):

    def configure_args(self):
        super(MRKMeansKeyphrase, self).configure_args()
        self.add_file_arg("--centroids", help="Path to the centroids file")
        self.add_passthru_arg(
            "--line-limit",
            type=int,
            default=None,
            help="Maximum number of lines to process",
        )

    def load_centroids(self):
        with open(self.options.centroids, "r") as file:
            self.centroids = np.array(
                [np.array(list(map(float, line.split(",")))) for line in file]
            )

    def mapper_init(self):
        self.load_centroids()
        self.num_lines_processed = 0

    def mapper(self, _, line):
        if (
            self.options.line_limit is not None
            and self.num_lines_processed >= self.options.line_limit
        ):
            return

        elements = line.split("\t")
        keyphrase = elements[3]  # Extracting the keyphrase for mapping
        point = np.array(
            [
                float(elements[4]),
                float(elements[5]),
                float(elements[6]),
                float(elements[2]),
            ]
        )  # avg_bid, impressions, clicks, rank

        distances = np.linalg.norm(point - self.centroids, axis=1)
        closest_centroid = np.argmin(distances)
        yield int(closest_centroid), (point.tolist(), keyphrase)

        self.num_lines_processed += 1

    def reducer(self, centroid_id, values):
        points, keyphrases = zip(*values)
        new_centroid = np.mean(np.array(points), axis=0).tolist()
        yield (centroid_id, new_centroid), list(
            set(keyphrases)
        )  # Emitting centroid with unique keyphrases

    def steps(self):
        return [
            MRStep(
                mapper_init=self.mapper_init, mapper=self.mapper, reducer=self.reducer
            )
        ]


if __name__ == "__main__":
    MRKMeansKeyphrase.run()
