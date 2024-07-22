DOCKER := $(shell command -v docker)

ifndef DOCKER
$(error Can't find docker)
endif

OUTDIR := /tmp/bazel_issue_22680_repro


all: clean run

clean:
	rm -rf bazel-*
	rm -rf "$(OUTDIR)"

gen-docker-image:
	docker build -f repro.Dockerfile --tag repro .

run: gen-docker-image
	rm -rf "$(OUTDIR)" && mkdir "$(OUTDIR)" && \
	docker run \
		--volume "$(OUTDIR):/tmp/out" \
		--volume .:/src/workspace \
		--entrypoint=./repro.sh \
		repro

run-interactive: gen-docker-image
	rm -rf "$(OUTDIR)" && mkdir "$(OUTDIR)" && \
	docker run \
		--volume "$(OUTDIR):/tmp/out" \
		--volume .:/src/workspace \
		--tty \
		--interactive \
		--entrypoint=/bin/bash \
		repro

.PHONY: all clean gen-docker-image run run-interactive
