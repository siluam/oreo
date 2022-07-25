with builtins; with import <nixos> {}; with lib; let
    isSublist = a: b: all (flip elem b) a;
in mkShell {
    shellHook = ''
        ${trace (isSublist [ 1 10 ] (range 1 10)) ":"}
        exit
    '';
}
