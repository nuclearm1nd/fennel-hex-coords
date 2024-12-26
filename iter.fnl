(local
  {: tget
   } (require :generic.obj))

(fn inc-last! [arr]
  (let [len (length arr)
        last (. arr len)]
    (set (. arr len) (+ 1 last))))

(fn remove-last! [arr]
  (let [len (length arr)]
    (set (. arr len) nil)))

(fn isubseqs-iter [tbl sub-tbl]
  (let [i (length sub-tbl)]
    (if (= i (length tbl))
      nil
      (do
        (table.insert sub-tbl (. tbl (+ 1 i)))
        sub-tbl))))

(fn idepth-first-iter [tbl indices]
  (var result nil)
  (while (and (= nil result)
              (< 0 (length indices)))
    (inc-last! indices)
    (let [item (tget tbl indices)]
      (if
        (= nil item)
          (remove-last! indices)
        (= :table (type item))
          (table.insert indices 0)
        (set result item))))
  (if (= nil result)
    nil
    (values indices result)))

(lambda isubseqs [tbl]
  (values isubseqs-iter tbl []))

(lambda idepth-first [tbl]
  (values idepth-first-iter tbl [0]))

(lambda map [f inner-iter]
  (fn [...]
    (let [(iterator t0 control-var) (inner-iter ...)
          new-iterator
            (fn [t k]
              (let [(nk nv) (iterator t k)]
                (if (or (= nil nk) (= nil nv))
                  nil
                  (values nk (f nv nk)))))]
      (values new-iterator t0 control-var))))

(lambda filter [f inner-iter]
  (fn [...]
    (let
      [(iterator t0 control-var) (inner-iter ...)
       new-iterator
         (fn new-iter [t k]
           (let [(nk nv) (iterator t k)]
             (if
               (or (= nil nk) (= nil nv))
                 nil
               (f nv nk)
                 (values nk nv)
               (tail! (new-iter t nk)))))]
      (values new-iterator t0 control-var))))

(lambda range-iter [[start end step] x]
  (if
    (= step 0)
      (when (~= start end) x)
    (let [x1 (+ x step)]
      (if (or (and (< 0 step) (<= x1 end))
              (and (> 0 step) (>= x1 end)))
        (values x1 x1)
        nil))))

(lambda range [...]
  (let
    [(start end step)
       (case (values (select :# ...) ...)
         (0) (values 1 (/ 1 0) 1)
         (1 ?end) (values 1 ?end 1)
         (2 ?start ?end) (values ?start ?end 1)
         _ ...)]
    (values
      range-iter
      [start end step]
      (- start step))))

(lambda take [n inner-iter]
  (fn [...]
    (let
      [(iterator t0 control-var) (inner-iter ...)
       new-control-var [0 control-var]
       new-iterator
         (fn [t [i k]]
           (let [i1 (+ i 1)]
             (if (< n i1)
               nil
               (let [(nk nv) (iterator t k)]
                 (if (or (= nil nk) (= nil nv))
                   nil
                   (values [i1 nk] nv))))))]
      (values new-iterator t0 new-control-var))))

(lambda drop [n inner-iter]
  (fn [...]
    (let
      [(iterator t0 control-var) (inner-iter ...)
       new-control-var [0 control-var]
       new-iterator
         (fn new-iter [t [i k]]
           (let [(nk nv) (iterator t k)]
             (if
               (or (= nil nk) (= nil nv))
                 nil
               (<= n i)
                 (values [(+ 1 i) nk] nv)
               (tail! (new-iter t [(+ 1 i) nk])))))]
      (values new-iterator t0 new-control-var))))

(lambda take-while [f inner-iter]
  (fn [...]
    (let
      [(iterator t0 control-var) (inner-iter ...)
       new-iterator
         (fn [t k]
           (let [(nk nv) (iterator t k)]
             (if
               (or (= nil nk) (= nil nv))
                 nil
               (f nv nk)
                 (values nk nv)
               nil)))]
      (values new-iterator t0 control-var))))

{: isubseqs
 : idepth-first
 : map
 : filter
 : range
 : take
 : drop
 : take-while
 }
