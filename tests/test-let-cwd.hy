(import pathlib [Path] hy)
(require oreo [let-cwd])
(defn test-let-cwd [cookies]
      (setv cwd (.cwd Path))
      (let-cwd cookies [ cwd cwd ] (= (.cwd Path) (/ cwd "cookies")))
      (let-cwd cookies [ cwd cwd ] (assert (= (.cwd Path) (/ cwd "cookies"))))
      (assert (= (.cwd Path) cwd)))
