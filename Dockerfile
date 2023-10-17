FROM node:18-alpine

RUN apk --no-cache add bash git curl jq && npm install -g calver

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
