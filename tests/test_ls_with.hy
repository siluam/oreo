(import oreo [ls])
(import pytest [mark])
(require oreo [with-cwd])
(defn [mark.ls] test-ls-cwd [cookies] (with-cwd cookies (assert (= (ls :sort True) (ls cookies :sort True)))))
