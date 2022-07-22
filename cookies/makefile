.RECIPEPREFIX := |
.DEFAULT_GOAL := split

# Adapted From: https://www.systutorials.com/how-to-get-the-full-path-and-directory-of-a-makefile-itself/
mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))

split:
|split -l 60 --numeric-suffixes=1 00 ""
