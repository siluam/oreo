(require hyrule [defmacro/g!])

;; ;; Run code in another directory and come back
(defmacro Assert [a [b True] [message None]]
  `(if (= ~a ~b) ~a (raise (AssertionError (or ~message ~a)))))

;; Set variables while in said directory
(defmacro/g! with-cwd [dir #* body]
  `(do (import os :as ~g!os pathlib [Path :as ~g!Path])
       (setv ~g!cwd (.cwd ~g!Path))
       (try ((. ~g!os chdir) ~dir)
            ~@body
            (finally ((. ~g!os chdir) ~g!cwd)))))

;; Adapted From:
;; Comment: https://stackoverflow.com/questions/73084195/require-macros-from-the-same-file-in-another-macro#comment129093172_73084195
;; User: https://stackoverflow.com/users/1451346/kodiologist
(defmacro/g! let-cwd [dir vars #* body]
  `(do (require oreo.hy [with-cwd :as ~g!with-cwd])
       (let ~vars
         (~g!with-cwd ~dir ~@body))))