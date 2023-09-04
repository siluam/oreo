(import hy [models unmangle])
(import oreo [recursive-unmangle get-un-mangled])
(import pytest [mark fixture])

(defclass [mark.recursive-unmangle] TestRecursiveUnmangle []
  (defn test-flat [self]
    (assert (= (recursive-unmangle {:a 1 :b 2}) {":a" 1 ":b" 2})))
  (defn test-nested [self]
    (assert (= (recursive-unmangle {:a {:b 2} :c 3}) {":a" {":b" 2} ":c" 3}))))

(defclass [mark.get-un-mangled] TestUnMangled []
  (defn [fixture] dct [self] (dict :a-b 1 :c_d 2))
  (defn test-mangled [self dct]
    (assert (= (get-un-mangled dct "a_b") 1)))
  (defn test-unmangled [self dct]
    (assert (= (get-un-mangled dct "c-d") 2))))