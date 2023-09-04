from more_itertools import collapse
from oreo import is_palindrome, genpal
from parametrized import parametrized
from pytest import mark, fixture
from random import randint


@mark.palindrome
class TestPalindomes:
    @fixture(params=("Tacocat", "Mom", "Ho-oh", "Abba", "Hannah"))
    def palindrome(self, request):
        return request.param

    def test_palindromes(self, palindrome):
        assert is_palindrome(palindrome)

    @parametrized
    def test_not(
        self, p=("These", "are", "not", "supposed", "to", "be", "palindromes!")
    ):
        assert not is_palindrome(p)

    def test_strict(self, palindrome):
        assert is_palindrome(palindrome.lower(), strict=True)

    def test_not_strict(self, palindrome):
        assert not is_palindrome(palindrome, strict=True)

    @parametrized
    def test_generating(
        self,
        p=collapse(genpal(n=randint(0, 100), odd=odd) for odd in (None, True, False)),
    ):
        assert is_palindrome(p, strict=True)
