from colors import strip_color
from oreo import is_visible, ls, Multi
from os import listdir
from pytest import mark, fixture, lazy_fixture
from valiant import SH


@mark.ls
class TestLs:
    @fixture
    def sorted_cookies(self, cookies):
        return ls(cookies, sort=True)

    @fixture
    def string_cookies(self, cookies):
        return ls(str(cookies), sort=True)

    @fixture
    def keyed_cookies(self, cookies):
        return ls(cookies, key=True)

    @fixture(
        params=(
            lazy_fixture("sorted_cookies"),
            lazy_fixture("string_cookies"),
            lazy_fixture("keyed_cookies"),
        )
    )
    def cookiejar(self, request):
        return request.param

    @mark.multi
    def test_ls(self, cookies, cookiejar):
        assert cookiejar == sorted(
            Multi(strip_color(SH.ls(cookies))).split("\n", " ", "\t")
        )

    def test_listdir(self, cookies_listdir, cookiejar):
        assert cookiejar == cookies_listdir

    def test_sort_reverse(self, cookies, cookies_listdir):
        assert cookies_listdir[::-1] == ls(cookies, reverse=True)

    def test_sort_key_function(self, cookies):
        func = lambda item: int(item) if item.isnumeric() else -1
        assert sorted(filter(is_visible, listdir(cookies)), key=func) == ls(
            cookies, key=func
        )

    def test_eq_listdir(self, sorted_cookies, string_cookies):
        assert sorted_cookies == string_cookies
