with builtins; ((builtins.getFlake or import) (toString ./.)).devShell.${currentSystem}
