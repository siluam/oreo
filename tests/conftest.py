import pytest

def pytest_internalerror():
    return False

@pytest.fixture()
def cookies(request):
    from pathlib import Path
    return Path(request.config.rootdir).resolve(strict = True) / "cookies"
