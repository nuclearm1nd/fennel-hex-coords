(local
  {: tget
   } (require :generic.obj))

(local
  {: inc-last!
   : remove-last!
   } (require :generic.list))

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
  (fn [tbl]
    (let [(iterator t0 control-var) (inner-iter tbl)
          new-iterator
            (fn [t k]
              (let [(nk nv) (iterator t k)]
                (if (= nil nv)
                  nil
                  (values nk (f nv nk)))))]
      (values new-iterator t0 control-var))))

{: isubseqs
 : idepth-first
 : map
 }
