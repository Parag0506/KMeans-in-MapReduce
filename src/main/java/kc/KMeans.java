package kc;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.log4j.Logger;

// Main class implementing Tool interface for configuration flexibility
public class KMeans extends Configured implements Tool {
    private static final Logger logger = Logger.getLogger(KMeans.class);

    // Mapper class definition
    public static class KMeansMapper extends Mapper<Object, Text, IntWritable, Text> {
        private List<double[]> centroids = new ArrayList<>();

        // Setup method to load centroids from cache
        @Override
        protected void setup(Context context) throws IOException {
            Configuration conf = context.getConfiguration();
            URI[] cacheFiles = context.getCacheFiles();
            if (cacheFiles != null && cacheFiles.length > 0) {
                URI uri = cacheFiles[0];
                FileSystem fs = FileSystem.get(uri, conf);
                Path path = new Path(uri.toString());
                try (BufferedReader br = new BufferedReader(new InputStreamReader(fs.open(path)))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        double[] centroid = Arrays.stream(line.split(","))
                                                  .mapToDouble(Double::parseDouble)
                                                  .toArray();
                        centroids.add(centroid);
                    }
                } catch (IOException e) {
                    logger.error("Error reading centroids file: " + e.getMessage());
                    throw e;
                }
            } else {
                logger.warn("No centroid file present in the Distributed Cache.");
            }
        }

        // Method to find the closest centroid for a given data point
        private int closestCentroid(double[] point) {
            int closestIndex = -1;
            double closestDistance = Double.MAX_VALUE;
            for (int i = 0; i < centroids.size(); i++) {
                double distance = 0.0;
                for (int j = 0; j < point.length; j++) {
                    distance += Math.pow(point[j] - centroids.get(i)[j], 2);
                }
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestIndex = i;
                }
            }
            return closestIndex;
        }

        // Map method that processes each line of input and assigns it to the closest centroid
        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String[] parts = value.toString().split("\t");
            if (parts.length < 7)
                return; // Skip invalid lines
            try {
                double avgBid = Double.parseDouble(parts[4]);
                double impressions = Double.parseDouble(parts[5]);
                double clicks = Double.parseDouble(parts[6]);
                double rank = Double.parseDouble(parts[2]);
                double[] point = { avgBid, impressions, clicks, rank };

                int closestCentroidIndex = closestCentroid(point);
                context.write(new IntWritable(closestCentroidIndex), value);
            } catch (NumberFormatException e) {
                logger.warn("Skipping line: " + value.toString() + ", due to NumberFormatException.");
            }
        }
    }

    // Reducer class definition
    public static class KMeansReducer extends Reducer<IntWritable, Text, IntWritable, Text> {
        // Reduce method aggregates centroid data and recalculates the centroid position
        @Override
        public void reduce(IntWritable key, Iterable<Text> values, Context context)
                throws IOException, InterruptedException {
            double sumAvgBid = 0, sumImpressions = 0, sumClicks = 0, sumRank = 0;
            int count = 0;

            for (Text value : values) {
                String[] parts = value.toString().split("\t");
                double avgBid = Double.parseDouble(parts[4]);
                double impressions = Double.parseDouble(parts[5]);
                double clicks = Double.parseDouble(parts[6]);
                double rank = Double.parseDouble(parts[2]);

                sumAvgBid += avgBid;
                sumImpressions += impressions;
                sumClicks += clicks;
                sumRank += rank;
                count++;
            }

            if (count > 0) {
                String newCentroid = String.format("%.2f,%.2f,%.2f,%.2f",
                        sumAvgBid / count, sumImpressions / count, sumClicks / count, sumRank / count);
                context.write(key, new Text(newCentroid));
            }
        }
    }

    // Main run method to set up job configuration
    @Override
    public int run(String[] args) throws Exception {
        if (args.length != 4) {
            System.err.println("Usage: KMeans <input path> <output path> <centroids path> <K>");
            System.exit(-1);
        }

        Configuration conf = getConf();
        Job job = Job.getInstance(conf, "KMeans");
        job.setJarByClass(KMeans.class);
        job.setMapperClass(KMeansMapper.class);
        job.setReducerClass(KMeansReducer.class);
        job.setOutputKeyClass(IntWritable.class);
        job.setOutputValueClass(Text.class);

        job.addCacheFile(new URI(args[2])); // Add centroid file to distributed cache
        FileInputFormat.addInputPath(job, new Path(args[0] + "/ydata-ysm-keyphrase-bid-imp-click-v1_0"));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        return job.waitForCompletion(true) ? 0 : 1;
    }

    // Main method to execute the program
    public static void main(String[] args) {
        try {
            int res = ToolRunner.run(new Configuration(), new KMeans(), args);
            System.exit(res);
        } catch (Exception e) {
            logger.error("Exception occurred while running job.", e);
            System.exit(255);
        }
    }
}
