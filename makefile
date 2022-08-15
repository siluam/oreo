.RECIPEPREFIX := |
.DEFAULT_GOAL := tangle

define nixShell
nix-shell -E '(import $(realfileDir)).devShells.$${builtins.currentSystem}.makeshell-$1' --show-trace --run
endef

define quickShell
nix-shell -E 'with (import $(realfileDir)).pkgs.$${builtins.currentSystem}; with lib; mkShell { buildInputs = flatten [ $1 ]; }' --show-trace
endef

mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
realfileDir := $(realpath $(mkfileDir))

preFiles := $(mkfileDir)/nix.org $(mkfileDir)/flake.org $(mkfileDir)/tests.org $(mkfileDir)/README.org

pnCommand := nix eval --show-trace --impure --expr '(import $(realfileDir)).pname'
projectName := $(subst ",,$(shell (find $(mkfileDir) -name '.#*.org*' -print | xargs rm &> /dev/null || :) && ($(pnCommand) || ((org-tangle -f $(preFiles) &> /dev/null) && $(pnCommand)))))
ifndef projectName
$(error Sorry; unable to get the name of the project)
endif

typeCommand := nix eval --show-trace --impure --expr '(import $(realfileDir)).type'
type := $(subst ",,$(shell (find $(mkfileDir) -name '.#*.org*' -print | xargs rm &> /dev/null || :) && ($(typeCommand) || ((org-tangle -f $(preFiles) &> /dev/null) && $(typeCommand)))))
ifndef type
$(error Sorry; unable to get the type of project)
endif

files := $(preFiles) $(mkfileDir)/$(projectName)
tangleTask := $(shell [ -e $(mkfileDir)/tests -o -e $(mkfileDir)/tests.org ] && echo test || echo tangle)
addCommand := git -C $(mkfileDir) add .

define tangleCommand
(($(call nixShell,general) "org-tangle -f $1") || org-tangle -f $1) && $(addCommand)
endef

define wildcardValue
$(shell echo $1 | cut -d "-" -f2-)
endef

add:
|$(addCommand)

commit: add
|git -C $(mkfileDir) commit --allow-empty-message -am ""

push: commit
|git -C $(mkfileDir) push

update: add
ifeq ($(projectName), settings)
|$(shell nix eval --impure --expr 'with (import $(realfileDir)); with pkgs.$${builtins.currentSystem}.lib; "nix flake lock $(realfileDir) --update-input $${concatStringsSep " --update-input " (filter (input: ! ((elem input [ "nixos-master" "nixos-unstable" ]) || (hasSuffix "-small" input))) (attrNames inputs))}"' | tr -d '"')
else
|nix flake update $(realfileDir)
endif

update-%: updateInput := nix flake lock $(realfileDir) --update-input
update-%: add
|$(eval input := $(call wildcardValue,$@))
ifeq ($(input), settings)
|-[ $(projectName) != "settings" ] && $(updateInput) $(input)
else ifeq ($(input), all)
|nix flake update $(realfileDir)
else
|$(updateInput) $(input)
endif

pre-tangle: update-settings
|-find $(mkfileDir) -name '.#*.org*' -print | xargs rm &> /dev/null

tangle: pre-tangle
|$(call tangleCommand,$(files))

tangle-%: pre-tangle
|$(eval file := $(mkfileDir)/$(call wildcardValue,$@).org)
|$(call tangleCommand,$(file))

tu: tangle update

tu-%: tangle update-%

ttu: $(tangleTask) update

ttu-%: $(tangleTask) update-%

develop: tu
|nix develop "$(realfileDir)#makeshell-$(type)"

shell: tu
|$(call quickShell,$(pkgs))

shell-%: tu
|$(call quickShell,(with $(call wildcardValue,$@); [ $(pkgs) ]))

develop-%: tu
|nix develop "$(realfileDir)#$(call wildcardValue,$@)"

repl: tu
|$(call nixShell,$(type)) "$(type)"

build-%: tu
|nix build "$(realfileDir)#$(call wildcardValue,$@)"

run-%: tu
|nix run "$(realfileDir)#$(call wildcardValue,$@)"

quick: tangle push

super: ttu push

super-%: ttu-% push ;

poetry2setup: tu
|$(call nixShell,$(type)) "cd $(mkfileDir) && poetry2setup > $(mkfileDir)/setup.py && cd -"

touch-tests:
|find $(mkfileDir)/tests -print | grep -v __pycache__ | xargs touch

tut: tu touch-tests

define pytest
$(call nixShell,$(type)) "pytest $1 $(mkfileDir)"
endef

test: tut
|$(call pytest)

test-native: tut
|$(call pytest,--tb=native)

test-%: tut
|$(call pytest,-m $(call wildcardValue,$@))
