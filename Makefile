IS_PYTHON_INSTALLED = $(shell which python >> /dev/null 2>&1; echo $$?)
ALL_DOCS := $(shell find . -type f -name '*.md' -not -path './.github/*' -not -path './node_modules/*' | sort)

parse: clean _check_python
	@python ./tools/specification_parser/specification_parser.py

clean:
	@find ./specification -name '*.json' -delete

lint:
	@python ./tools/specification_parser/lint_json_output.py specification/

_check_python:
	@if [ $(IS_PYTHON_INSTALLED) -eq 1 ]; \
		then echo "" \
		&& echo "ERROR: python must be available on PATH." \
		&& echo "" \
		&& exit 1; \
		fi;
.PHONY: markdown-toc
markdown-toc:
	@if ! npm ls markdown-toc; then npm install; fi
	@for f in $(ALL_DOCS); do \
		if grep -q '<!-- tocstop -->' $$f; then \
			echo markdown-toc: processing $$f; \
			npx --no -- markdown-toc --no-first-h1 --no-stripHeadingTags -i $$f || exit 1; \
		else \
			echo markdown-toc: no TOC markers, skipping $$f; \
		fi; \
	done
