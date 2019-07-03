#---------------------------------------------------------------------
# Base instance to build MKL based Tensorflow on Clear Linux
#---------------------------------------------------------------------

FROM clearlinux as base
LABEL maintainer=liang.case@gmail.com

# tf with vnni support and bug fixes
#ARG TF_COMMIT_SHA=47ab68d265a96b6e7be06afd1b4b47e0114c0ee9
ARG swupd_args

# update os and add required bundles
RUN swupd update $swupd_args && \
    swupd bundle-add machine-learning-basic git \
    java-basic sysadmin-basic package-utils devpkg-zlib

RUN ln -s -f /usr/bin/pip3.7 /usr/bin/pip
RUN ln -s -f /usr/bin/python3.7 /usr/bin/python

RUN pip install \
    keras_applications>=1.0.6 \
    keras_preprocessing>=1.0.5

# Install bazel v0.24.0 or lower to build TF 1.x
# Install bazel v0.24.1 or later to build TF 2.x
WORKDIR /tmp
ARG BAZEL_VER=0.24.1
RUN curl -L https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-x86_64.sh > /tmp/bazel-installer-linux-x86_64.sh

RUN chmod +x /tmp/bazel-installer-linux-x86_64.sh &&\
	./bazel-installer-linux-x86_64.sh --user 
#&&\
#export PATH="$PATH:$HOME/bin"

# clone build and install tensorflow 1.13.1
WORKDIR /tensorflow_src
RUN git clone https://github.com/tensorflow/tensorflow.git /tensorflow_src && \
	git checkout -b 2.0.0-beta1
#	git checkout -b 1.14.0
#    git checkout -b quantized ${TF_COMMIT_SHA}

RUN export CC_OPT_FLAGS=$(grep flags -m1 /proc/cpuinfo | cut -d ":" -f 2 | tr '[:upper:]' '[:lower:]' | { read FLAGS; OPT="-march=broadwell -mtune=native"; for flag in $FLAGS; do case "$flag" in "sse4_1" | "sse4_2" | "ssse3" | "fma" | "cx16" | "popcnt" | "avx" | "avx2") OPT+=" -m$flag";; esac; done; MODOPT=${OPT//_/\.}; echo "$MODOPT"; })

RUN export COPTFLAGS=$(grep flags -m1 /proc/cpuinfo | cut -d ":" -f 2 | tr '[:upper:]' '[:lower:]' | { read FLAGS; OPT="-march=broadwell -mtune=native"; for flag in $FLAGS; do case "$flag" in "sse4_1" | "sse4_2" | "ssse3" | "fma" | "cx16" | "popcnt" | "avx" | "avx2") OPT+=" --copt=-m$flag";; esac; done; MODOPT=${OPT//_/\.}; echo "$MODOPT"; })

RUN \
  export PYTHON_BIN_PATH=/usr/bin/python3.7 &&\
  export USE_DEFAULT_PYTHON_LIB_PATH=1 &&\
#  export CC_OPT_FLAGS="-march=native -mtune=native" &&\
#for AMD#  export CC_OPT_FLAGS="-march=znver1 -mtune=znver1" &&\
  export TF_NEED_JEMALLOC=1  &&\
  export TF_NEED_KAFKA=0 &&\
  export TF_NEED_OPENCL_SYCL=0 &&\
  export TF_NEED_GCP=0 &&\
  export TF_NEED_HDFS=0 &&\
  export TF_NEED_S3=0 &&\
  export TF_ENABLE_XLA=1 &&\
  export TF_NEED_GDR=0 &&\
  export TF_NEED_VERBS=0 &&\
  export TF_NEED_OPENCL=0 &&\
  export TF_NEED_MPI=0 &&\
  export TF_NEED_TENSORRT=0 &&\
  export TF_SET_ANDROID_WORKSPACE=0 &&\
  export TF_DOWNLOAD_CLANG=0 &&\
  export TF_NEED_CUDA=0 &&\
#  export TF_BUILD_MAVX=MAVX512 &&\
  export HTTP_PROXY=`echo $http_proxy | sed -e 's/\/$//'` &&\
  export HTTPS_PROXY=`echo $https_proxy | sed -e 's/\/$//'`
RUN ./configure

RUN bazel --output_base=/tmp/bazel build --repository_cache=/tmp/cache \
   --config=opt --config=mkl \
# build Tensorflow 2.x instead of 1.x
   --config=v2 \
   --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
   --copt=-O3 \
   $COPTFLAGS \
#   --copt=-mavx \
#   --copt=-mavx2 \
#   --copt=-march=skylake-avx512 \
#   --copt=-mfma \
   --copt=-mfpmath=both -k \
   //tensorflow/tools/pip_package:build_pip_package
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tf/

#---------------------------------------------------------------------
# Tensorflow with MKL-DNN on Clear Linux
#---------------------------------------------------------------------

FROM clearlinux
LABEL maintainer=liang.case@gmail.com

#ARG HOROVOD_VERSION=0.16.1
ARG swupd_args

# update os and add required bundles
RUN swupd update $swupd_args && \
    swupd bundle-add git \
    openssh-server sysadmin-basic \
    devpkg-openmpi python3-basic jupyter devpkg-opencv

RUN ln -s -f /usr/bin/pip3.7 /usr/bin/pip &&\
    ln -s -f /usr/bin/python3.7 /usr/bin/python

# install keras, nltk and jupyterhub
RUN pip --no-cache-dir install \
    keras_applications>=1.0.6 \
    keras_preprocessing>=1.0.9 \
    nltk>=3.4 jupyterhub>=0.9.4

# install tensorflow
RUN pip uninstall -y tensorflow tensorboard &&\
    pip install --upgrade pip protobuf>=3.7
COPY --from=base /tmp/tf/*.whl /tmp/.
RUN pip --no-cache-dir  install /tmp/tensorflow*.whl

# install horovod
# RUN HOROVOD_WITH_TENSORFLOW=1 \
#    pip --no-cache-dir install horovod==${HOROVOD_VERSION}

# install tensorflow-datasets tensorflow-hub
RUN pip --no-cache-dir install tensorflow-datasets tensorflow-hub

# clean up and init
RUN rm -rf /tmp/*
WORKDIR /workspace
COPY ./set_env.sh /workspace/
RUN chmod -R a+w /workspace
ENTRYPOINT source /workspace/set_env.sh && /bin/bash
