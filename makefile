.RECIPEPREFIX := |
.DEFAULT_GOAL := tangle

mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
realfileDir := $(realpath $(mkfileDir))

export PATH := $(shell nix-shell -E '(import $(realfileDir)).devShells.$${builtins.currentSystem}.makefile' --show-trace):$(PATH)
export SHELL := $(shell which sh)

tangle:
|org-tangle $(mkfileDir)/nix.org

add:
|git -C $(mkfileDir) add .

commit: add
|git -C $(mkfileDir) commit --allow-empty-message -am ""

push: commit
|git -C $(mkfileDir) push

update: tangle
|nix flake update $(mkfileDir)

super: update push

export PYTHONPATH := $(shell nix-shell -E '(import $(realfileDir)).devShells.$${builtins.currentSystem}.makefile-python' --show-trace):$(PYTHONPATH)

tangle-python:
|org-tangle $(mkfileDir)/$$(cat $(mkfileDir)/pyproject.toml | tomlq .tool.poetry.name | tr -d '"') $(mkfileDir)/tests.org

test: tangle-python
|pytest $(mkfileDir)

poetry2setup:
|poetry2setup > $(mkfileDir)/setup.py

super-python: update test push

echo:
|@which pytest
|@echo $$PYTHONPATH
|@echo $(PYTHONPATH)