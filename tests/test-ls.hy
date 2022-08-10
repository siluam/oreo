(import oreo [ls])
(require oreo [with-cwd])
(import pathlib [Path])
(defn test-ls-with-ls [cookies cookies-ls] (assert (= cookies-ls (ls cookies :sort True))))
(defn test-ls-with-listdir [cookies cookies-listdir] (assert (= cookies-listdir (ls cookies :sort True))))
(defn test-ls-listdir-with-ls [cookies cookies-ls] (assert (= cookies-ls (ls (str cookies) :sort True))))
(defn test-ls-listdir-with-listdir [cookies cookies-listdir] (assert (= cookies-listdir (ls (str cookies) :sort True))))
(defn test-ls-sort-reverse [cookies cookies-listdir] (assert (= (cut cookies-listdir None None -1) (ls cookies :reverse True))))
(defn test-ls-sort-key-true [cookies cookies-listdir] (assert (= cookies-listdir (ls cookies :key True))))
(defn test-ls-sort-key-function [cookies cookies-generator]
      (let [ func (fn [item] (if (.isnumeric item) (int item) -1)) ]
           (assert (= (sorted cookies-generator :key func)
                      (ls cookies :key func)))))
(defn test-ls-with-ls-listdir [cookies] (assert (= (ls cookies :sort True) (ls (str cookies) :sort True))))
(defn test-ls-cwd [cookies] (with-cwd cookies (assert (= (ls :sort True) (ls cookies :sort True)))))
