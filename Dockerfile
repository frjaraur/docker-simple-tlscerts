FROM alpine
RUN apk --update add openssl bash
WORKDIR /certs
VOLUME /certs
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
