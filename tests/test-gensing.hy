(import oreo [tea])
(setv test (tea :a "b" :c "d"))
(defn test-gensing []
      (.append test "f")
      (.extend test "h" "j" "l")
      (.glue test "mnop")
      (.glue test (tea :q "r" :s "t"))
      (.glue test ["v" "x"])
      (assert (= (test) "b d f h j lmnopr tv x")))
