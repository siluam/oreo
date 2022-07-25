{
    description = "The Stuffing for Other Functions!";
    inputs = rec {
        settings.url = github:sylvorg/settings;
        py3pkg-rich.url = github:syvlorg/rich;
        py3pkg-pytest-hy.url = github:syvlorg/pytest-hy;
        flake-utils.url = github:numtide/flake-utils;
        flake-compat = {
            url = "github:edolstra/flake-compat";
            flake = false;
        };
    };
    outputs = inputs@{ self, flake-utils, settings, ... }: with builtins; with settings.lib; with flake-utils.lib; settings.mkOutputs {
        inherit inputs;
        callPackage = { buildPythonPackage
            , callPackage
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
            , toolz
            , pname
            , pytestCheckHook
            , pytest-randomly
            , pytest-hy
            , rich
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
                substituteInPlace pyproject.toml --replace "hy = \"^0.24.0\"" ""
                substituteInPlace pyproject.toml --replace "hyrule = \"^0.2\"" ""
                substituteInPlace setup.py --replace "'rich @ git+https://github.com/${owner}/rich.git@master'," ""
                substituteInPlace setup.py --replace "'hy>=0.24.0,<0.25.0'," ""
                substituteInPlace setup.py --replace "'hyrule>=0.2,<0.3'," ""
            '';
            meta = {
                description = "The Stuffing for Other Functions!";
                homepage = "https://github.com/${owner}/${pname}";
            };
        };
        pname = "oreo";
        type = "hy";
    };
}
