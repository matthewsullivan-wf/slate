#build stage
FROM ruby:2.3-alpine as builder

# bring in the code, cannot be at root, don't want name collision with middleman build dir (it's just confusing)
WORKDIR /local-build

# bring in the code
COPY . .

# install dependencies
RUN apk add --update nodejs g++ make
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

# set dependency artifact
ARG BUILD_ARTIFACTS_AUDIT=/static/npm.lock

# open up port 8000
EXPOSE 8000

CMD ["http-server", "-p", "8000"]
