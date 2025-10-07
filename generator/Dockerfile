FROM alpine:3.19
RUN apk add --no-cache curl bash
COPY generator.sh /generator.sh
RUN chmod +x /generator.sh
CMD ["/generator.sh"]
