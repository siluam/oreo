from oreo import remove_prefix_n, remove_suffix_n
from parametrized import parametrized
from pytest import mark


@mark.remove_prefix_n
class TestRemovePrefix:
    @parametrized.zip
    def test_remove_prefix(
        self,
        n=range(5),
        output=("yourboat", "rowrowyourboat", "rowyourboat", "yourboat", "yourboat"),
    ):
        assert remove_prefix_n(string="rowrowrowyourboat", prefix="row", n=n) == output

    @parametrized.zip
    def test_single_character(
        self, n=range(5), output=("yb", "rryb", "ryb", "yb", "yb")
    ):
        assert remove_prefix_n(string="rrryb", prefix="r", n=n) == output


@mark.remove_suffix_n
class TestRemoveSuffix:
    @parametrized.zip
    def test_remove_suffix(
        self, n=range(5), output=("lets", "letsgogo", "letsgo", "lets", "lets")
    ):
        assert remove_suffix_n(string="letsgogogo", suffix="go", n=n) == output

    @parametrized.zip
    def test_single_character(self, n=range(5), output=("l", "lgg", "lg", "l", "l")):
        assert remove_suffix_n(string="lggg", suffix="g", n=n) == output
