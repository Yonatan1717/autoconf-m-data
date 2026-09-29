PYTHON ?= python3
INPUT ?= examples/demo_no_mpls.xlsx

.PHONY: generate summary services-bootstrap services-up services-down lint

generate:
	$(PYTHON) automation/generator/generate.py $(INPUT)

summary:
	$(PYTHON) tools/summarize_site_config.py

services-bootstrap:
	cd services && ./bootstrap-configs.sh

services-up:
	cd services && docker compose up -d --build

services-down:
	cd services && docker compose down

lint:
	$(PYTHON) -m compileall -q automation/generator tools
