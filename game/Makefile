IMG ?= quay.io/mdewald/s3e:latest

compile:
	podman run --rm -v `pwd`:/game ioribranford/godot-docker:3.2 sh -c "/bin/godot --export HTML5 /game/project.godot /game/export/index.html; chmod -R a+rw /game/export"

docker-build:
	podman build --file build.Dockerfile -t $(IMG)

docker-push: docker-build
	podman push $(IMG)

run-local:
	podman run -p 8080:8080 $(IMG)