FROM alpine:3.13.4 as base

LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"

# GOPATH AND GOBIN ON PATH
ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

# INSTALL DEPENDENCIES
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
	apk update && apk add --no-cache \
	go@community \
	npm \ 
	make \
	git \
	bash \
	which \
	protoc && \
	mkdir /go && mkdir /usr/local/include

FROM base as builder

ARG STARPORT_VERSION='master'
ARG PROTOC_VERSION='3.19.1'

RUN apk add --no-cache wget

# Clone starport code
RUN git clone https://github.com/tendermint/starport.git /starport && \
    cd /starport && git checkout ${STARPORT_VERSION}

# INSTALL STARPORT
RUN PATH=$PATH:/go/bin && cd /starport && make install

# Install proto
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip -O /protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip /protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local/ && \
    rm -f /protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    git clone --depth=1 https://github.com/googleapis/googleapis.git && \
    cp -r googleapis/google/api /usr/local/include/google/

FROM base

# EXPOSE PORTS
EXPOSE 12345
EXPOSE 8080
EXPOSE 1317
EXPOSE 26656
EXPOSE 26657

WORKDIR /app

COPY --from=builder /usr/local/include/ /usr/local/include/
COPY --from=builder /usr/bin/protoc /usr/local/bin/
COPY --from=builder /go/bin/starport /usr/local/bin/

CMD ["/usr/local/bin/starport"]
