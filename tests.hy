(import rich.traceback)
(.install rich.traceback)

(import oreo [eclair])
(import os [path :as osPath])

(setv funcs [])
(defn zoom [func] (.append funcs func))

#@(zoom (defn 69611341-cf92-48bb-8cda-79c7fe28d9f2 []
              (import oreo [eclair])
              (for [i (eclair (range 100) "69611341-cf92-48bb-8cda-79c7fe28d9f2" "red")])))

#@(zoom (defn 9a62edb0-a552-4283-914a-b4731968b1e4 []
              (import oreo [tea])
              (setv test (tea :a "b" :c "d"))
              (.append test "f")
              (.extend test "h" "j" "l")
              (.glue test "mnop")
              (.glue test (tea :q "r" :s "t"))
              (.glue test ["v" "x"])
              (assert (test) "b d f h j lmnopr tv x")))

#@(zoom (defn 66c3744b-a036-4476-b1ae-024bc99bee41 []
              (import oreo [either?])
              (import collections [OrderedDict])
              (import addict [Dict])
              (assert (either? OrderedDict dict))
              (assert (either? Dict dict))
              (assert (either? OrderedDict Dict))
              (assert (= (either? "Dict" Dict) False))
              (assert (either? "Dict" str))
              (assert (= (either? "Dict" Dict list) False))
              (assert (either? "OrderedDict" "Dict"))
              (assert (either? "OrderedDict" "Dict" list))))

#@(zoom (defn 554446e6-ffb6-4469-b4d2-90282e466751 []
              (import oreo [trim])
              (setv ten (range 10))
              (assert (all (gfor i (range 5) (in i (trim :iterable ten :number 5)))))
              (assert (all (gfor i (range 5 10) (in i (trim :iterable ten :number 5 :last True)))))))

(for [func (eclair funcs "tests" "blue")] (func))
