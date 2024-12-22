(lambda tget [tbl indices]
  (accumulate
    [res tbl
     _ i (ipairs indices)
     &until (or (= res nil)
                (~= :table (type res)))]
    (. res i)))

(lambda merge [...]
  (let [result {}]
    (each [_ tbl (ipairs [...])]
      (each [k v (pairs tbl)]
        (tset result k v)))
    result))

(lambda merge! [t ...]
  (each [_ tbl (ipairs [...])]
    (each [k v (pairs tbl)]
      (tset t k v)))
  t)

(lambda keys [tbl]
  (icollect [key _ (pairs tbl)]
    key))

(lambda vals [tbl]
  (icollect [_ value (pairs tbl)]
    value))

(lambda every-key? [f tbl]
  (accumulate
    [result true
     k _ (pairs tbl)
     &until (not result)]
    (and result (f k))))

{: tget
 : merge
 : merge!
 : keys
 : vals
 : every-key?
 }
