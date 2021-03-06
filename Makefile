NODE_PATH ?= ./node_modules
DIST_DIR = ./dist
BROWSERIFY = $(NODE_PATH)/.bin/browserify
JS_COMPILER = $(NODE_PATH)/uglify-js/bin/uglifyjs
JS_TESTER = $(NODE_PATH)/vows/bin/vows

DOC_DIR = doc
BUILD_DIR = build
DOC_LIST = `ls $(DOC_DIR)/md/`
JS_ENGINE ?= $(shell which node nodejs 2>/dev/null | grep -Po -m 1 "(.+?)$$")

all: clean core doc

clean:
	@echo 'Cleaning up build files'
	@rm -rf dist

core: jstat.js jstat.min.js

jstat.js:
	@echo 'Building jStat'
	@mkdir -p $(DIST_DIR)
	@$(BROWSERIFY) index.js > $(DIST_DIR)/$@

jstat.min.js: jstat.js
	@echo 'Minifying jStat'
	@$(JS_COMPILER) < $(DIST_DIR)/$< > $(DIST_DIR)/$@

doc:
	@echo 'Generating documentation'
	@mkdir -p $(DIST_DIR)/docs/assets
	@cp $(DOC_DIR)/assets/*.css $(DIST_DIR)/docs/assets/
	@cp $(DOC_DIR)/assets/*.js $(DIST_DIR)/docs/assets/
	@for i in $(DOC_LIST); do \
		$(JS_ENGINE) $(BUILD_DIR)/doctool.js $(DOC_DIR)/assets/template.html $(DOC_DIR)/md/$${i} $(DIST_DIR)/docs/$${i%.*}.html; \
	done

jstat: jstat.js

test: clean core
	@echo 'Running jStat unit tests'
	@$(JS_TESTER)

.PHONY: clean core doc test
