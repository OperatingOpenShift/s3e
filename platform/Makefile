IMG ?= quay.io/mdewald/s3e-platform:latest

docker-build:
	docker build . -t $(IMG)

docker-push: docker-build
	docker push $(IMG)
