import pytest

def pytest_internalerror():
    return False

@pytest.fixture()
def cookies(request):
    from pathlib import Path
    return Path(request.config.rootdir).resolve(strict = True) / "cookies"

@pytest.fixture()
def cookies_ls(cookies):
    from subprocess import check_output
    return list(filter(None, check_output(["ls", cookies]).decode("utf-8").split("\n")))

@pytest.fixture()
def cookies_generator(cookies):
    from oreo import is_visible
    from os import listdir
    return (item for item in listdir(cookies) if is_visible(item))

@pytest.fixture()
def cookies_listdir(cookies_generator):
    return sorted(cookies_generator, key = str.lower)
