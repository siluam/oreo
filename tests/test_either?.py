from parametrized import parametrized
from pytest import mark, param
from addict import Dict
from collections import OrderedDict
from oreo import is_either


@mark.either
class TestEither:
    @parametrized
    def test_either(
        self,
        types=(
            (OrderedDict, dict),
            (OrderedDict, Dict),
            (Dict, dict),
            ("Dict", str),
            ("OrderedDict", "Dict", list),
            ("OrderedDict", "Dict"),
        ),
    ):
        assert is_either(*types)

    @parametrized
    def test_not(
        self,
        types=(("Dict", Dict), ("Dict", Dict, list)),
    ):
        assert not is_either(*types)
