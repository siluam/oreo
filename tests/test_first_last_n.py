from oreo import first_last_n
from pytest import mark


@mark.first_last_n
class TestFirstLastN:
    def test_first_5(self):
        assert list(range(5)) == first_last_n(iterable=range(10), number=5, type_=list)

    def test_last_5(self):
        assert list(range(5, 10)) == first_last_n(
            iterable=range(10), number=5, last=True, type_=list
        )
