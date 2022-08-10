(import oreo [ls])
(print (ls "cookies" :key (fn [item] (if (.isnumeric item) (int item) -1))))
