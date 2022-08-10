(import pathlib [Path])
(require oreo [with-cwd])
(defn test-with-cwd [cookies]
      (let [ cwd (.cwd Path) ]
           (with-cwd cookies (assert (= (.cwd Path) cookies)))
           (assert (= (.cwd Path) cwd))))
