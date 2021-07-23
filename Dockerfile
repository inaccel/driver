FROM alpine
RUN apk add --no-cache \
	coreutils \
	wget
COPY driver /bin/driver
ENTRYPOINT ["driver"]
