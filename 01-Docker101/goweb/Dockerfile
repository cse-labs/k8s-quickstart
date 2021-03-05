# build the app in a temporary container
FROM golang:latest as build

RUN mkdir -p /root/app
COPY app/ /root/app/
WORKDIR /root/app
ENTRYPOINT ["/bin/bash"]

# Build the app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ./app main.go

#############################
# build the release container
FROM alpine:latest  
RUN mkdir -p /root/app && apk --no-cache add curl
WORKDIR /root/app
COPY --from=build /root/app/ /root/app/
ENTRYPOINT ["./app"] 

