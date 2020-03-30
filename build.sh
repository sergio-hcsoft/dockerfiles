#!/bin/bash

TAG="deep-learning"
PYTHON_VERSION="3.7"
UBUNTU_VERSION="19.04"
DEEP_LEARNING="NONE"
INSTALL_PHANTOM_JS=false
INSTALL_TENSORFLOW=false
INSTALL_PYTORCH=false
CONTAINER_VERSION="latest"
# Parse args

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  case "$1" in
    -v | --python ) PYTHON_VERSION="$2"; echo "SET version"; shift 2;;
    -d | --deep-learning ) DEEP_LEARNING="$2"; shift 2;;
    -j | --phantomjs ) INSTALL_PHANTOM_JS=true; shift;;
    -t | --tag ) TAG="$2"; shift 2;;
    -c | --tag-version) CONTAINER_VERSION="$2"; shift 2;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
# Set deep learning frameworks
case $DEEP_LEARNING in
     pytorch) INSTALL_PYTORCH=true;;
     torch) INSTALL_PYTORCH=true;;
     tensorflow) INSTALL_TENSORFLOW=true;;
     tf) INSTALL_TENSORFLOW=true;;
     all) INSTALL_TENSORFLOW=true INSTALL_PYTORCH=true;;
     *)
esac

if [ "$PYTHON_VERSION" = "3.6" ]; then  UBUNTU_VERSION="18.04"
fi

echo "PYTHON_VERSION" "$PYTHON_VERSION" "DL" "$DEEP_LEARNING" "PHANTOM_JS" $INSTALL_PHANTOM_JS \
  "TENSORFLOW" $INSTALL_TENSORFLOW "PYTORCH" $INSTALL_PYTORCH "CONTAINER_VERSION" ${CONTAINER_VERSION}

# build base container
docker build --pull -t fragiletech/base-py${PYTHON_VERSION}:${CONTAINER_VERSION} -f base-python . --build-arg INSTALL_PHANTOM_JS=${INSTALL_PHANTOM_JS} \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} --build-arg UBUNTU_VERSION=${UBUNTU_VERSION}

# build deep learning if dl frameworks passed as arguments
if [ ${DEEP_LEARNING} != "NONE" ]; then
docker build -t fragiletech/${TAG}-py${PYTHON_VERSION}:${CONTAINER_VERSION} -f deep-learning . --build-arg INSTALL_PYTORCH=${INSTALL_PYTORCH} \
  --build-arg INSTALL_TENSORFLOW=${INSTALL_TENSORFLOW} --build-arg BASE_VERSION=${CONTAINER_VERSION}
fi
