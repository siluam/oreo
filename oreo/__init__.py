import rich.traceback as RichTraceback
RichTraceback.install(show_locals = True)

import hy

hy.macros.require('oreo.oreo',
    # The Python equivalent of `(require oreo.oreo *)`
    None, assignments = 'ALL', prefix = '')
hy.macros.require_reader('oreo.oreo', None, assignments = 'ALL')
from oreo.oreo import *
