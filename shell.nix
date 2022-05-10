with builtins; let
    pkgs = import (fetchGit { url = "https://github.com/shadowrylander/nixpkgs"; ref = "j"; }) {};
in with pkgs; mkShell {
    buildInputs = with python310Packages; [ xonsh python310 (oreo.overridePythonAttrs (prev: {
        src = ./.;
    })) ];
    shellHook = "exec xonsh";
}
