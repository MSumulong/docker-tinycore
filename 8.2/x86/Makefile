IMAGE_NAME := tinycore
TCL_VER := 8.2.1
TCL_ARCH := x86

TCL_VER_MAJOR := $(word 1,$(subst ., ,${TCL_VER}))
TCL_VER_MINOR := $(word 2,$(subst ., ,${TCL_VER}))
TCL_VER_PATCH := $(word 3,$(subst ., ,${TCL_VER}))
IMAGE_TAG := $(TCL_VER)-$(TCL_ARCH)
TMP_IMAGE_NAME := $(IMAGE_NAME)-tar-builder
TMP_CONTAINER_NAME := $(IMAGE_NAME)-tar-exporter

.PHONY: all build stop clean

all: build

build: Dockerfile bin/rootfs.tar.gz bin/squashfs-tools.tar.gz
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest

bin/rootfs.tar.gz: src/Dockerfile src/tce-load.patch
	mkdir -p bin/
	docker build -t $(TMP_IMAGE_NAME) --build-arg TCL_VER_MAJOR=$(TCL_VER_MAJOR) \
		--build-arg TCL_ARCH=$(TCL_ARCH) src
	docker run --name $(TMP_CONTAINER_NAME) $(TMP_IMAGE_NAME)
	docker wait $(TMP_CONTAINER_NAME)
	docker cp $(TMP_CONTAINER_NAME):/tmp/rootfs.tar.gz ./bin/
	docker rm $(TMP_CONTAINER_NAME)
	docker rmi $(TMP_IMAGE_NAME)

bin/squashfs-tools.tar.gz: src/build_squashfs_tools.sh
	mkdir -p bin/
	docker run -d --privileged --name $(TMP_CONTAINER_NAME) alpine sleep 180
	docker start $(TMP_CONTAINER_NAME)
	docker exec -i $(TMP_CONTAINER_NAME) /bin/sh -c \
		'cat > /tmp/build_squashfs_tools.sh; /bin/sh /tmp/build_squashfs_tools.sh \
		${TCL_VER_MAJOR} ${TCL_ARCH}' < src/build_squashfs_tools.sh > bin/squashfs-tools.tar.gz
	docker kill $(TMP_CONTAINER_NAME)
	docker rm $(TMP_CONTAINER_NAME)

check:
	# Display TinyCore info
	docker run --rm --name tcl_check $(IMAGE_NAME):$(IMAGE_TAG) /bin/sh -c \
		'cat /etc/motd; cat /etc/issue; cat /usr/share/doc/tc/release.txt'
	# Store version into a variable
	$(eval DOCKER_TCL_VER := $(shell docker run --rm --name tcl_check \
		$(IMAGE_NAME):$(IMAGE_TAG) /bin/sh -c 'cat /usr/share/doc/tc/release.txt'))
	# Verify versions match
	@test $(DOCKER_TCL_VER) = $(TCL_VER)

clean:
	docker ps | grep -q $(TMP_CONTAINER_NAME) && docker stop $(TMP_CONTAINER_NAME) || true
	docker ps -a | grep -q $(TMP_CONTAINER_NAME) && docker rm $(TMP_CONTAINER_NAME) || true
	docker images $(IMAGE_NAME) | grep -q $(IMAGE_TAG) && docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
	docker images $(IMAGE_NAME) | grep -q latest && docker rmi $(IMAGE_NAME):latest || true
	docker images | grep -q $(TMP_IMAGE_NAME) && docker rmi $(TMP_IMAGE_NAME) || true
	-rm -rf bin
