;; fennel-ls: macro-file

(fn test [name ...]
  (let [upack (or unpack table.unpack)]
   `(global ,(->>
               (. name 1)
               (.. "test")
               sym)
      (fn []
        ,(upack [...])))))

(fn to-test-pairs [test-fn ...]
  (var tmp nil)
  (let [upack (or unpack table.unpack)
        result []]
    (each [i m (ipairs [...])]
      (if (= 1 (% i 2))
          (set tmp `(,test-fn ,m))
          (do
            (table.insert tmp m)
            (table.insert result tmp))))
    `(do ,(upack result))))

{: test
 : to-test-pairs}

