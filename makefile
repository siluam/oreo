.RECIPEPREFIX := |
.DEFAULT_GOAL := tangle

define nixShell
nix-shell -E '(import ./.).devShells.$${builtins.currentSystem}.makeshell-$1' --show-trace --run
endef

mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
realfileDir := $(realpath $(mkfileDir))
type := $(shell nix eval --impure --expr '(import ./.).type' | tr -d '"')
projectName := $(shell nix eval --impure --expr '(import ./.).pname' | tr -d '"')

add:
|git -C $(mkfileDir) add .

commit: add
|git -C $(mkfileDir) commit --allow-empty-message -am ""

push: commit
|git -C $(mkfileDir) push

update:
|nix flake update

tangle:
|$(call nixShell,general) "org-tangle $(mkfileDir)/nix.org"

tangle-python: tangle
|$(call nixShell,general) "org-tangle $(mkfileDir)/$(projectName) $(mkfileDir)/tests.org"

poetry2setup:
|$(call nixShell,$(type)) "poetry2setup > $(mkfileDir)/setup.py"

test: tangle-python update 
|$(call nixShell,$(type)) pytest

quick: tangle-python push

super: test push
