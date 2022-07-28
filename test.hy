(defmacro assert [a [b True] [message None]] `(if (not (= ~a ~b)) (raise (AssertionError (or ~message ~a)))))
(assert 1 1)
