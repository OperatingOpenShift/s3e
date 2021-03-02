IMG ?= quay.io/mdewald/s3e-highscore:latest

all:
	go build .

docker-build:
	docker build . -t $(IMG)

docker-push: docker-build
	docker push $(IMG)
