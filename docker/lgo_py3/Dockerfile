# REF:
# https://github.com/yunabe/lgo/blob/master/docker/image_py3/Dockerfile

#FROM golang:1.9.7
FROM intelaipg/intel-optimized-tensorflow:latest-mkl-py3                                          
MAINTAINER JimChiu
ARG GOLANG_VERSION=1.9.7
ARG GOLANG_DOWNLOAD_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
ARG GOLANG_DOWNLOAD_SHA256=88573008f4f6233b81f81d8ccf92234b4f67238df0f0ab173d75a302a1f3d6ee

# Install Jupyter Notebook
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	# libzmq3-dev \
	# python3-pip \
	git \
	musl-dev \
    mercurial \
# gcc for cgo
	# g++ \
	# gcc \
	# libc6-dev \
	# make \
	# pkg-config \
	&& rm -rf /var/lib/apt/lists/*
RUN pip3 install --upgrade pip && hash -r pip && pip3 install -U jupyter jupyterlab && jupyter serverextension enable --py jupyterlab --sys-prefix

# Support UTF-8 filename in Python (https://stackoverflow.com/a/31754469)
ENV LC_CTYPE=C.UTF-8

ENV LGOPATH /lgo
RUN mkdir -p $LGOPATH

# Add a non-root user with uid:1000 to follow the convention of mybinder to use this image from mybinder.org.
# https://mybinder.readthedocs.io/en/latest/dockerfile.html
ARG NB_USER=gopher
ARG NB_UID=1000
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    --home ${HOME} \
    ${NB_USER}

# Set up golang
ARG TF_TYPE=cpu 
ENV TARGET_DIRECTORY /usr/local
ENV GOROOT ${TARGET_DIRECTORY}/go
ENV GOPATH ${HOME}/go
# add .local/bin to PATH for Tensorflow 2.0
ENV PATH $GOPATH/bin:/usr/local/go/bin:$HOME/.local/bin:$PATH
# Intall Go
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
 	&& tar -C ${TARGET_DIRECTORY} -xzf golang.tar.gz \
    	&& rm golang.tar.gz \
    	&& mkdir -p "$GOPATH/src" "$GOPATH/bin"

# Install Tensorflow Go
ARG TFLIB_VERSION=1.13.1
ARG TARGET_OS=linux
RUN curl -L \
"https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-${TARGET_OS}-x86_64-${TFLIB_VERSION}.tar.gz" | tar -C $TARGET_DIRECTORY -xz
RUN ldconfig

# Install Python popular Data Science libraries
RUN pip3 install --user pandas matplotlib scikit-learn seaborn xlrd -q tensorflow==2.0.0-alpha0

# clean
RUN find /usr/lib/python* -name __pycache__ | xargs rm -r \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apk/*

# Appply correct permission and switch to USER account
RUN chown -R ${NB_USER}:${NB_USER} ${HOME} $GOPATH $LGOPATH
USER ${NB_USER}
WORKDIR ${HOME}

# Fetch lgo repository
RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

# Install packages used from example notebooks.
ENV GO_ITPKGS \
	gonum.org/v1/plot/... 
ENV GO_IPKGS \
	gonum.org/v1/gonum/...
ENV GO_PKGS \
#	go-hep.org/x/hep/csvutil/... \
	go-hep.org/x/hep/fit \
	go-hep.org/x/hep/hbook \
	github.com/kniren/gota/... \
	github.com/nfnt/resize \
	github.com/sajari/regression \
#	github.com/sjwhitworth/golearn/... \
	github.com/wcharczuk/go-chart \
	github.com/montanaflynn/stats \
	github.com/boltdb/bolt \
	github.com/patrickmn/go-cache \
	github.com/chewxy/math32 \
	github.com/chewxy/hm \
	gorgonia.org/vecf64 \
	gorgonia.org/vecf32 \
	github.com/awalterschulze/gographviz \
	github.com/leesper/go_rng \
	github.com/pkg/errors \
	github.com/stretchr/testify/assert \
	github.com/lib/pq \
	github.com/pa-m/sklearn \
# Install Tensorflow Go & examples
	github.com/tensorflow/tensorflow/tensorflow/go
ENV TFGO_EX \
	github.com/cigoic/tensorflow-and-go

#RUN go get ${GO_IPKGS}
#RUN go get -u ${GO_ITPKGS}
RUN go get ${GO_PKGS}
RUN go test github.com/tensorflow/tensorflow/tensorflow/go
RUN go get ${TFGO_EX}

# Install lgo
RUN lgo install && lgo installpkg ${GO_ITPKGS} ${GO_PKGS}
RUN python3 $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel


# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

# Notes:
# 1. Do not use ENTRYPOINT because mybinder need to run a custom command.
# 2. To use JupyterLab, replace "notebook" with "lab".
# 3. Set --allow-root in case you want to run jupyter as root.

# Configure Jupyter Notebook
RUN jupyter notebook --generate-config
RUN echo "c = get_config()" >> ${HOME}/.jupyter/jupyter_notebook_config.py
RUN echo "c.IPKernelApp.pylab = 'inline'" >> ${HOME}/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> ${HOME}/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ${HOME}/.jupyter/jupyter_notebook_config.py

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0"]
