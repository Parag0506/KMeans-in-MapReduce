# Makefile for Hadoop MapReduce KMeans clustering project.

# Customize these paths for your environment.
hadoop.root=/usr/local/hadoop-3.3.5
jar.name=kmeans-1.0.jar
jar.path=target/${jar.name}
job.name=kc.KMeans
local.input=input
local.output=output

# AWS EMR Execution
aws.emr.release=emr-6.10.0
aws.region=us-east-1
aws.bucket.name=kmeans-project
aws.subnet.id=subnet-6356553a
aws.input=input
aws.output=output
aws.log.dir=log
aws.num.nodes=4
aws.instance.type=m3.xlarge

# Compile code and build JAR
jar:
	mvn clean package

# Clean local output directory
clean-local-output:
	rm -rf ${local.output}*

# Run jobs for multiple values of K
run-kmeans:
	for K in 1 2 3; do \
		CENTROID_FILE="${local.input}/centroids_k$$K.txt"; \
		OUTPUT_DIR="${local.output}/${local.output}_K$$K"; \
		echo "Running KMeans for K=$$K with centroids from $$CENTROID_FILE to output in $$OUTPUT_DIR"; \
		${hadoop.root}/bin/hadoop jar ${jar.path} ${job.name} ${local.input} $$OUTPUT_DIR $$CENTROID_FILE $$K & \
	done
	wait

# HDFS and YARN management
start-hdfs:
	${hadoop.root}/sbin/start-dfs.sh

stop-hdfs:
	${hadoop.root}/sbin/stop-dfs.sh

start-yarn:
	${hadoop.root}/sbin/start-yarn.sh

stop-yarn:
	${hadoop.root}/sbin/stop-yarn.sh

format-hdfs:
	${hadoop.root}/bin/hdfs namenode -format
	init-hdfs

init-hdfs: start-hdfs
	${hadoop.root}/bin/hdfs dfs -mkdir -p /user/${hdfs.user.name}/${hdfs.input}

upload-input-hdfs:
	${hadoop.root}/bin/hdfs dfs -put ${local.input}/* /user/${hdfs.user.name}/${hdfs.input}

clean-hdfs-output:
	${hadoop.root}/bin/hdfs dfs -rm -r -f /user/${hdfs.user.name}/${hdfs.output}*

download-output-hdfs:
	mkdir ${local.output}
	${hadoop.root}/bin/hdfs dfs -get /user/${hdfs.user.name}/${hdfs.output}/* ${local.output}

# AWS S3 and EMR management
make-bucket:
	aws s3 mb s3://${aws.bucket.name}

upload-input-aws: make-bucket
	aws s3 sync ${local.input} s3://${aws.bucket.name}/${aws.input}

delete-output-aws:
	aws s3 rm s3://${aws.bucket.name}/${aws.output} --recursive

upload-app-aws:
	aws s3 cp ${jar.path} s3://${aws.bucket.name}/${jar.name}

aws:
	aws emr create-cluster \
	--name "KMeans Clustering" \
	--release-label ${aws.emr.release} \
	--step-concurrency-level 3 \
	--instance-groups '[{"InstanceCount":${aws.num.nodes},"InstanceGroupType":"CORE","InstanceType":"${aws.instance.type}"},{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"${aws.instance.type}"}]' \
	--steps '$(shell echo -n "["; for K in 1 2 3; do echo -n "{\"Args\":[\"${job.name}\",\"s3a://${aws.bucket.name}/input\",\"s3a://${aws.bucket.name}/output/output_K$$K\",\"s3a://${aws.bucket.name}/input/centroids_k$$K.txt\",\"$$K\"],\"Type\":\"CUSTOM_JAR\",\"Jar\":\"s3://${aws.bucket.name}/${jar.name}\",\"ActionOnFailure\":\"CONTINUE\",\"Name\":\"KMeans K=$$K\"},"; done | sed "s/,$$//"; echo -n "]")' \
	--applications Name=Hadoop \
	--log-uri s3://${aws.bucket.name}/${aws.log.dir} \
	--configurations '[{"Classification":"core-site","Properties":{"fs.s3a.impl":"org.apache.hadoop.fs.s3a.S3AFileSystem"}},{"Classification":"hadoop-env","Properties":{},"Configurations":[{"Classification":"export","Properties":{"JAVA_HOME":"/usr/lib/jvm/java-11-amazon-corretto.x86_64"}}]}]' \
	--use-default-roles --enable-debugging --auto-terminate

download-output-aws:
	mkdir ${local.output}
	aws s3 sync s3://${aws.bucket.name}/${aws.output} ${local.output}

# Mode switching and packaging
switch-standalone:
	cp config/standalone/*.xml ${hadoop.root}/etc/hadoop

switch-pseudo:
	cp config/pseudo/*.xml ${hadoop.root}/etc/hadoop

distro:
	rm -f kmeans-1.0.tar.gz
	rm -f kmeans-1.0.zip
	rm -rf build
	mkdir -p build/deliv/kmeans-1.0
	cp -r src build/deliv/kmeans-1.0
	cp -r config build/deliv/kmeans-1.0
	cp -r input build/deliv/kmeans-1.0
	cp pom.xml build/deliv/kmeans-1.0
	cp Makefile build/deliv/kmeans-1.0
	cp README.txt build/deliv/kmeans-1.0
	tar -czf kmeans-1.0.tar.gz -C build/deliv kmeans-1.0
	cd build/deliv && zip -rq ../../kmeans-1.0.zip kmeans-1.0

