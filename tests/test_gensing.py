import hy
from parametrized import parametrized
from pytest import mark
from oreo import tea


@mark.gensing
class TestGensing:
    def test_construct(self):
        test = tea(a="b", c="d")
        test.append("f")
        test.extend("h", "j", "l")
        test.glue("mnop")
        test.glue(tea(q="r", s="t"))
        test.glue(["v", "x"])
        assert test() == "b d f h j lmnopr tv x"

    @parametrized
    def test_equality(
        self,
        rhs=(
            {hy.models.Keyword("a"): "b", hy.models.Keyword("c"): "d"},
            dict(a="b", c="d"),
            ["b", "d"],
            "b d",
            tea(a="b", c="d"),
            tea("b", "d"),
        ),
    ):
        assert tea(a="b", c="d") == rhs
