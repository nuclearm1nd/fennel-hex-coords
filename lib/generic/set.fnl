(local set-meta {})

(lambda assert-is-table [tbl]
  (assert (= :table (type tbl))
    (.. "Argument should be a table: " (tostring tbl))))

(lambda assert-is-set [tbl]
  (assert-is-table tbl)
  (let [meta (getmetatable tbl)]
    (assert (= set-meta meta)
      (.. "Argument should be a Set: " (tostring tbl)))))

(lambda add! [{: items &as s} ...]
  (each [_ v (ipairs [...])]
    (tset items v true))
  s)

(lambda remove! [{: items &as s} ...]
  (each [_ v (ipairs [...])]
    (tset items v nil))
  s)

(lambda has? [{: items} v]
  (or (?. items v) false))

(fn next-wrapper [t k]
  (let [(nk _) (next t k)] nk))

(fn iterator [{: items}]
  (values next-wrapper items nil))

(var new nil)

(lambda to-set [?t]
  (if (= nil ?t)
    (new)
    (do
      (assert-is-table ?t)
      (let [meta (getmetatable ?t)]
        (if (= set-meta meta)
          ?t
          (let
            [result (new)]
            (each [_ v (pairs ?t)]
              (result:add! v))
            result))))))

(lambda to-array [s]
  (assert-is-set s)
  (icollect [v (s:iterator)] v))

(lambda is-set? [t]
  (if (~= :table (type t))
    false
    (= set-meta (getmetatable t))))

(lambda intersect-two! [s t]
  (assert-is-set s)
  (let [s1 (to-set t)]
    (each [v (s:iterator)]
      (if (not (s1:has? v))
        (s:remove! v))))
  s)

(lambda intersection [...]
  (accumulate
    [res (to-set)
     idx v (ipairs [...])]
    (if (= 1 idx)
      (to-set v)
      (intersect-two! res v))))

(lambda intersection! [s ...]
  (accumulate
    [res s
     _ v (ipairs [...])]
    (intersect-two! res v)))

(lambda union-two! [s t]
  (assert-is-set s)
  (assert-is-table t)
  (if (is-set? t)
    (each [v (t:iterator)]
      (s:add! v))
    (each [_ v (pairs t)]
      (s:add! v)))
  s)

(lambda union [...]
  (accumulate
    [res (to-set {})
     _ v (ipairs [...])]
    (union-two! res v)))

(lambda union! [s ...]
  (accumulate
    [res s
     _ v (ipairs [...])]
    (union-two! res v)))

(lambda difference-two! [s t]
  (assert-is-set s)
  (assert-is-table t)
  (if (is-set? t)
    (each [v (t:iterator)]
      (s:remove! v))
    (each [_ v (pairs t)]
      (s:remove! v)))
  s)

(lambda difference [...]
  (accumulate
    [res (to-set {})
     idx v (ipairs [...])]
    (if (= 1 idx)
      (to-set v)
      (difference-two! res v))))

(lambda difference! [s ...]
  (accumulate
    [res s
     _ v (ipairs [...])]
    (difference-two! res v)))

(set new
  (lambda []
    (let
      [result
       {:items {}
        : add!
        : remove!
        : has?
        : iterator
        : to-array
        : union!
        : difference!
        : intersection!}]
       (setmetatable result set-meta)
       result)))

(set
  set-meta.__le
  (lambda [s1 s2]
    (assert-is-set s1)
    (assert-is-set s2)
    (accumulate
      [res true
       v _ (s1:iterator)
       &until (not res)]
      (s2:has? v))))

(set
  set-meta.__lt
  (lambda [s1 s2]
    (and (<= s1 s2)
         (not (<= s2 s1)))))

(set
  set-meta.__eq
  (lambda [s1 s2]
    (if (not (and (is-set? s1)
                  (is-set? s2)))
      false
      (and (<= s1 s2)
           (<= s2 s1)))))

(set
  set-meta.__mul
  (lambda [s1 s2]
    (assert-is-set s1)
    (assert-is-set s2)
    (intersection s1 s2)))

(set
  set-meta.__add
  (lambda [s1 s2]
    (assert-is-set s1)
    (assert-is-set s2)
    (union s1 s2)))

(set
  set-meta.__sub
  (lambda [s1 s2]
    (assert-is-set s1)
    (assert-is-set s2)
    (difference s1 s2)))

{: new
 : to-set
 : to-array
 : is-set?
 : intersection
 : union
 : difference
 }
