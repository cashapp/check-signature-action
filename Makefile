.PHONY: all
all: test

.PHONY: test
test:
	bin/shellcheck src/*
