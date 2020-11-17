# build the app in a temporary container
FROM golang:latest

RUN mkdir -p /root/app
COPY app/ /root/app/
WORKDIR /root/app
CMD bash

# Build the app
RUN go fmt
RUN go vet
#RUN go get -u golang.org/x/lint/golint && golint
#RUN go test -cover
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ./app main.go
#RUN rm main.go


# build the release container
FROM alpine:latest  
RUN mkdir -p /root/app && apk --no-cache add curl
WORKDIR /root/app
COPY --from=0 /root/app/ /root/app/
CMD ["./app"] 

