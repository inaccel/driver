FROM alpine
RUN apk add --no-cache \
	coreutils
COPY driver /bin/driver
ENTRYPOINT ["driver"]
