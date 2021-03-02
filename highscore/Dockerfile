FROM golang:1.14 AS build
COPY . /src
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux go build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
RUN mkdir /app/db
RUN chmod 777 /app/db
COPY --from=build /src/highscore .
RUN ls /app
EXPOSE 8080
CMD ["/app/highscore"]
