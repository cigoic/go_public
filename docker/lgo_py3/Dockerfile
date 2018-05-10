# REF:
# https://github.com/yunabe/lgo/blob/master/docker/image_py3/Dockerfile

#FROM golang:1.9.6
FROM tensorflow/tensorflow                                                           
MAINTAINER JimChiu
ENV GOLANG_VERSION 1.9.6
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 d1eb07f99ac06906225ac2b296503f06cc257b472e7d7817b8f822fe3766ebfe

# Set up golang
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# Intall Go
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
 	&& tar -C /usr/local -xzf golang.tar.gz \
    	&& rm golang.tar.gz \
    	&& mkdir -p "$GOPATH/src" "$GOPATH/bin" \
	&& chmod -R 777 "$GOPATH" \
 	&& curl -fsSL https://git.io/vDyrl -o /usr/local/bin/go-wrapper
# Install Tensorflow Go
ENV TF_TYPE cpu 
ENV TARGET_DIRECTORY /usr/local
RUN curl -L "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-$(go env GOOS)-x86_64-1.8.0.tar.gz" | tar -C $TARGET_DIRECTORY -xz
RUN ldconfig


# Install Jupyter Notebook
RUN apt-get update && apt-get install -y libzmq3-dev python3-pip \
	git \
	musl-dev \
        mercurial \
	&& rm -rf /var/lib/apt/lists/*
RUN curl https://bootstrap.pypa.io/get-pip.py | python3 && pip3 install -U jupyter jupyterlab && jupyter serverextension enable --py jupyterlab --sys-prefix

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
RUN chown -R ${NB_USER}:${NB_USER} ${HOME} $GOPATH $LGOPATH
USER ${NB_USER}
WORKDIR ${HOME}



# Fetch lgo repository
RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

# Install packages used from example notebooks.
ENV GO_PKGS github.com/nfnt/resize \
	gonum.org/v1/gonum/... \
	gonum.org/v1/plot/... \
	github.com/wcharczuk/go-chart \
	github.com/kniren/gota/... \
	github.com/sajari/regression \
	github.com/sjwhitworth/golearn/... \
	go-hep.org/x/hep/csvutil/... \
	go-hep.org/x/hep/fit \
	go-hep.org/x/hep/hbook \
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
	github.com/lib/pq

RUN go get -u ${GO_PKGS}

# Install Tensorflow Go
RUN go get github.com/tensorflow/tensorflow/tensorflow/go \
	&& go test github.com/tensorflow/tensorflow/tensorflow/go

# Install lgo
RUN lgo install && lgo installpkg ${GO_PKGS} \
	github.com/tensorflow/tensorflow/tensorflow/go
RUN python3 $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

# Notes:
# 1. Do not use ENTRYPOINT because mybinder need to run a custom command.
# 2. To use JupyterLab, replace "notebook" with "lab".
# 3. Set --allow-root in case you want to run jupyter as root.
CMD ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0"]