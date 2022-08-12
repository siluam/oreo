(import oreo [first-last-n])
(setv ten (range 10))
(defn test-first-5 [] (assert (all (gfor i (range 5) (in i (first-last-n :iterable ten :number 5))))))
(defn test-last-5 [] (assert (all (gfor i (range 5 10) (in i (first-last-n :iterable ten :number 5 :last True))))))
