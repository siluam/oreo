from oreo import Multi
from parametrized import parametrized
from pytest import mark, fixture, lazy_fixture

delims = (tuple(), (":",), (":", "/"), (":", "/", "."))


@mark.multi
class TestMulti:
    @fixture
    def string(self):
        return ("https://www.syvl.org/",)

    @fixture
    def multi(self, string, scope="class"):
        return Multi(*string)

    @parametrized.zip
    def test_partition(
        self,
        multi,
        delims=delims,
        output=(
            lazy_fixture("string"),
            ("https", ":", "//www.syvl.org/"),
            ("https", ":", "/", "/", "www.syvl.org", "/"),
            ("https", ":", "/", "/", "www", ".", "syvl", ".", "org", "/"),
        ),
    ):
        assert tuple(multi.partition(*delims)) == output

    @parametrized.zip
    def test_split(
        self,
        multi,
        delims=delims,
        output=(
            lazy_fixture("string"),
            ("https", "//www.syvl.org/"),
            ("https", "www.syvl.org"),
            ("https", "www", "syvl", "org"),
        ),
    ):
        assert tuple(multi.split(*delims)) == output

    def test_empty_split(self, multi):
        assert not tuple(multi.split(":", string="::"))
