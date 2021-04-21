FROM golang:1.14 AS build
COPY . /src
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux go build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
RUN mkdir -p /app/db/GameScores
RUN chgrp -R 0 /app/db && chmod -R g=u /app/db
COPY --from=build /src/highscore .
RUN ls /app
EXPOSE 8080
CMD ["/app/highscore"]
