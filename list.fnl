(lambda head [tbl]
  (?. tbl 1))

(lambda tail [tbl]
  (. tbl (length tbl)))

(lambda nth [n tbl]
  (?. tbl n))

(fn inc-last! [arr]
  (let [len (length arr)
        last (. arr len)]
    (set (. arr len) (+ 1 last))))

(fn remove-last! [arr]
  (let [len (length arr)]
    (set (. arr len) nil)))

(lambda mapv [func arr]
  (icollect [i v (ipairs arr)]
    (func v i)))

(lambda mapv-many [f coll]
  (let [result []]
    (each [i v (ipairs coll)]
      (each [_ inner (ipairs (f v i))]
        (table.insert result inner)))
    result))

(lambda filter [func arr]
  (icollect [i v (ipairs arr)]
    (if (func v i)
      v)))

(lambda remove-at-idx [idx arr]
  (icollect [i v (ipairs arr)]
    (if (~= i idx)
      v)))

(lambda reduce [init f arr]
  (accumulate
    [agg init
     i v (ipairs arr)]
    (f agg v i)))

(lambda combine [...]
  (let [result []]
    (each [_ tbl (ipairs [...])]
      (each [_ v (ipairs tbl)]
        (table.insert result v)))
    result))

(lambda partition [size items]
  (accumulate
    [parts []
     i v (ipairs items)]
    (do
      (if (= 1 (% i size))
        (table.insert parts [v])
        (table.insert (tail parts) v))
      parts)))

(lambda reverse [arr]
  (accumulate
    [result []
     _ v (ipairs arr)]
    (do
      (table.insert result 1 v)
      result)))

(lambda any? [func arr]
  (accumulate
    [result false
     _ v (ipairs arr)
     &until result]
    (or result (func v))))

(lambda every? [func arr]
  (accumulate
    [result true
     _ v (ipairs arr)
     &until (not result)]
    (and result (func v))))

(lambda first [func arr]
  (accumulate
    [result nil
     i v (ipairs arr)
     &until result]
    (if (func v i)
      v
      nil)))

(lambda first-index [func arr]
  (accumulate
    [result nil
     i v (ipairs arr)
     &until result]
    (if (func v i)
      i
      nil)))

(lambda couples [arr]
  (assert (<= 2 (length arr)))
  (var i 1)
  (let [result []
        get #(. arr $)
        add #(table.insert result $)]
    (while (<= (+ 1 i) (length arr))
      (add [(get i) (get (+ 1 i))])
      (set i (+ 1 i)))
    result))

{
 : head
 : tail
 : nth
 : inc-last!
 : remove-last!
 : mapv
 : mapv-many
 : filter
 : remove-at-idx
 : reduce
 : combine
 : partition
 : reverse
 : any?
 : every?
 : first
 : first-index
 : couples
 }
