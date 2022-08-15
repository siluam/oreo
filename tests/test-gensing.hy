(import parametrized [parametrized])
(import pytest [mark])
(import oreo [tea])
(defn [mark.gensing] test-gensing []
      (setv test (tea :a "b" :c "d"))
      (.append test "f")
      (.extend test "h" "j" "l")
      (.glue test "mnop")
      (.glue test (tea :q "r" :s "t"))
      (.glue test ["v" "x"])
      (assert (= (test) "b d f h j lmnopr tv x")))
(defn [mark.gensing (.parametrize mark "rhs" #(
      { :a "b" :c "d" }
      { "a" "b" "c" "d" }
      ["b" "d"]
      "b d"
      (tea :a "b" :c "d")
      (tea "b" "d")
))] test-gensing-equality [rhs] (assert (= (tea :a "b" :c "d") rhs)))
