DOCKER := $(shell command -v docker)

ifndef DOCKER
$(error Can't find docker)
endif


BASEDIR := /tmp/lima
OUTDIR := $(BASEDIR)/bazel_issue_22680_repro/out
REPO := $(PWD)


all: run

clean:
	rm -rf bazel-*
	rm -rf "$(OUTDIR)"

gen-docker-image:
	docker build -f repro.Dockerfile --tag repro .

run: clean gen-docker-image
	mkdir -p "$(OUTDIR)" && \
	docker run \
		--volume "$(OUTDIR)":/tmp/out:rw \
		--volume "${REPO}":/src/workspace:rw \
		--entrypoint=./repro.sh \
		repro

run-interactive: clean gen-docker-image
	mkdir -p "$(OUTDIR)" && \
	docker run \
		--volume "$(OUTDIR)":/tmp/out:rw \
		--volume "${REPO}":/src/workspace:rw \
		--tty \
		--interactive \
		--entrypoint=/bin/bash \
		repro

.PHONY: all clean gen-docker-image run run-interactive
