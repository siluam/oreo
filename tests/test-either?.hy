(import oreo [either?])
(import collections [OrderedDict])
(import addict [Dict])

(defn test-either-OrderedDict-dict [] (assert (either? OrderedDict dict)))
(defn test-either-OrderedDict-Dict [] (assert (either? OrderedDict Dict)))
(defn test-either-Dict-dict [] (assert (either? Dict dict)))

(defn test-either-Dict-not-string [] (assert (= (either? "Dict" Dict) False)))

(defn test-either-isinstance-string [] (assert (either? "Dict" str)))

(defn test-either-none-of [] (assert (= (either? "Dict" Dict list) False)))

(defn test-either-one-of [] (assert (either? "OrderedDict" "Dict" list)))

(defn test-either-instances [] (assert (either? "OrderedDict" "Dict")))
