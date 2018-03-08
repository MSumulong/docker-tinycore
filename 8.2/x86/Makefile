IMAGE_NAME := tinycore
IMAGE_TAG := 8.2-x86
TMP_IMAGE_NAME := $(IMAGE_NAME)-tar-builder
TMP_CONTAINER_NAME := $(IMAGE_NAME)-tar-exporter

.PHONY: all build stop clean

all: build

build: Dockerfile bin/rootfs.tar.gz bin/squashfs-tools.tar.gz
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest

bin/rootfs.tar.gz: src/Dockerfile src/tce-load.patch
	mkdir -p bin/
	docker run --name $(TMP_CONTAINER_NAME) $(TMP_IMAGE_NAME)
	docker wait $(TMP_CONTAINER_NAME)
	docker cp $(TMP_CONTAINER_NAME):/tmp/rootfs.tar.gz ./bin/
	docker rm $(TMP_CONTAINER_NAME)
	docker rmi $(TMP_IMAGE_NAME)

bin/squashfs-tools.tar.gz: src/build_squashfs_tools.sh
	mkdir -p bin/
	docker run -d --privileged --name $(TMP_CONTAINER_NAME) alpine sleep 180
	docker start $(TMP_CONTAINER_NAME)
	docker exec -i $(TMP_CONTAINER_NAME) /bin/sh -c 'cat > /tmp/build_squashfs_tools.sh; /bin/sh /tmp/build_squashfs_tools.sh' < src/build_squashfs_tools.sh > squashfs-tools.tar.gz
	docker kill $(TMP_CONTAINER_NAME)
	docker rm $(TMP_CONTAINER_NAME)

clean:
	docker ps | grep -q $(TMP_CONTAINER_NAME) && docker stop $(TMP_CONTAINER_NAME) || true
	docker ps -a | grep -q $(TMP_CONTAINER_NAME) && docker rm $(TMP_CONTAINER_NAME) || true
	docker images $(IMAGE_NAME) | grep -q $(IMAGE_TAG) && docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
	docker images $(IMAGE_NAME) | grep -q latest && docker rmi $(IMAGE_NAME):latest || true
	docker images | grep -q $(TMP_IMAGE_NAME) && docker rmi $(TMP_IMAGE_NAME) || true
	-rm -rf bin
