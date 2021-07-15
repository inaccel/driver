FROM alpine
COPY driver /bin/driver
ENTRYPOINT ["driver"]
