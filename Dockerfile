FROM alpine:3.15

ARG GH_VERSION="2.29.0"
RUN apk update && \
    apk add --no-cache bash git jq yq openssh gpg
RUN wget -q https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -O - | tar -zx
ENV PATH=$PATH:/gh_${GH_VERSION}_linux_amd64/bin

COPY src/* /

ENTRYPOINT ["/check.sh"]