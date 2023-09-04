(import parametrized [parametrized])
(import pytest [mark])
(import pathlib [Path] hy)
(require oreo [let-cwd])
(defn [mark.let-cwd] test-let-cwd [cookies]
      (setv cwd (.cwd Path))
      (let-cwd cookies [ cwd cwd ] (assert (= (.cwd Path) cookies)))
      (assert (= (.cwd Path) cwd)))
