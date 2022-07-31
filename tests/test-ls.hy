(import oreo [ls])
(require oreo [with-cwd])
(import os [listdir])
(import subprocess [check-output])
(import pathlib [Path])
(defn test-ls-with-ls [cookies]
      (assert (= (sorted (filter None (.split (.decode (check-output [ "ls" "cookies" ]) "utf-8") "\n")))
                 (ls cookies :sort True))))
(defn test-ls-with-listdir [cookies]
      (assert (= (sorted (gfor item (listdir cookies) :if (not (.startswith item ".")) item))
                 (ls cookies :sort True))))
(defn test-ls-listdir-with-ls [cookies]
      (assert (= (sorted (filter None (.split (.decode (check-output [ "ls" "cookies" ]) "utf-8") "\n")))
                 (ls (str cookies) :sort True))))
(defn test-ls-listdir-with-listdir [cookies]
      (assert (= (sorted (gfor item (listdir cookies) :if (not (.startswith item ".")) item))
                 (ls (str cookies) :sort True))))
(defn test-ls-with-ls-listdir [cookies] (assert (= (ls cookies :sort True) (ls (str cookies) :sort True))))
(defn test-ls-cwd [cookies] (with-cwd cookies (assert (= (ls :sort True) (ls cookies :sort True)))))
