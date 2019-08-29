# spark-docker

## Start Spark Cluster
```
$ docker-compose up -d
```

## Change the number of workers
```
$ docker-compose up -d --scale worker=3
```

## Execute spark-shell
```
$ docker container exec spark-docker_master_1 /spark/bin/spark-shell --master spark://localhost:7077
```
