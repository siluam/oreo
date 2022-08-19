
.RECIPEPREFIX := |
.DEFAULT_GOAL := tangle

mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
realfileDir := $(realpath $(mkfileDir))

preFiles := $(mkfileDir)/nix.org $(mkfileDir)/flake.org $(mkfileDir)/tests.org $(mkfileDir)/README.org

removeTangleBackups := find $(mkfileDir) -name '.\#*.org*' -print | xargs rm &> /dev/null || :

define fallbackCommand
($(removeTangleBackups)) && ($1 || ((org-tangle -f $2 > /dev/null) && $1))
endef

define preFallback
$(call fallbackCommand,$1,$(preFiles))
endef

define nixShell
nix-shell -E '(import $(realfileDir)).devShells.$${builtins.currentSystem}.makeshell-$1' --show-trace --run
endef

define quickShell
$(call preFallback,nix-shell -E 'with (import $(realfileDir)).pkgs.$${builtins.currentSystem}; with lib; mkShell { buildInputs = flatten [ $1 ]; }' --show-trace)
endef

projectName := $(subst ",,$(shell $(call preFallback,nix eval --show-trace --impure --expr '(import $(realfileDir)).pname')))
ifndef projectName
$(error Sorry; unable to get the name of the project)
endif

type := $(subst ",,$(shell $(call preFallback,nix eval --show-trace --impure --expr '(import $(realfileDir)).type')))
ifndef type
$(error Sorry; unable to get the type of project)
endif

files := $(preFiles) $(mkfileDir)/$(projectName)

define fallback
$(call fallbackCommand,$1,$(files))
endef

tangleTask := $(shell [ -e $(mkfileDir)/tests -o -e $(mkfileDir)/tests.org ] && echo test || echo tangle)
addCommand := git -C $(mkfileDir) add .
updateCommand := $(call fallback,nix flake update --show-trace $(realfileDir))

define tangleCommand
($(removeTangleBackups)) && (($(call nixShell,general) "org-tangle -f $1") || org-tangle -f $1) && $(addCommand)
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
|$(shell $(call fallback,nix eval --impure --expr 'with (import $(realfileDir)); with pkgs.$${builtins.currentSystem}.lib; "nix flake lock $(realfileDir) --update-input $${concatStringsSep " --update-input " (filter (input: ! ((elem input [ "nixos-master" "nixos-unstable" ]) || (hasSuffix "-small" input))) (attrNames inputs))}"' | tr -d '"'))
else
|$(updateCommand)
endif

update-%: updateInput := nix flake lock $(realfileDir) --show-trace --update-input
update-%: add
|$(eval input := $(call wildcardValue,$@))
ifeq ($(input), settings)
|-[ $(projectName) != "settings" ] && $(call fallback,$(updateInput) $(input))
else ifeq ($(input), all)
|$(updateCommand)
else
|$(call fallback,$(updateInput) $(input))
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
|$(call fallback,nix develop --show-trace "$(realfileDir)#makeshell-$(type)")

shell: tu
|$(call quickShell,$(pkgs))

shell-%: tu
|$(call quickShell,(with $(call wildcardValue,$@); [ $(pkgs) ]))

develop-%: tu
|$(call fallback,nix develop --show-trace "$(realfileDir)#$(call wildcardValue,$@)")

repl: tu
|$(call fallback,$(call nixShell,$(type)) "$(type)")

build: tu
|$(call fallback,nix build --show-trace "$(realfileDir)")

build-%: tu
|$(call fallback,nix build --show-trace "$(realfileDir)#$(call wildcardValue,$@)")

run: tu
|export PPWD=$$(pwd) && cd $(mkfileDir) && $(call fallback,$(call nixShell,$(type)) "$(command)") && cd $PPWD

run-%: tu
|$(call fallback,nix run --show-trace "$(realfileDir)#$(call wildcardValue,$@)")

define touch-test-command
export PPWD=$$(pwd) && cd $(mkfileDir) && $(call fallback,$(call nixShell,$(type))) "touch $1 && $(type) $1" && cd $PPWD
endef

touch-test: tu
|$(call touch-test-command,$(file))

touch-test-%: tu
|$(eval file := $(mkfileDir)/$(call wildcardValue,$@))
|$(call touch-test-command,$(file))

quick: tangle push

super: ttu push

super-%: ttu-% push ;
poetry2setup: tu
|$(call nixShell,$(type)) "cd $(mkfileDir) && poetry2setup > $(mkfileDir)/setup.py && cd -"

touch-tests:
|find $(mkfileDir)/tests -print | grep -v __pycache__ | xargs touch

tut: tu touch-tests

define pytest
$(call nixShell,$(type)) "pytest --randomly-seed=1296887350 $1 $(mkfileDir)"
endef

test: tut
|$(call pytest)

test-native: tut
|$(call pytest,--tb=native)

test-%: tut
|$(call pytest,-m $(call wildcardValue,$@))
