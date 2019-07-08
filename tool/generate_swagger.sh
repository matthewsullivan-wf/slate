#!/usr/bin/env bash

for i in java csharp go
do
    # this path tom-foolery is because if you don't cd into the root of the zip you are trying to create
    # your path is fully representing in the generated archive...
    # we don't want that, we just want it to be recursive but starting at the root path (which is why -j doesn't work)
    java -jar swagger-codegen-cli-2.2.1.jar generate -i https://h.app.wdesk.com/s/cerebral/v2/api-docs -l $i -o source/generated/$i && \
    cd source/generated/$i && \
    zip -r client.zip ./* && \
    cd ../../.. && \
    mv source/generated/$i/client.zip . && \
    rm -rf source/generated/$i && \
    mkdir -p source/generated/$i && \
    mv client.zip source/generated/$i/client.zip;
done
