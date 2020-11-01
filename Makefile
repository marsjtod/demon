## https://github.com/marsjtod/demon
# Handy commands:
# - `make docker-build`: builds DOCKERIMAGE (default: `image-processing:latest`)
PROJECT ?= demon-sfm
WORKSPACE ?= /workspace/$(PROJECT)
DOCKER_IMAGE ?= ${PROJECT}:latest

SHMSIZE ?= 444G
WANDB_MODE ?= run
DOCKER_OPTS := \
			--rm -it \
			--shm-size=${SHMSIZE} \
			-e HOST_HOSTNAME= \
			-e OMP_NUM_THREADS=1 -e KMP_AFFINITY="granularity=fine,compact,1,0" \
			-e OMPI_ALLOW_RUN_AS_ROOT=1 \
			-e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
			-e NCCL_DEBUG=VERSION \
            -e DISPLAY=${DISPLAY} \
            -e XAUTHORITY \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
			-v /root/.ssh:/root/.ssh \
			-v ~/.cache:/root/.cache \
			-v /mnt/e/data:/data \
			-v /mnt/e/raw-data:/raw-data \
			-v /mnt/e/data/datasets/KITTI_raw:${WORKSPACE}/kitti_data \
			-v /mnt/fsx/:/mnt/fsx \
			-v /dev/null:/dev/raw1394 \
			-v /tmp:/tmp \
			-v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v ${PWD}:${WORKSPACE} \
			-w ${WORKSPACE} \
			--privileged \
			--ipc=host \
			--network=host

NGPUS=$(shell nvidia-smi -L | wc -l)
MPI_CMD=mpirun \
		-allow-run-as-root \
		-np ${NGPUS} \
		-H localhost:${NGPUS} \
		-x MASTER_ADDR=127.0.0.1 \
		-x MASTER_PORT=23457 \
		-x HOROVOD_TIMELINE \
		-x OMP_NUM_THREADS=1 \
		-x KMP_AFFINITY='granularity=fine,compact,1,0' \
		-bind-to none -map-by slot -x NCCL_DEBUG=INFO -x NCCL_MIN_NRINGS=4 \
		--report-bindings


.PHONY: all clean docker-build docker-overfit-pose

all: clean

clean:
	find . -name "*.pyc" | xargs rm -f && \
	find . -name "__pycache__" | xargs rm -rf

# docker-build-cpu:
# 	docker build \
# 		-f docker/Dockerfile-cpu \
# 		-t cpu-${DOCKER_IMAGE} .

# docker-shell-cpu: docker-build-cpu
# 	docker run ${DOCKER_OPTS} cpu-${DOCKER_IMAGE} bash

# docker-jupyter-cpu: docker-build-cpu
# 	docker run ${DOCKER_OPTS} cpu-${DOCKER_IMAGE} \
# 		bash -c "jupyter notebook --port=7111 --ip=0.0.0.0 --allow-root --no-browser"

# docker-run-cpu: docker-build-cpu
# 	docker run ${DOCKER_OPTS} cpu-${DOCKER_IMAGE} \
# 		bash -c "${COMMAND}"

docker-build:
	docker build \
		-f docker/Dockerfile \
		-t ${DOCKER_IMAGE} .

docker-build-cpu:
	docker build \
		-f docker/Dockerfile-cpu \
		-t ${DOCKER_IMAGE}-cpu .


docker-shell-cpu: docker-build-cpu
	docker run --name ${PROJECT}-cpu ${DOCKER_OPTS} ${DOCKER_IMAGE}-cpu bash

docker-shell-cpu-2: docker-build-cpu
	docker run --name ${PROJECT}-cpu-2  ${DOCKER_OPTS} ${DOCKER_IMAGE}-cpu bash

docker-jupyter-cpu: docker-build-cpu
	docker run --name ${PROJECT}-cpu  ${DOCKER_OPTS} ${DOCKER_IMAGE}-cpu \
		bash -c "jupyter notebook --port=7222 --ip=0.0.0.0 --allow-root --no-browser"

docker-run-cpu: docker-build-cpu
	docker run --name ${PROJECT}-cpu  ${DOCKER_OPTS} ${DOCKER_IMAGE}-cpu \
		bash -c "${COMMAND}"



docker-shell: docker-build
	docker run --name ${PROJECT} --gpus all  ${DOCKER_OPTS} ${DOCKER_IMAGE} bash

docker-shell-2: docker-build
	docker run --name ${PROJECT}-2 --gpus all ${DOCKER_OPTS} ${DOCKER_IMAGE} bash

docker-jupyter: docker-build
	docker run --name ${PROJECT} --gpus all  ${DOCKER_OPTS} ${DOCKER_IMAGE} \
		bash -c "jupyter notebook --port=7222 --ip=0.0.0.0 --allow-root --no-browser"

docker-run: docker-build
	docker run --name ${PROJECT} --gpus all ${DOCKER_OPTS} ${DOCKER_IMAGE} \
		bash -c "${COMMAND}"