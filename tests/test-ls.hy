(import parametrized [parametrized])
(import pytest [mark])
(import oreo [ls])
(require oreo [with-cwd])
(import pathlib [Path])
(try (import cytoolz [first])
     (except [ImportError]
             (import toolz [first])))
(setv funcs #(
      (fn [cookies] (ls cookies :sort True))
      (fn [cookies] (ls (str cookies) :sort True))
      (fn [cookies] (ls cookies :key True))
))
(defn [mark.ls parametrized.zip] test-ls-ls [cookies cookies-ls [func funcs]] (assert (= ((first func) cookies) cookies-ls)))
(defn [mark.ls parametrized.zip] test-ls-listdir [cookies cookies-listdir [func funcs]] (assert (= ((first func) cookies) cookies-listdir)))
(defn [mark.ls] test-ls-sort-reverse [cookies cookies-listdir] (assert (= (cut cookies-listdir None None -1) (ls cookies :reverse True))))
(defn [mark.ls] test-ls-cwd [cookies] (with-cwd cookies (assert (= (ls :sort True) (ls cookies :sort True)))))
(defn [mark.ls] test-ls-sort-key-function [cookies cookies-generator]
      (let [ func (fn [item] (if (.isnumeric item) (int item) -1)) ]
           (assert (= (sorted cookies-generator :key func)
                      (ls cookies :key func)))))
(defn [mark.ls] test-ls-with-ls-listdir [cookies] (assert (= (ls cookies :sort True) (ls (str cookies) :sort True))))
