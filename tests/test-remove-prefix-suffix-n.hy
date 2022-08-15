(import parametrized [parametrized])
(import pytest [mark])
(import oreo [remove-prefix-n remove-suffix-n])
(setv fives (range 5))
(defn [mark.remove-prefix-n parametrized.zip] test-remove-prefix-n [[n fives] [output #("yourboat" "rowrowyourboat" "rowyourboat" "yourboat" "yourboat")]]
      (assert (= (remove-prefix-n :string "rowrowrowyourboat" :prefix "row" :n n))))
(defn [mark.remove-suffix-n parametrized.zip] test-remove-suffix-n [[n fives] [output #("lets" "letsgogo" "letsgo" "lets" "lets")]]
      (assert (= (remove-prefix-n :string "letsgogogo" :prefix "go" :n n))))
(defn [mark.remove-prefix-n parametrized.zip] test-remove-single-character-prefix-n [[n fives] [output #("yb" "rryb" "ryb" "yb" "yb")]]
      (assert (= (remove-prefix-n :string "rrryb" :prefix "r" :n n))))
(defn [mark.remove-suffix-n parametrized.zip] test-remove-single-character-suffix-n [[n fives] [output #("l" "lgg" "lg" "l" "l")]]
      (assert (= (remove-prefix-n :string "lggg" :prefix "g" :n n))))
