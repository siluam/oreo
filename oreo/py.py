import requests
import os
from addict import Dict
from autoslot import Slots
from hy import mangle, unmangle
from ipaddress import IPv4Address, IPv6Address
from itertools import product
from more_itertools import collapse, powerset, unique_everseen
from pathlib import Path
from pytest import mark, param
from random import randint
from rich import print
from rich.pretty import pprint
from valiant import is_coll, module_installed


def cprint(obj, *args):
    if isinstance(obj, (str, bytes, bytearray, IPv4Address, IPv6Address, *args)):
        print(obj)
    else:
        pprint(obj)


def expandboth(path):
    return os.expanduser(os.expandvars(path))


# Adapted From:
# Answer 1: https://stackoverflow.com/a/27475071/10827766
# User 1: https://stackoverflow.com/users/100297/martijn-pieters
# Answer 2: https://stackoverflow.com/a/17246726/10827766
# User 2: https://stackoverflow.com/users/179805/fletom
# Comment: https://stackoverflow.com/questions/2611892/how-to-get-the-parents-of-a-python-class#comment70569175_2611939
# User: https://stackoverflow.com/users/210945/naught101
def is_either(first_type, second_type, *args):
    args = (first_type, second_type, *args)

    def inner(cls):
        if hasattr(cls, "__mro__"):
            return (m for m in cls.__mro__ if m != object)
        return (cls,)

    types1 = []
    for index1, type1 in enumerate(args):
        types2 = []
        for index2, type2 in enumerate(args):
            if index1 != index2:
                if isinstance(type2, ModuleCaller):
                    instance = type2()
                elif isinstance(type2, type):
                    instance = type2
                else:
                    instance = type(type2)
                types2.append(inner(instance))
        types2 = tuple(collapse(types2))
        if isinstance(type1, ModuleCaller):
            types1.append(issubclass(type1, types2))
        elif isinstance(type1, type):
            types1.append(issubclass(type1, types2))
        else:
            types1.append(issubclass(type(type1), types2) or isinstance(type1, types2))
    return any(types1)


# Single Use Import
def sui(_module, attr):
    if module := module_installed(_module):
        return getattr(module, attr)
    return module


def is_dots(string):
    return string == "." or string == ".."


def is_nots(string):
    return not is_dots(string)


def is_hidden(item):
    return item.startswith(".")


def is_visible(item):
    return not item.startswith(".")


def ls(dir=None, sort=False, key=False, reverse=False):
    dir = dir or Path.cwd()
    output = []
    if isinstance(dir, Path):
        for item in dir.iterdir():
            if is_visible(name := item.name):
                output.append(name)
    else:
        for item in os.listdir(dir):
            if is_visible(item):
                output.append(item)
    if sort or key != False or reverse:
        return sorted(output, key=key if callable(key) else None, reverse=reverse)
    else:
        return output


# First or last `n' values
def first_last_n(iterable=None, last=False, number=0, type_=iter):
    iterable = tuple(iterable)
    length = len(iterable)
    if number and iterable:
        result = iterable[length - number : length] if last else iterable[0:number]
    else:
        result = iterable
    return type_(result)


def flatten(*iterable, times=None):
    print(iterable, times, len(iterable))
    if len(iterable) == 1:
        first = iterable[0]
        if times == 0:
            return first
        else:
            iterable = first if is_coll(first) else iterable
    else:
        if times == 0:
            return iterable
    lst = []
    for i in iterable:
        if is_coll(i) and (times is None or times):
            lst.extend(flatten(i, times=(times - 1) if times else times))
        else:
            lst.append(i)
    return lst


def recursive_unmangle(dct):
    unmangled = Dict()
    for k, v in dct.items():
        unmangled[unmangle(k)] = recursive_unmangle(v) if isinstance(v, dict) else v
    return unmangled


# Adapted From:
# Answer: https://stackoverflow.com/a/829729/10827766
# User: https://stackoverflow.com/users/37984/saffsd
class Counter(Slots):
    def __init__(self, count):
        self.count = (
            count.count
            if isinstance(count, self.__class__)
            else count
            if is_int(count)
            else len(count)
        )

    def __nonzero__(self):
        self.count -= 1
        return self.count >= 0

    def __str__(self):
        return str(self.count)

    def __repr__(self):
        return repr(self.count)

    def __rich_repr__(self):
        yield self.__str__()

    __bool__ = __nonzero__


# Remove character or string `n' times
def remove_fix_n(rfix, string, fix, n=1):
    def inner(string):
        return getattr(string, "remove" + rfix)(fix)

    old_string = ""
    if n:
        n = Counter(n)
        while n:
            string = inner(string)
    else:
        if len(fix) == 1:
            string = getattr(string, ("l" if rfix == "prefix" else "r") + "strip")(fix)
        else:
            while old_string != string:
                old_string = string
                string = inner(string)
    return string


# Remove prefix `n' times
def remove_prefix_n(string, prefix, n=1):
    return remove_fix_n("prefix", string, prefix, n=n)


# Remove suffix `n' times
def remove_suffix_n(string, suffix, n=1):
    return remove_fix_n("suffix", string, suffix, n=n)


# Get a mangled or unmangled key
def get_un_mangled(dct, key, default=None):
    return dct.get(mangle(key), dct.get(unmangle(key).replace("_", "-"), default))


# Adapted From:
# Answer: https://stackoverflow.com/a/61618555/10827766
# User: https://stackoverflow.com/users/11769765/friedrich
class ModuleCaller:
    ...


def is_int(value):
    return isinstance(value, int) and (not isinstance(value, bool))


def is_palindrome(string, strict=False):
    s = string if strict else string.lower()
    l = len(s)
    if l % 2 == 0:
        return s[: l // 2 :][::-1] == s[l // 2 :]
    else:
        return s[: (l - 1) // 2 :][::-1] == s[(l + 1) // 2 :]


# Generate random palindromes
def genpal(n=1, odd=None):
    p = []
    n = Counter(n)
    while n:
        o = randint(0, 1) if odd is None else odd
        c = []
        count = Counter(randint(0, 100))
        while count:
            c.append(chr(randint(0, 255)))
        p.append("".join(c + ([chr(randint(0, 255))] if o else []) + c[::-1]))
    return p


# Get a list of dictionaries of all possible combinations of keys and values
def apcd(keys, values):
    return map(dict, [powerset(product(s, values)) for s in powerset(keys)][-1])


# Get a list of dictionaries of all possible combinations of keys and values
# if the length of the dictionary matches the length of the key;
# useful for getting all possible keyword argument combination of a function.
def apod(keys, values):
    return (s for s in unique_everseen(apcd(keys, values)) if len(s) == len(keys))


# `Pytest Mark' the keys from a list of dictionaries.
def mark_params(params, func=None):
    marked_params = []
    for p in params:
        marked_params.append(
            param(
                p,
                marks=[
                    getattr(mark, k)
                    for [k, v] in p.items()
                    if (func(k, v) if func else True)
                ],
            )
        )
    return marked_params


# Same as `apod', but the keys are `pytest.mark'-ed as well.
def mark_apod(keys, values, func=None):
    if (not func) and all((isinstance(v, bool) for v in values)):
        func = lambda k, v: v
    return mark_params(
        apod(keys, values),
        func,
    )


# Adapted From:
# Answer: https://stackoverflow.com/a/58055668/10827766
# User: https://stackoverflow.com/users/3831197/zhe
class BearerAuth(requests.auth.AuthBase):
    def __init__(self, token):
        self.token = token

    def __call__(self, r):
        r.headers["authorization"] = "Authorization: Bearer " + self.token
        return r
