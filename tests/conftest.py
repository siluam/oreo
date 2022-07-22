import pytest

@pytest.fixture()
def cookies():
    from pathlib import Path
    # return Path(__file__).parent.parent.resolve(strict = True) / "cookies"
    return Path.cwd() / "cookies"
