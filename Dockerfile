FROM openapitools/openapi-generator-cli:latest

RUN set -x && \
    apk add --no-cache git curl jq

COPY generate-and-push.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/generate-and-push.sh
ENTRYPOINT ["generate-and-push.sh"]
