(import oreo [tea])
(defn test-gensing []
      (setv test (tea :a "b" :c "d"))
      (.append test "f")
      (.extend test "h" "j" "l")
      (.glue test "mnop")
      (.glue test (tea :q "r" :s "t"))
      (.glue test ["v" "x"])
      (assert (= (test) "b d f h j lmnopr tv x")))
(defn test-gensing-dict-equality []
      (setv test (tea :a "b" :c "d"))
      (assert (= test { :a "b" :c "d" })))
(defn test-gensing-list-equality []
      (setv test (tea :a "b" :c "d"))
      (assert (= test ["b" "d"])))
(defn test-gensing-string-equality []
      (setv test (tea :a "b" :c "d"))
      (assert (= test "b d")))
(defn test-gensing-false-equality []
      (setv test (tea :a "b" :c "d"))
      (assert (not (= test None))))
(defn test-gensing-tea-equality []
      (setv test (tea :a "b" :c "d"))
      (assert (= test (tea "b" "d"))))
