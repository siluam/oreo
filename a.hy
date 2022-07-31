(defmacro assert [a [b True] [message None]] `(if (= ~a ~b) ~a (raise (AssertionError (or ~message ~a)))))
