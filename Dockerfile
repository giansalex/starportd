FROM alpine

LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"

ARG STARPORT_VERSION='develop'

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
	npm \ 
	make \
	git \
	bash \
	which \
	protoc

# Clone starport code
RUN mkdir /go && \
    mkdir /usr/local/include && \
    git clone https://github.com/tendermint/starport.git /starport && \
    cd /starport && git checkout ${STARPORT_VERSION}

WORKDIR /starport

# INSTALL STARPORT
RUN PATH=$PATH:/go/bin && \
		bash scripts/install && \
        /bin/protoc /usr/local/bin

# Copy third_party proto
COPY include/ /usr/local/include/

WORKDIR /app

CMD ["/go/bin/starport"]