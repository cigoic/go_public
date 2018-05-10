# Build a docker image containes Jupyter Notebook for Go & Tensorflow
# Run the following commend along with this Dockerfile
# $ docker build .
# 
# To run docker image, run the following commend:
# $ docker run -it -p 8888:8888 <docker_image>

FROM tensorflow/tensorflow

ENV GOLANG_VERSION 1.9.6
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 d1eb07f99ac06906225ac2b296503f06cc257b472e7d7817b8f822fe3766ebfe
# Set up golang
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
# Install gcc for cgo
        g++ \
        gcc \
        libc6-dev \
        make \
        pkg-config \
# Notebook Dependencies
        libzmq3-dev \
        build-essential \
        python3-pip \
        git && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz && \
    echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" && \
    curl -fsSL https://git.io/vDyrl -o /usr/local/bin/go-wrapper && \
# Install Gophernotes
    go get golang.org/x/tools/cmd/goimports && \
    go get -tags zmq_3_x github.com/gopherds/gophernotes && \
    mkdir -p ~/.ipython/kernels/gophernotes && \
    cp -r $GOPATH/src/github.com/gopherds/gophernotes/kernel/* ~/.ipython/kernels/gophernotes && \
    mv /notebooks/* /go

RUN curl https://bootstrap.pypa.io/get-pip.py | python3
RUN pip install --upgrade pip && \
    python3 -m pip install ipykernel && \
    python3 -m ipykernel install --user

# Install Tensorflow Go
ENV TF_TYPE cpu 
ENV TARGET_DIRECTORY /usr/local
RUN curl -L "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-$(go env GOOS)-x86_64-1.8.0.tar.gz" | tar -C $TARGET_DIRECTORY -xz
RUN ldconfig
RUN go get github.com/tensorflow/tensorflow/tensorflow/go
RUN go test github.com/tensorflow/tensorflow/tensorflow/go

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/go"

CMD ["jupyter_notebook_config.py"]
CMD ["/run_jupyter.sh", "--allow-root"]
