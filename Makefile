artifact_name := configurable-api-caller

.PHONY: all
all: build

.PHONY: clean
clean:
	rm -f ./$(artifact_name)-*.zip
	rm -rf ./dist

.PHONY: dependency-check
dependency-check:
	npm audit

.PHONY: build
build:  install
	npm run build

.PHONY: test
test:
	# npm run test # add this back in when you write service tests

.PHONY: sonar
sonar:
	npm run sonar-scanner

.PHONY: install
install:
	npm i

.PHONY: lint
lint:
	npm run lint

.PHONY: package
package: build
ifndef version
	$(error No version given. Aborting)
endif
	$(info Packaging version: $(version))
	$(eval tmpdir := $(shell mktemp -d build-XXXXXXXXXX))
	cp -r ./dist/* $(tmpdir)
	cp -r ./package.json $(tmpdir)
	cp -r ./package-lock.json $(tmpdir)
	cd $(tmpdir) && npm i --production
	rm $(tmpdir)/package.json $(tmpdir)/package-lock.json
	cd $(tmpdir) && zip -r ../$(artifact_name)-$(version).zip .
	rm -rf $(tmpdir)
