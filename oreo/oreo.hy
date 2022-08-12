(import rich.traceback)
(.install rich.traceback :show-locals True)

(import click)

(eval-and-compile (import os hy))
(eval-and-compile (import pathlib [Path]))

(import addict [Dict :as D])
(import autoslot [SlotsMeta])
(import collections [OrderedDict])
(import collections.abc [Iterable])
(import contextlib [contextmanager])
(import hy [mangle unmangle])
(import hyrule [dec])
(import importlib.util [spec-from-file-location module-from-spec])
(import itertools [islice])
(import rich [print])
(import rich.pretty [pprint])
(import rich.progress [Progress])
(import time [sleep])
(import uuid [uuid4])

(try (import coconut *)
     (except [ImportError] None))

(try (import cytoolz [first])
     (except [ImportError]
             (import toolz [first])))

(require hyrule [-> assoc unless])

(defmacro Assert [a [b True] [message None]] `(if (= ~a ~b) ~a (raise (AssertionError (or ~message ~a)))))

(defmacro with-cwd [dir #* body]
          (setv cwd (hy.gensym))
          `(let [ ~cwd (.cwd Path) ]
                (try (.chdir os ~dir)
                     ~@body
                     (finally (.chdir os ~cwd)))))

(defmacro let-cwd [dir vars #* body]
          (setv with-cwd (hy.gensym))
          `(do (require oreo.oreo [with-cwd :as ~with-cwd]) (let ~vars (~with-cwd ~dir ~@body))))

(defn cprint [obj]
      (if (isinstance obj #(str bytes bytearray))
          (print obj)
          (pprint obj)))

(defn either? [first-type second-type #* args]
      (setv args #(first-type second-type #* args))
      (defn inner [cls]
            (return (if (hasattr cls "__mro__")
                        (gfor m cls.__mro__ :if (!= m object) m)
                        #(cls))))
      (any (gfor [i a]
                 (enumerate args)
                 :setv typle (tuple (flatten (gfor [j b]
                                                   (enumerate args)
                                                   :if (!= i j)
                                                   (inner (cond (isinstance b ModuleCaller) (b)
                                                                (isinstance b type) b
                                                                True (type b))))))
                 (cond (isinstance a ModuleCaller) (issubclass (a) typle)
                       (isinstance a type) (issubclass a typle)
                       True (or (issubclass (type a) typle)
                                 (isinstance a typle))))))

(defn coll? [coll]
      (return (if (isinstance coll #(str bytes bytearray))
                  False
                  (try (iter coll)
                       (except [TypeError]
                               (isinstance coll Iterable))
                       (else True)))))

(defn module-installed [path]
      (setv spec (-> os.path
                     (.basename path)
                     (.split ".")
                     (get 0)
                     (spec-from-file-location path)))
      (return (if spec
                  (do (setv module (module-from-spec spec))
                      (.exec-module spec.loader module)
                      module)
                  False)))

(defn sui [*module attr]
      (return (if (setx module (module-installed *module))
                  (getattr module attr)
                  module)))

(defn dots? [string] (or (= string ".") (= string "..")))

(defn nots? [string] (not (dots? string)))

(defn hidden? [item] (.startswith item "."))

(defn visible? [item] (not (.startswith item ".")))

(defn ls [[dir None] [sort False] [key False] [reverse False]]
      (let [ dir (or dir (.cwd Path))
             output (lfor item (if (isinstance dir Path) (.iterdir dir) (.listdir os dir)) :if visible? (getattr item "name" item)) ]
           (if (or sort (!= key False) reverse)
               (sorted output :key (if (callable key) key None) :reverse reverse)
               output)))

(defn first-last-n [[iterable None] [last False] [number 0] [type- iter]]
      (setv iterable (tuple iterable)
            first-last-n/len (len iterable)
            result (if (and number iterable)
                       (if last
                           (cut iterable (- first-last-n/len number) first-last-n/len)
                           (cut iterable 0 number))
                       iterable))
      (return (type- result)))

(defn flatten [#* iterable [times None]]
      (if (= (len iterable) 1)
          (do (setv first (get iterable 0))
              (if (= times 0)
                  (return first)
                  (setv iterable (if (coll? first)
                                     first
                                     iterable))))
          (when (= times 0) (return iterable)))
      (setv lst [])
      (for [i iterable]
           (if (and (coll? i)
                    (or (is times None)
                        times))
               (.extend lst (flatten i :times (if times (dec times) times)))
               (.append lst i)))
      (return lst))

(defn multipart [string delimiter [all-parts None]]
      (setv all-parts (or all-parts []))
      (for [part (.partition string delimiter)]
           (if (and (in delimiter part) (!= delimiter part))
               (setv all-parts (multipart part delimiter :all-parts all-parts))
               (.append all-parts part)))
      (return (filter None all-parts)))

(defn recursive-unmangle [dct]
      (return (D (dfor [key value]
                       (.items dct)
                       [(unmangle key)
                        (if (isinstance value dict)
                            (recursive-unmangle value)
                            value)]))))

(defn remove-fix-n [rfix string fix [n 1]]
      (setv old-string "")
      (if n
          (for [i (range n)]
               (setv string ((getattr string (+ "remove" rfix)) fix)))
          (if (= (len fix) 1)
              (setv string ((getattr string (+ (if (= fix "prefix") "l" "r") "strip")) string fix))
              (while (!= old-string string)
                     (setv old-string string
                           string (.removeprefix string fix)))))
      (return string))

#_(defn remove-prefix-n [string prefix [n 1]]
      (setv old-string "")
      (if n
          (for [i (range n)]
               (setv string (.removeprefix string prefix)))
          (if (= (len prefix) 1)
              (setv string (.lstrip string prefix))
              (while (!= old-string string)
                     (setv old-string string
                           string (.removeprefix string prefix)))))
      (return string))

(defn remove-prefix-n [string prefix [n 1]]
      (return (remove-fix-n "prefix" string prefix :n n)))

#_(defn remove-suffix-n [string suffix [n 1]]
      (setv old-string "")
      (if n
          (for [i (range n)]
               (setv string (.removesuffix string suffix)))
          (if (= (len suffix) 1)
              (setv string (.rstrip string suffix))
              (while (!= old-string string)
                     (setv old-string string
                           string (.removesuffix string suffix)))))
      (return string))

(defn remove-suffix-n [string suffix [n 1]]
      (return (remove-fix-n "suffix" string suffix :n n)))

(defn get-un-mangled [dct key [default None]]
      (return (or (.get dct (mangle key) None)
                  (.get dct (.replace (unmangle key) "_" "-") default))))

(defclass ModuleCaller)

(defn int? [value] (return (and (isinstance value int) (not (isinstance value bool)))))

(defclass meclair [SlotsMeta]

(defn __init__ [cls #* args #** kwargs] (setv cls.Progress (Progress :auto-refresh False))))

(defclass eclair [:metaclass meclair]

(defn __init__ [self iterable name color [sleep 0.025]]
    (setv self.color color
          self.iterable (tuple iterable)
          self.len (len iterable)
          self.increment (/ 100 self.len)
          self.n 0
          self.name name
          self.sleep sleep)

(when (= (len self.__class__.Progress.task-ids) 0)
      (setv self.first-task (.add-task self.__class__.Progress f"[green]start" :total 0 :visible False)))

(setv self.task (.add-task self.__class__.Progress f"[{self.color}]{self.name}" :total self.len :start False))

)

(defn __iter__ [self]
      (setv self.n 0)
      (if (= (len self.__class__.Progress.task-ids) 2)
          (do (.start self.__class__.Progress)
              (.start-task self.__class__.Progress (get self.__class__.Progress.task-ids 1)))
          (.start-task self.__class__.Progress self.task))
      (return self))

(defn __next__ [self]
      (if (< self.n self.len)
          (try (sleep self.sleep)
               (.update self.__class__.Progress self.task :advance self.increment :refresh True)
               (return (get self.iterable self.n))
               (finally (+= self.n 1)))
          (try (raise StopIteration)
               (finally (.stop-task self.__class__.Progress self.task)
                        (when self.__class__.Progress.finished
                              (.stop self.__class__.Progress))))))

)

(defclass Option [click.Option]

(defn [staticmethod] static/name [name]
      (-> name
          (remove-prefix-n "-" :n 2)
          (.replace "-" "_")
          (.lower)))

(defn [staticmethod] static/opt-joined [name opt-val opt-len]
      (if (= opt-len 1)
          (get opt-val 0)
          (.join ", " (gfor opt opt-val :if (!= opt name) opt))))

(defn [staticmethod] option? [opt-len] (if (= opt-len 1) "option" "options"))

(defn [staticmethod] is? [opt-len] (if (= opt-len 1) "is" "are"))

(defn [staticmethod] da-use? [opt-len] (if (= opt-len 1) "the use" "one or more"))

(defn [staticmethod] static/gen-help [help end] (+ help "\nNOTE: This option " end))

(defn __init__ [self #* args #** kwargs]

(setv nargs (get args 0)
      name (cond (= (len nargs) 1) (.static/name self.__class__ (get nargs 0))
                 (= (len nargs) 2) (if (.startswith (setx pre-name (get nargs 0)) "--")
                                       (.static/name self.__class__ pre-name)
                                       (.static/name self.__class__ (get nargs 1)))
                 (= (len nargs) 3) (get nargs 3)))

(setv help (.get kwargs "help" ""))

(when (setx self.xor (.pop kwargs "xor" (,)))
      (setv self.xor-len (len self.xor)
            self.xor-joined (.static/opt-joined self.__class__ name self.xor self.xor-len)
            self.xor-help #[f[is mutually exclusive with {(.option? self.__class__ self.xor-len)} {self.xor-joined}.]f]
            help (.static/gen-help self.__class__ help self.xor-help)))

(setv self.one-req (or (.pop kwargs "one_req" None)
                       (.pop kwargs "one-req" (,))))
(when self.one-req
      (setv self.one-req-len (len self.one-req)
            self.one-req-joined (.static/opt-joined self.__class__ name self.one-req self.one-req-len)
            self.one-req-help #[f[must be used if {(.option? self.__class__ self.one-req-len)} {self.one-req-joined} {(.is? self.__class__ self.one-req-len)} not.]f]
            help (.static/gen-help self.__class__ help self.one-req-help)))

(setv self.req-one-of (or (.pop kwargs "req_one_of" None)
                          (.pop kwargs "req-one-of" (,))))
(when self.req-one-of
      (setv self.req-one-of-len (len self.req-one-of)
            self.req-one-of-joined (.static/opt-joined self.__class__ name self.req-one-of self.req-one-of-len)
            self.req-one-of-help #[f[requires {(.da-use? self.__class__ self.req-one-of-len)} of {(.option? self.__class__ self.req-one-of-len)} {self.req-one-of-joined} as well.]f]
            help (.static/gen-help self.__class__ help self.req-one-of-help)))

(setv self.req-all-of (or (.pop kwargs "req_all_of" None)
                          (.pop kwargs "req-all-of" (,))))
(when self.req-all-of
      (setv self.req-all-of-len (len self.req-all-of)
            self.req-all-of-joined (.static/opt-joined self.__class__ name self.req-all-of self.req-all-of-len)
            self.req-all-of-help #[f[requires {(.option? self.__class__ self.req-all-of-len)} {self.req-all-of-joined} as well.]f]
            help (.static/gen-help self.__class__ help self.req-all-of-help)))

(.update kwargs { "help" help })

(.__init__ (super) #* args #** kwargs)

)

(defn handle-parse-result [self ctx opts args]

(when (and (in self.name opts)
           self.xor
           (any (gfor opt self.xor (in opt opts))))
      (raise (click.UsageError f"Sorry; {self.name} {self.xor-help}")))

(when (and (in self.name opts)
           self.req-one-of
           (not (any (gfor opt self.req-one-of (in opt opts)))))
      (raise (click.UsageError f"Sorry; {self.name} {self.req-one-of-help}")))

(when (and (in self.name opts)
           self.req-all-of
           (not (all (gfor opt self.req-all-of (in opt opts)))))
      (raise (click.UsageError f"Sorry; {self.name} {self.req-all-of-help}")))

(return (.handle-parse-result (super) ctx opts args))

)

)

(defclass tea [OrderedDict]

(defn __init__ [self #* args #** kwargs]

(setv super-dict (dict (enumerate args)))
(.update super-dict kwargs)

(.__init__ (super) (gfor [k v] (.items super-dict) #(k v)))

)

(defn gin [self [delimiter " "] [override-type None]]
      (setv values (tuple (.values self)))
      (when override-type
            (setv values (tuple (map override-type values))))
      (try (setv first-value (get values 0))
           (except [IndexError] None)
           (else (return (cond (isinstance first-value str) (.strip (.join delimiter (map str values)))
                               (isinstance first-value int) (sum (map int values))
                               (all (gfor value values (isinstance value (type first-value))))
                                (do (setv total first-value)
                                    (for [value (cut values 1 (len values))]
                                         (+= total value))
                                    total)
                               True (raise (TypeError "Sorry! All values in the tea must be of the same type to join!")))))))

(defn __call__ [self [delimiter " "] [override-type None]] (.gin self :delimiter delimiter :override-type override-type))

(defn __str__ [self] (.gin self :override-type str))

(defn get-next-free-index [self]
      (setv current-len (len self)
            keys (.keys self))
      (when (in current-len keys)
            (while (in current-len keys)
                   (+= current-len 1)))
      (return current-len))

(defn append [self summand [key None]] (assoc self (or key (.get-next-free-index self)) summand))

(defn shifted [self #* args]
      (setv shift (.get-next-free-index self))
      (return (dfor [i s] (enumerate args) [(+ i shift) s])))

(defn extend [self #* args #** kwargs]
      (.update self (.shifted self #* args))
      (.update self kwargs))

(defn glue [self summand [override-type None]]
      (setv [last-key last-value] (.popitem self :last True)
            last-value (if override-type
                           (override-type last-value)
                           last-value)
            summand-is-collection (coll? summand)
            summand-is-dict (isinstance summand dict)
            summand (if (and summand-is-collection
                             (not summand-is-dict))
                        (list summand)
                        summand)

            summand-first-value (if summand-is-collection
                                    (.pop summand
                                          (if summand-is-dict
                                              (next (iter summand))
                                              0))
                                    summand)

            summand-first-value (if override-type
                                    (override-type summand-first-value)
                                    summand-first-value)
            summand-first-value (if (either? last-value summand-first-value)
                                    summand-first-value
                                    (raise (TypeError "Sorry! The last value of this tea and first value of the provided collection must be of the same type!"))))
      (assoc self last-key (+ last-value summand-first-value))
      (when summand-is-collection
            (.update self (if summand-is-dict
                              summand
                              (.shifted self #* summand)))))

(defn __add__ [self summand]
      (setv scopy (deepcopy self))
      (cond (isinstance summand dict) (.update scopy summand)
            (coll? summand) (.update scopy (.shifted scopy #* summand))
            True (assoc scopy (.get-next-free-index scopy) summand))
      (return scopy))

(defn __sub__ [self subtrahend]
      (setv scopy (deeepcopy self))
      (for [key subtrahend]
           (del (get scopy key)))
      (return scopy))

(defn __eq__ [self expr]
      (return (cond (isinstance expr self.__class__) (= (expr) (self))
                    (isinstance expr dict) (= (.items self) (.items (dfor [k v] (.items expr) [k.name v])))
                    (coll? expr) (all (gfor [a b] (zip (.values self) expr :strict True) (= a b)))
                    (isinstance expr str) (= (self) expr)
                    True False)))

)
