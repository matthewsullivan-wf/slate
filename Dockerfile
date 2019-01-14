FROM debian:stretch-slim as helm_artifact

RUN apt-get update && apt-get install -y wget && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && \
    echo "56ae2d5d08c68d6e7400d462d6ed10c929effac929fedce18d2636a9b4e166ba helm-v2.9.1-linux-amd64.tar.gz" | sha256sum -c && \
    tar xf helm-v2.9.1-linux-amd64.tar.gz && \
    cp linux-amd64/helm /usr/local/bin && \
    rm -rf helm-v2.9.1-linux-amd64.tar.gz linux-amd64

ADD helm /build/
WORKDIR /build/

RUN helm init --client-only
RUN helm package *
ARG BUILD_ARTIFACTS_HELM_CHARTS=/build/*.tgz

#build stage
FROM ruby:2.5.1-alpine as builder

# bring in the code, cannot be at root, don't want name collision with middleman build dir (it's just confusing)
WORKDIR /local-build

# bring in the code
COPY . .

# install dependencies
RUN apk add --update nodejs nodejs-npm g++ make
RUN bundle install
RUN npm config set unsafe-perm true
RUN npm install -g widdershins@3.6.0

# generate documentation
RUN widdershins https://h.app.wdesk.com/s/cerebral/v2/api-docs -o source/includes/_swagger.md

# remove header from swagger, this is ugly but widdershins adds meta we don't need, the size of the meta (in lines) is deterministic so we know how many to remove
RUN tail -n +19 < source/includes/_swagger.md > source/includes/_swagger.md

# build the app which puts the compiled html, etc into the build directory
RUN bundle exec middleman build --clean

# run stage
FROM alpine:3.7

#package updates
RUN apk update && apk upgrade

# new workdir
WORKDIR /static/

# get node ready
RUN apk add --update nodejs

# so the next command succeeds
RUN npm config set unsafe-perm true
RUN npm install http-server -g

# create empty dependencies file... we have none but this is for rm
RUN touch npm.lock

# bring the static html in
COPY --from=builder /local-build/build/ s/cerebral-docs/

# bring in gem lock
COPY --from=builder /local-build/Gemfile.lock /static/Gemfile.lock

# set dependency artifact
ARG BUILD_ARTIFACTS_AUDIT=/static/npm.lock:/static/Gemfile.lock

# run as non-root user
USER nobody

# open up port 8000
EXPOSE 8000

CMD ["http-server", "-p", "8000"]
