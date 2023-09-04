import rich.traceback as RichTraceback

RichTraceback.install(show_locals=True)

import hy as _hy

_hy.macros.require(
    "oreo.hy",
    # The Python equivalent of `(require oreo.hy *)`
    None,
    assignments="ALL",
    prefix="",
)
_hy.macros.require_reader("oreo.hy", None, assignments="ALL")
from oreo.py import *
from oreo.eclair import *
from oreo.gensing import *
from oreo.multi import *
from oreo.option import *
from oreo.passwords import *
