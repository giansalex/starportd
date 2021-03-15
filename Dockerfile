FROM alpine AS builder

ARG STARPORT_VERSION='develop'

# GOPATH AND GOBIN ON PATH
ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

# INSTALL DEPENDENCIES
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
	apk update && apk add --no-cache \
	go \
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

WORKDIR /starport

# INSTALL STARPORT
RUN PATH=$PATH:/go/bin && \
		bash scripts/install


FROM alpine

LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"

# GOPATH AND GOBIN ON PATH
ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

# INSTALL DEPENDENCIES
RUN apk update && apk add --no-cache \
	go \
	npm \ 
	make \
	git \
	bash \
	which \
	protoc && \
	mkdir /go && mkdir /usr/local/include

# COPY BIN
COPY --from=builder /go/bin/starport /go/bin
COPY /bin/protoc /usr/local/bin

# Copy third_party proto
COPY include/ /usr/local/include/

WORKDIR /app

# EXPOSE PORTS
EXPOSE 12345
EXPOSE 8080
EXPOSE 1317
EXPOSE 26656
EXPOSE 26657
