TEST?=$$(go list ./... |grep -v 'vendor')
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)
PKG_NAME=mysql
VERSION=$(shell git describe --abbrev=0 --tag)
TERRAFORM_D?=~/.terraform.d
GOOS?=$(shell go env GOOS)
GOARCH?=$(shell go env GOARCH)
PROVIDER_DIR?=$(TERRAFORM_D)/plugins/registry.terraform.io/winebarrel/mysql/$(subst v,,$(VERSION))/$(GOOS)_$(GOARCH)

default: build

build: fmtcheck
	go build

install: build
	mkdir -p $(PROVIDER_DIR)
	cp terraform-provider-mysql $(PROVIDER_DIR)/terraform-provider-mysql_$(VERSION)

test: fmtcheck
	go test -i $(TEST) || exit 1
	echo $(TEST) | \
		xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

fmt:
	gofmt -w $(GOFMT_FILES)

deps:
	go mod tidy
	go mod vendor

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

errcheck:
	@sh -c "'$(CURDIR)/scripts/errcheck.sh'"

vendor-status:
	@govendor status

test-compile:
	@if [ "$(TEST)" = "./..." ]; then \
		echo "ERROR: Set TEST to a specific package. For example,"; \
		echo "  make test-compile TEST=./$(PKG_NAME)"; \
		exit 1; \
	fi
	go test -c $(TEST) $(TESTARGS)


export DB?=mysql:8.0
export MYSQL_HOST?=127.0.0.1
export MYSQL_PORT?=3306
export MYSQL_ENDPOINT?=$(MYSQL_HOST):$(MYSQL_PORT)
export MYSQL_USERNAME?=root
export MYSQL_PASSWORD?=
export CONTAINER_NAME?=terraform-provider-mysql

testacc: fmtcheck
	go clean -testcache
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m

setup-db:
	./setup-db.sh

teardown-db:
	docker container kill $(CONTAINER_NAME)

.PHONY: build test testacc vet fmt fmtcheck errcheck vendor-status test-compile setup-db teardown-db
