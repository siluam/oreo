.RECIPEPREFIX := |
.DEFAULT_GOAL := test
export PATH := $(shell nix-shell -E '(import ./.).devShells.$${builtins.currentSystem}.makefile' --show-trace)
mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
tangle:
|org-tangle $(mkfileDir)/$$(cat $(mkfileDir)/pyproject.toml | tomlq .tool.poetry.name | tr -d '"') $(mkfileDir)/tests.org $(mkfileDir)/nix.org

test: tangle
|hy $(mkfileDir)/tests.hy

poetry2setup:
|poetry2setup > $(mkfileDir)/setup.py

commit:
|git -C $(mkfileDir) commit --allow-empty-message -am ""

push: commit
|git -C $(mkfileDir) push