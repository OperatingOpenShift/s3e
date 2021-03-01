IMG ?= quay.io/mdewald/s3e:latest

compile:
	docker run --rm -v `pwd`:/game ioribranford/godot-docker:3.2 sh -c "/bin/godot --export HTML5 /game/project.godot /game/export/index.html; chmod -R a+rw /game/export"

docker-build: compile
	docker build . -t $(IMG)

docker-push: docker-build
	docker push $(IMG)
