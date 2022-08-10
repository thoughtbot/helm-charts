TEST_FILES  := $(wildcard tests/*.bats)

export TEST_TMPDIR := $(CURDIR)/tmp
export TEST_DIR    := $(CURDIR)/tests

.PHONY: default
default: tests template-test kubeval

.PHONY: tests
tests: vendor/bin/bats
	vendor/bin/bats $(TEST_FILES)

.PHONY: $(TEST_FILES)
$(TEST_FILES): vendor/bin/bats
	vendor/bin/bats "$@"

vendor/bin/bats: tmp/bats
	mkdir -p vendor
	tmp/bats/install.sh ./vendor

tmp/bats:
	mkdir -p tmp
	git clone https://github.com/sstephenson/bats.git tmp/bats

.PHONY: template-test
template-test:
	rm -rf template-test/helm-rails
	helm template example-app "." \
		--debug \
		--values template-test/values.yaml \
		--output-dir template-test

.PHONY: kubeval
kubeval:	
	cat template-test/helm-rails/templates/*.yaml \
		| kubeval --strict --ignore-missing-schemas
