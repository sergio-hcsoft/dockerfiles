current_dir = $(shell pwd)

PROJECT = dockerfiles
VERSION ?= latest
DOCKER_TAG= None
PYTHON_VERSION="3.7"

# Install system packages
.PHONY: install-common-dependencies
install-common-dependencies:
	apt-get update && \
	apt-get install -y --no-install-suggests --no-install-recommends \
		ca-certificates locales pkg-config apt-utils gcc g++ wget make cmake git curl flex ssh \
		libffi-dev libjpeg-turbo-progs libjpeg8-dev libjpeg-turbo8 libjpeg-turbo8-dev \
		libpng-dev libpng16-16 libglib2.0-0 bison gfortran \
		libsm6 libxext6 libxrender1 libfontconfig1 libhdf5-dev libopenblas-base libopenblas-dev \
		libfreetype6 libfreetype6-dev zlib1g-dev zlib1g xvfb python-opengl ffmpeg && \
	ln -s /usr/lib/x86_64-linux-gnu/libz.so /lib/ && \
	ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /lib/ && \
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen && \
	wget -O - https://bootstrap.pypa.io/get-pip.py | python3 && \
	rm -rf /var/lib/apt/lists/* && \
	echo '#!/bin/bash\n\\n\echo\n\echo "  $@"\n\echo\n\' > /browser && \
	chmod +x /browser

# Install Python 3.7 in Ubuntu 19.04
.PHONY: install-python3.7
install-python3.7:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.7 python3.7-dev python3-distutils python3-setuptools libhdf5-103

# Install Python 3.6 in Ubuntu 18.04
.PHONY: install-python3.6
install-python3.6:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.6 python3.6-dev python3-distutils python3-setuptools libhdf5-100\

# Install phantomjs for holoviews image save
.PHONY: install-phantomjs
install-phantomjs:
	apt-get install curl -y && \
	curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt-get install -y nodejs && \
	npm install phantomjs --unsafe-perm && \
	npm install -g phantomjs-prebuilt --unsafe-perm

# Install phantomjs for holoviews image save
.PHONY: install-python-libs
install-python-libs:
	pip3 install -U pip && \
	pip3 install --no-cache-dir cython && \
	pip3 install --no-cache-dir -r requirements.txt --no-use-pep517 && \
	pip3 install -U https://s3-us-west-2.amazonaws.com/ray-wheels/latest/ray-0.9.0.dev0-cp37-cp37m-manylinux1_x86_64.whl && \
	python3 -c "import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot"


.PHONY: remove-dev-packages
remove-dev-packages:
	pip3 uninstall -y cython && \
	apt-get remove -y cmake pkg-config flex bison curl libpng-dev \
		libjpeg-turbo8-dev zlib1g-dev libhdf5-dev libopenblas-dev gfortran \
		libfreetype6-dev libjpeg8-dev libffi-dev && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

.PHONY: install-tf
install-tf:
	pip install https://github.com/inoryy/tensorflow-optimized-wheels/releases/download/v2.1.0/tensorflow-2.1.0-cp37-cp37m-linux_x86_64.whl

.PHONY: install-pytorch
.install-pytorch:
	pip install torch torchvision

.PHONY: docker-push
docker-push:
	docker push fragiletech/"${DOCKER_TAG}":${VERSION}