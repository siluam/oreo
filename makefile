.RECIPEPREFIX := |
.DEFAULT_GOAL := tangle

define nixShell
nix-shell -E '(import $(realfileDir)).devShells.$${builtins.currentSystem}.makeshell-$1' --show-trace --run
endef

mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
realfileDir := $(realpath $(mkfileDir))
tangleTask := $(shell [ -e $(mkfileDir)/tests -o -e $(mkfileDir)/tests.org ] && echo test || echo tangle)

preFiles := $(mkfileDir)/nix.org $(mkfileDir)/flake.org $(mkfileDir)/tests.org $(mkfileDir)/README.org
pnCommand := nix eval --show-trace --impure --expr '(import $(realfileDir)).pname'
projectName := $(subst ",,$(shell $(pnCommand) || (org-tangle -f $(preFiles) && $(pnCommand))))
ifndef projectName
$(error Sorry; unable to get the name of the project)
endif

type := $(subst ",,$(shell nix eval --show-trace --impure --expr '(import $(realfileDir)).type'))
files := $(preFiles) $(mkfileDir)/$(projectName)

add:
|git -C $(mkfileDir) add .

commit: add
|git -C $(mkfileDir) commit --allow-empty-message -am ""

push: commit
|git -C $(mkfileDir) push

update:
ifeq ($(projectName), settings)
|$(shell nix eval --impure --expr 'with (import $(realfileDir)); with pkgs.$${builtins.currentSystem}.lib; "nix flake lock $(realfileDir) --update-input $${concatStringsSep " --update-input " (filter (input: ! ((elem input [ "nixos-master" "nixos-unstable" ]) || (hasSuffix "-small" input))) (attrNames inputs))}"' | tr -d '"')
else
|nix flake update $(realfileDir)
endif

update-%: updateInput := nix flake lock $(realfileDir) --update-input
update-%:
|$(eval input := $(shell echo $@ | cut -d "-" -f2-))
ifeq ($(input), settings)
|-$(updateInput) $(input)
else ifeq ($(input), all)
|nix flake update $(realfileDir)
else
|$(updateInput) $(input)
endif

tangle: update-settings
|$(call nixShell,general) "org-tangle -f $(files)"

tangle-%: update-settings
|$(eval file := $(mkfileDir)/$(shell echo $@ | cut -d "-" -f2-).org)
|$(call nixShell,general) "org-tangle -f $(files)"

quick: tangle push

super: $(tangleTask) update push

super-%: $(tangleTask) update-% push ;

poetry2setup:
|$(call nixShell,$(type)) "cd $(mkfileDir) && poetry2setup > $(mkfileDir)/setup.py && cd -"

test: tangle update
|find $(mkfileDir)/tests -print | grep -v __pycache__ | xargs touch
|$(call nixShell,$(type)) "pytest --tb=native"
