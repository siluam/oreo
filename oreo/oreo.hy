(import rich.traceback)
(.install rich.traceback :show-locals True)

(import click)
(import os)

(import addict [Dict :as D])
(import autoslot [SlotsMeta])
(import collections [OrderedDict])
(import hy [mangle unmangle])
(import hyrule [coll?])
(import importlib.util [spec-from-file-location module-from-spec])
(import itertools [islice])
(import rich.progress [Progress])

(require hyrule [-> assoc])

(try (import coconut *)
     (except [ImportError] None))

(try (import cytoolz [first])
     (except [ImportError]
             (import toolz [first])))

(defn module-installed [path]
      (setv spec (-> os.path
                     (.basename path)
                     (.split ".")
                     (get 0)
                     (spec-from-file-location path)))
      (if spec
          (do (setv module (module-from-spec spec))
              (.exec-module spec.loader module)
              (return module))
          (return False)))

(defn sui [*module attr]
      (return (if (setx module (module-installed *module))
                  (getattr module attr)
                  module)))

(defn trim [[iterable None] [last False] [number 0]]
      (setv iterable (tuple iterable)
            trim/len (len iterable))
      (yield-from (if (and number iterable)
                      (if last
                          (islice iterable (- trim/len number) trim/len)
                          (islice iterable 0 number))
                      iterable)))

(defn flatten [iterable [times None]]
      (setv lst [])
      (for [i iterable]
           (if (and (coll? i)
                    (or (is times None)
                        times))
               (.extend lst (flatten i :times (if times (dec times) times)))
               (.append lst i)))
      (return lst))

(defn recursive-unmangle [dct]
      (return (D (dfor [key value]
                       (.items dct)
                       [(unmangle key)
                        (if (isinstance value dict)
                            (recursive-unmangle value)
                            value)]))))

(defn remove-prefix-n [string prefix [n 1]]
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

(defn remove-suffix-n [string suffix [n 1]]
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

(defn get-un-mangled [dct key [default None]]
      (return (or (.get dct (mangle key) None)
                  (.get dct (.replace (unmangle key) "_" "-") default))))

(defclass ModuleCaller)

(defn int? [value] (return (and (isinstance value int) (not (isinstance value bool)))))

(defn either? [first-type second-type #* args]
      (setv args (, first-type second-type #* args))
      (defn inner [cls]
            (return (if (hasattr cls "__mro__")
                        (gfor m cls.__mro__ :if (!= m object) m)
                        (, cls))))
      (any (gfor [i a]
                 (enumerate args)
                 :setv typle (tuple (flatten (gfor [j b]
                                                   (enumerate args)
                                                   :if (!= i j)
                                                   (inner (cond [(isinstance b ModuleCaller) (b)]
                                                                [(isinstance b type) b]
                                                                [True (type b)])))))
                 (cond [(isinstance a ModuleCaller) (issubclass (a) typle)]
                       [(isinstance a type) (issubclass a typle)]
                       [True (or (issubclass (type a) typle)
                                 (isinstance a typle))]))))

(defclass meclair [SlotsMeta]

(defn __init__ [cls #* args #** kwargs] (setv cls.Progress (Progress :auto-refresh False))))

(defclass eclair [:metaclass meclair]

(defn __init__ [self iterable name color]
    (setv self.color color
          self.iterable (tuple iterable)
          self.len (len iterable)
          self.increment (/ 100 self.len)
          self.n 0
          self.name name

self.task (.add-task self.__class__.Progress f"[{self.color}]{self.name}" :total self.len))

)

(defn __iter__ [self]
    (setv self.n 0)
    (.start self.__class__.Progress)
    (return self))

(defn __next__ [self]
      (if (< self.n self.len)
          (try (.update self.__class__.Progress self.task :advance self.increment :refresh True)
               (return (get self.iterable self.n))
               (finally (+= self.n 1)))
          (try (raise StopIteration)
               (finally (.stop self.__class__.Progress)))))

)

(defclass Option [click.Option]

#@(staticmethod (defn static/name [name]
                      (-> name
                          (remove-prefix-n "-" :n 2)
                          (.replace "-" "_")
                          (.lower))))

#@(staticmethod (defn static/opt-joined [opt-val opt-len]
                      (if (= opt-len 1)
                          (get opt-val 0)
                          (.join ", " (gfor opt opt-val :if (!= opt name) opt)))))

#@(staticmethod (defn option? [opt-len] (if (= opt-len 1) "option" "options")))

#@(staticmethod (defn is? [opt-len] (if (= opt-len 1) "is" "are")))

#@(staticmethod (defn da-use? [opt-len] (if (= opt-len 1) "the use" "one or more")))

#@(classmethod (defn static/gen-help [cls help end] (+ help "\nNOTE: This option " end)))

(defn __init__ [self #* args #** kwargs]

(setv name (cond [(= (len args) 1) (.static/name self.__class__ (get args 0))]
                 [(= (len args) 2) (if (.startswith (setx pre-name (get args 0)) "--")
                                       (.static/name self.__class__ pre-name)
                                       (.static/name self.__class__ (get args 1)))]
                 [(= (len args) 3) (get args 3)]))

(setv help (.get kwargs "help" ""))

(if (setx self.xor (.pop kwargs "xor" (,)))
    (do (setv self.xor-len (len self.xor)
              self.xor-joined (.static/opt-joined self.__class__ self.xor self.xor-len)
              self.xor-help #[f[is mutually exclusive with {(.option? self.__class__ self.xor-len)} {self.xor-joined}.]f])
        (+= help (.static/gen-help help self.xor-help))))

(setv self.one-req (or (.pop kwargs "one_req" None)
                       (.pop kwargs "one-req" (,))))
(if self.one-req
    (do (setv self.one-req-len (len self.one-req)
              self.one-req-joined (.static/opt-joined self.__class__ self.one-req self.one-req-len)
              self.one-req-help #[f[must be used if {(.option? self.__class__ self.one-req-len)} {self.one-req-joined} {(.is? self.__class__ self.one-req-len)} not.]f])
        (+= help (.static/gen-help help self.one-req-help))))

(setv self.req-one-of (or (.pop kwargs "req_one_of" None)
                          (.pop kwargs "req-one-of" (,))))
(if self.req-one-of
    (do (setv self.req-one-of-len (len self.req-one-of)
              self.req-one-of-joined (.static/opt-joined self.__class__ self.req-one-of self.req-one-of-len)
              self.req-one-of-help #[f[requires {(.da-use? self.__class__ self.req-one-of-len)} of {(.option? self.__class__ self.req-one-of-len)} {self.req-one-of-joined} as well.]f])
        (+= help (.static/gen-help help self.req-one-of-help))))

(setv self.req-all-of (or (.pop kwargs "req_all_of" None)
                          (.pop kwargs "req-all-of" (,))))
(if self.req-all-of
    (do (setv self.req-all-of-len (len self.req-all-of)
              self.req-all-of-joined (.static/opt-joined self.__class__ self.req-all-of self.req-all-of-len)
              self.req-all-of-help #[f[requires {(.option? self.__class__ self.req-all-of-len)} {self.req-all-of-joined} as well.]f])
        (+= help (.static/gen-help help ))))

(.update kwargs { "help" help })

(.__init__ (super) #* args #** kwargs)

)

(defn handle-parse-result [self ctx opts args]

(if (and (in self.name opts)
         self.xor
         (any (gfor opt self.xor (in opt opts))))
    (raise (click.UsageError f"Sorry; {self.name} {self.xor-help}")))

(if (not (and (not self.one-req)
              (in self.name opts)
              (any (gfor opt self.one-req (in opt opts)))))
    (raise (click.UsageError (+ "Sorry! "
                                (if (= self.one-req-len 1) "One of " "")
                                self.one-req-joined
                                " is required."))))

(if (and (in self.name opts)
         self.req-one-of
         (not (any (gfor opt self.req-one-of (in opt opts)))))
    (raise (click.UsageError f"Sorry; {self.name} {self.req-one-of-help}")))

(if (and (in self.name opts)
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

(.__init__ (super) (gfor [k v] (.items super-dict) (, k v)))

)

(defn gin [self [delimiter " "] [override-type None]]
      (setv values (tuple (.values self)))
      (if override-type
          (setv values (tuple (map override-type values))))
      (try (setv first-value (get values 0))
           (except [IndexError] None)
           (else (return (cond [(isinstance first-value str) (.join delimiter (map str values))]
                               [(isinstance first-value int) (sum (map int values))]
                               [(all (gfor value values (isinstance value (type first-value))))
                                (do (setv total first-value)
                                    (for [value (cut values 1 (len values))]
                                         (+= total value))
                                    total)]
                               [True (raise (TypeError "Sorry! All values in the tea must be of the same type to join!"))])))))

(defn __call__ [self #* args #** kwargs] (.gin self #* args #** kwargs))

(defn __str__ [self] (.gin self :override-type str))

(defn get-next-free-index [self]
      (setv current-len (len self)
            keys (.keys self))
      (if (in current-len keys)
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

summand-first-value (if summand-is-collection
                        (.pop summand (if summand-is-dict
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
(if summand-is-collection
    (.update self (if summand-is-dict
                      summand
                      (.shifted self #* summand)))))

(defn __add__ [self summand]
      (setv scopy (deepcopy self))
      (cond [(isinstance summand dict) (.update scopy summand)]
            [(coll? summand) (.update scopy (.shifted scopy #* summand))]
            [True (assoc scopy (.get-next-free-index scopy) summand)])
      (return scopy))

(defn __sub__ [self subtrahend]
      (setv scopy (deeepcopy self))
      (for [key subtrahend]
           (del (get scopy key)))
      (return scopy))

)
