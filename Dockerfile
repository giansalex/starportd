FROM alpine

LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"

ARG STARPORT_VERSION='develop'
ARG PROTOC_VERSION='3.15.6'

# EXPOSE PORTS
EXPOSE 12345
EXPOSE 8080
EXPOSE 1317
EXPOSE 26656
EXPOSE 26657

# GOPATH AND GOBIN ON PATH
ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

# INSTALL DEPENDENCIES
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
	apk update && apk add --no-cache \
	go@community \
	wget \
	npm \ 
	make \
	git \
	bash \
	which \
	protoc

# Clone starport code
RUN mkdir /go && \
    git clone https://github.com/tendermint/starport.git /starport && \
    cd /starport && git checkout ${STARPORT_VERSION}

# INSTALL STARPORT
RUN PATH=$PATH:/go/bin && \
		cd /starport && make install && \
		cd / && rm -rf /starport


# Install proto
RUN /usr/bin/protoc /usr/local/bin && \
	wget https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    -O /protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip /protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local/ && \
    rm -f /protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
	git clone --depth=1 https://github.com/googleapis/googleapis.git && \
	cp -r googleapis/google/api /usr/local/include/ && \
	rm -rf ./googleapis

WORKDIR /app

CMD ["/go/bin/starport"]