{
    description = "The Stuffing for Other Functions!";
    inputs = rec {
        settings = {
            url = github:sylvorg/settings;
            inputs.pypkg-oreo.follows = "";
        };
        # nixpkgs.follows = "settings/nixpkgs";
        nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
        flake-utils.url = github:numtide/flake-utils;
        flake-compat = {
            url = "github:edolstra/flake-compat";
            flake = false;
        };
    };
    outputs = inputs@{ self, flake-utils, settings, ... }: with builtins; with settings.lib; with flake-utils.lib; let
        pname = "oreo";
        callPackage = { buildPythonPackage
            , pythonOlder
            , poetry-core
            , addict
            , autoslot
            , click
            , coconut
            , cytoolz
            , hy
            , hyrule
            , more-itertools
            , nixpkgs
            , rich
            , toolz
            , pname
        }: let owner = "syvlorg"; in buildPythonPackage rec {
            inherit pname;
            inherit ((fromTOML (readFile "${src}/pyproject.toml")).tool.poetry) version;
            format = "pyproject";
            disabled = pythonOlder "3.9";
            src = ./.;
            buildInputs = [ poetry-core ];
            nativeBuildInputs = buildInputs;
            propagatedBuildInputs = [
                addict
                autoslot
                click
                coconut
                cytoolz
                hy
                hyrule
                more-itertools
                nixpkgs
                rich
                toolz
            ];
            pythonImportsCheck = [ pname ];
            postPatch = ''
                substituteInPlace pyproject.toml --replace "rich = { git = \"https://github.com/${owner}/rich.git\", branch = \"master\" }" ""
                substituteInPlace pyproject.toml --replace "hy = \"^0.24\"" ""
                substituteInPlace setup.py --replace "'rich @ git+https://github.com/${owner}/rich.git@master'," ""
                substituteInPlace setup.py --replace "'hy>=0.24,<0.25'," ""
            '';
            meta = {
                description = "The Stuffing for Other Functions!";
                homepage = "https://github.com/${owner}/${pname}";
            };
        };

        overlayset = let
            overlay = j.update.python.callPython.three { inherit pname; } pname callPackage;
        in rec {
            overlays = settings.overlays // { default = overlay; "${pname}" = overlay; };
            inherit overlay;
            defaultOverlay = overlay;
        };
    in j.foldToSet [
        (eachSystem allSystems (system: let
            made = settings.make system (attrValues overlayset.overlays);
            python = made.mkPython made.pkgs.Python3 [] pname;
            xonsh = settings.mkXonsh [] pname;
            hy = made.mkHy [] pname;
        in rec {
            inherit (made) legacyPackages pkgs nixpkgs;
            packages = flattenTree {
                inherit python xonsh hy;
                "python-${pname}" = python;
                "xonsh-${pname}" = xonsh;
                "hy-${pname}" = hy;
                "${pname}" = python;
                default = python;
            };
            package = packages.default;
            defaultPackage = package;
            apps = mapAttrs (n: made.app) packages;
            app = apps.default;
            defaultApp = app;
            devShells = j.foldToSet [
                (mapAttrs (n: v: pkgs.mkShell { buildInputs = toList v; }) packages)
                (mapAttrs (n: v: pkgs.mkShell { buildInputs = toList v; }) settings.buildInputs)
                {
                    default = pkgs.mkShell { buildInputs = attrValues packages; };
                    inherit (settings.devShells.${system}) makefile;
                }
            ];
            devShell = devShells.default;
            defaultdevShell = devShell;
        }))
        overlayset
        { inherit pname callPackage; }
    ];
}
