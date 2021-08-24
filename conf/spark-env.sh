#!/usr/bin/env bash

SPARK_LOG_DIR="/var/log/spark"
SPARK_WORKER_DIR="/var/run/spark/work"
# - SPARK_WORKER_CORES, to set the number of cores to use on this machine
SPARK_WORKER_CORES=4
# - SPARK_WORKER_MEMORY, to set how much total memory workers have to give executors (e.g. 1000m, 2g)
SPARK_WORKER_MEMORY=4096m
# - SPARK_WORKER_INSTANCES, to set the number of worker processes per node
SPARK_WORKER_INSTANCES=1
