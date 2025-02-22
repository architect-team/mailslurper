FROM golang:alpine as builder

LABEL maintainer="erguotou525@gmail.compute"

RUN apk --no-cache add git libc-dev gcc
RUN go install github.com/mjibson/esc@latest

COPY . /go/src/github.com/mailslurper/mailslurper
WORKDIR /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper

RUN go get
RUN go generate
RUN go build

FROM alpine:3.18

RUN apk add --no-cache ca-certificates \
  && echo -e '{\n\
  "wwwAddress": "0.0.0.0",\n\
  "wwwPort": 8080,\n\
  "wwwPublicURL": "",\n\
  "serviceAddress": "0.0.0.0",\n\
  "servicePort": 8085,\n\
  "servicePublicURL": "",\n\
  "smtpAddress": "0.0.0.0",\n\
  "smtpPort": 2500,\n\
  "dbEngine": "SQLite",\n\
  "dbHost": "",\n\
  "dbPort": 0,\n\
  "dbDatabase": "./mailslurper.db",\n\
  "dbUserName": "",\n\
  "dbPassword": "",\n\
  "maxWorkers": 1000,\n\
  "autoStartBrowser": false,\n\
  "keyFile": "./assets/ca-key.pem",\n\
  "certFile": "./assets/ca-cert.pem",\n\
  "adminKeyFile": "",\n\
  "adminCertFile": ""\n\
  }'\
  >> config.json

COPY --from=builder /go/src/github.com/mailslurper/mailslurper/assets/* ./assets/
COPY --from=builder /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper/mailslurper mailslurper

EXPOSE 8080 8085 2500

CMD ["./mailslurper"]
