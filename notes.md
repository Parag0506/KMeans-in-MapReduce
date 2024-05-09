## Local Configuration (Docker Based)

# KMeans-Project

Example code for KMeans Project to run on Docker Instance

Docker commands:

- Build the image with `docker build . -t kmeans-project` (from the root directory of the project).
- Start the container with `docker run -itd --privileged kmeans-project`. This command will also return the id of the container.
- To start a bash terminal on the container: `docker exec -ti <container_id> bash` where you have to replace `<container_id>` with the id you get from `docker ps`).
- `docker cp <container_id>:/app/ ./docker_results` will copy the results back to the host in a `docker_results` folder.

ContainerID:

```sh
45d2ae7cbf803103f006eceedbca465b18938dbf40fca7b3b49c98dff73c7bdb
```
