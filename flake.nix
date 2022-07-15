{
    description = "The Stuffing for Other Functions!";
    inputs = rec {
        settings = {
            url = github:sylvorg/settings;
            inputs.pypkg-oreo.follows = "";
        };
        nixpkgs.follows = "settings/nixpkgs";
        flake-utils.url = github:numtide/flake-utils;
        flake-compat = {
            url = "github:edolstra/flake-compat";
            flake = false;
        };
    };
    outputs = inputs@{ self, flake-utils, settings, ... }: with builtins; with settings.lib; with flake-utils.lib; settings.mkOutputs {
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
            , pytestCheckHook
            , pytest-hylang
            , pytest-randomly
        }: let owner = "syvlorg"; in buildPythonPackage rec {
            inherit pname;
            version = j.pyVersion format src;
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
            checkInputs = [ pytestCheckHook pytest-hy pytest-randomly ];
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
        pname = "oreo";
        python = "hy";
    };
}
