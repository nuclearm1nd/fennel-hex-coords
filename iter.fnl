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

(fn itraverse-iter [tbl indices]
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

(lambda imap-iter [f]
  (fn [tbl idx]
    (let [next-idx (+ idx 1)
          next-item (. tbl next-idx)]
      (if next-item
        (values next-idx (f next-item next-idx))
        nil))))

(lambda isubseqs [tbl]
  (values isubseqs-iter tbl []))

(lambda itraverse [tbl]
  (values itraverse-iter tbl [0]))

(lambda imap [f tbl]
  (values (imap-iter f) tbl 0))

{: isubseqs
 : itraverse
 : imap
 }
