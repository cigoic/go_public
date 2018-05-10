# Build a docker image containes Jupyter Notebook for Go & Tensorflow
# Run the following commend along with this Dockerfile
# $ docker build -t myname/gophernotes:1.10.2 .
# 
# To run docker image, run the following commend:
# $ docker run -it -p 8888:8888 <docker_image>
#
# REF:
# https://github.com/gopherdata/gophernotes/blob/master/Dockerfile.DS

FROM tensorflow/tensorflow
MAINTAINER JimChiu

ENV GOLANG_VERSION 1.10.2
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff
# Set up golang
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
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
        git \
	musl-dev \
        mercurial \
# Install Python and Jupyter Notebook
	&& curl https://bootstrap.pypa.io/get-pip.py | python3 \
	&& pip install --upgrade pip \
	&& python3 -m pip install ipykernel \
	&& python3 -m ipykernel install --user \
# Intall Go
	&& curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
 	&& tar -C /usr/local -xzf golang.tar.gz \
    	&& rm golang.tar.gz \
    	&& mkdir -p "$GOPATH/src" "$GOPATH/bin" \
	&& chmod -R 777 "$GOPATH" \
 	&& curl -fsSL https://git.io/vDyrl -o /usr/local/bin/go-wrapper \
# Install Gophernotes
	&& go get golang.org/x/tools/cmd/goimports \
	&& go get -tags zmq_3_x github.com/gopherds/gophernotes \
	&& mkdir -p ~/.ipython/kernels/gophernotes \
    	&& cp -r $GOPATH/src/github.com/gopherds/gophernotes/kernel/* ~/.ipython/kernels/gophernotes \
	&& mv /notebooks/* /go

# Install Tensorflow Go
ENV TF_TYPE cpu 
ENV TARGET_DIRECTORY /usr/local
RUN curl -L "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-$(go env GOOS)-x86_64-1.8.0.tar.gz" | tar -C $TARGET_DIRECTORY -xz
RUN ldconfig
RUN go get github.com/tensorflow/tensorflow/tensorflow/go \
	&& go test github.com/tensorflow/tensorflow/tensorflow/go
# Install the relevant Go packages for Data Science
RUN go get -insecure -t -u gonum.org/v1/plot/... \
	&& go get -insecure gonum.org/v1/gonum/... \
	&& go get -t -u github.com/kniren/gota/... \
	&& go get github.com/sajari/regression \
	&& go get github.com/sjwhitworth/golearn/... \
	&& go get -insecure go-hep.org/x/hep/csvutil/... \
	&& go get -insecure go-hep.org/x/hep/fit \
	&& go get -insecure go-hep.org/x/hep/hbook \
	&& go get github.com/montanaflynn/stats \
	&& go get github.com/boltdb/bolt \
	&& go get github.com/patrickmn/go-cache \
	&& go get github.com/chewxy/math32 \
	&& go get github.com/chewxy/hm \
	# && go get github.com/chewxy/vecf64 \
	# && go get github.com/chewxy/vecf32 \
	&& go get gorgonia.org/vecf64 \
        && go get gorgonia.org/vecf32 \
	# && go get github.com/gonum/... \
	&& go get github.com/awalterschulze/gographviz \
	&& go get github.com/leesper/go_rng \
	&& go get github.com/pkg/errors \
	&& go get github.com/stretchr/testify/assert \
	&& go get github.com/lib/pq
# clean
RUN find /usr/lib/python* -name __pycache__ | xargs rm -r \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apk/*


# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/go"

#CMD ["jupyter_notebook_config.py"]
CMD ["/run_jupyter.sh", "--no-browser", "--allow-root", "--ip=0.0.0.0"]
