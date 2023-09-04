from oreo import flatten
from parametrized import parametrized
from pytest import mark, fixture, lazy_fixture


@mark.flatten
class TestFlatten:
    @fixture
    def nested(self):
        return 1, (2, (3, (4,)))

    @fixture
    def flattened(self):
        return [1, 2, 3, 4]

    @fixture
    def flattened_once(self):
        return [1, 2, (3, (4,))]

    @fixture
    def flattened_twice(self):
        return [1, 2, 3, (4,)]

    def test_one_item(self):
        assert flatten(1) == [1]

    def test_all(self, nested, flattened):
        assert flatten(nested) == flattened

    @parametrized.zip
    def test_flatten(
        self,
        nested,
        outputs=(
            lazy_fixture("nested"),
            lazy_fixture("flattened_once"),
            lazy_fixture("flattened_twice"),
            lazy_fixture("flattened"),
        ),
        times=range(5),
    ):
        assert flatten(nested, times=times) == outputs

    def test_all_unpacked(self, nested, flattened):
        assert flatten(*nested) == flattened

    @parametrized.zip
    def test_unpacked(
        self,
        nested,
        outputs=(
            lazy_fixture("nested"),
            lazy_fixture("flattened_once"),
            lazy_fixture("flattened_twice"),
            lazy_fixture("flattened"),
        ),
        times=range(5),
    ):
        assert flatten(*nested, times=times) == outputs
