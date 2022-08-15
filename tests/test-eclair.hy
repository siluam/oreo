(import parametrized [parametrized])
(import pytest [mark])
(import oreo [eclair])
(defn [mark.eclair] test-eclair [] (for [i (eclair (range 100) "69611341-cf92-48bb-8cda-79c7fe28d9f2" "red")]))
