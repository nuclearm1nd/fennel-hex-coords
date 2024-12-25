;; fennel-ls: macro-file

(local upack (or unpack table.unpack))

(local
  {: tget
   } (require :generic.obj))

(local
  {: inc-last!
   : remove-last!
   : mapv
   : mapv-many
   : reverse
   : partition
   : combine
   : filter
   } (require :generic.list))

(fn itraverse-iter [tbl indices]
  (var result nil)
  (while (and (= nil result)
              (< 0 (length indices)))
    (inc-last! indices)
    (let [item (tget tbl indices)]
      (if
        (= nil item)
          (remove-last! indices)
        (list? item)
          (table.insert indices 0)
        (set result item))))
  (if (= nil result)
    nil
    (values indices result)))

(lambda itraverse [tbl]
  (assert (list? tbl)
    "code list should be the argument to this iterator")
  (values itraverse-iter tbl [0]))

(lambda list-set! [lst indices ?val]
  (let [last-idx (length indices)]
    (accumulate
      [sublist lst
       idx i (ipairs indices)]
      (if (= idx last-idx)
        (tset sublist i ?val)
        (do
          (when (= nil (. sublist i))
            (tset sublist i (list)))
          (. sublist i))))
    lst))

(lambda in? [v ...]
  (let [vals [...]]
   `(let [val# ,v]
      (or
       ,(upack
          (mapv (fn [x] `(= val# ,x)) vals))))))

(lambda <<- [...]
  (let [vals [...]]
   `(->> ,(upack (reverse vals)))))

(lambda code-traverse [f]
  (fn [exprn]
    (if (not (list? exprn))
      (f exprn)
      (accumulate
        [result (list)
         indices v (itraverse exprn)]
        (list-set! result indices (f v))))))

(lambda as-> [name init ...]
  (var cur-gensym (gensym))
  (let [result [cur-gensym init]
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ expr (ipairs [...])]
      (let [new-gensym (gensym)]
        (table.insert result new-gensym)
        (table.insert result (swapper expr))
        (set cur-gensym new-gensym)))
    `(let ,result ,cur-gensym)))

(lambda cond-> [name init ...]
  (assert-compile
    (-> [...] length (% 2) (= 0))
    "Even number of forms expected")
  (var cur-gensym (gensym))
  (let [lets [cur-gensym init]
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ [cond expr] (ipairs (partition 2 [...]))]
      (let [new-gensym (gensym)]
        (table.insert lets new-gensym)
        (table.insert lets `(if ,(swapper cond)
                                ,(swapper expr)
                                ,cur-gensym))
        (set cur-gensym new-gensym)))
    `(let ,lets ,cur-gensym)))

(lambda array-> [name init ...]
  (var cur-gensym (gensym))
  (let [lets [cur-gensym init]
        array []
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ expr (ipairs [...])]
      (let [new-gensym (gensym)]
        (table.insert lets new-gensym)
        (table.insert lets (swapper expr))
        (table.insert array new-gensym)
        (set cur-gensym new-gensym)))
    `(let ,lets ,array)))

(lambda if-not [...]
  (assert-compile (< 1 (length [...]))
    "At least two forms expected")
  `(if
    ,(->> [...]
          (partition 2)
          (mapv-many
            (fn [[A B]]
               (if (= nil B)
                 [`,A]
                 [`(not ,A) `,B])))
          upack)))

(lambda early [cond res]
  (let [g (gensym)]
    `(when ,cond
       (let [,g ,res]
         (lua ,(.. "return " (tostring g)))))))

(lambda condlet [clauses ...]
  (let
    [nil-clause
      (fn [clause ?exclude]
        (let
          [exclude (or ?exclude [])
           to-exclude
             (accumulate
               [res {}
                _ name (ipairs exclude)]
               (do
                 (tset res (tostring name) true)
                 res))]
          (->> clause
               (partition 2)
               (filter
                 (fn [[A _]]
                   (= nil (. to-exclude (tostring A)))))
               (mapv-many
                 (fn [[A _]]
                   [`,A `nil])))))]
    (accumulate
      [result ...
       _ [condition t-clause ?f-clause] (ipairs (reverse clauses))]
      (if (= nil ?f-clause)
        `(if ,condition
           (let ,t-clause ,result)
           (let ,(nil-clause t-clause) ,result))
        `(if ,condition
           (let ,(combine t-clause  (nil-clause ?f-clause t-clause)) ,result)
           (let ,(combine ?f-clause (nil-clause t-clause ?f-clause)) ,result))))))

{: in?
 : <<-
 : as->
 : cond->
 : array->
 : if-not
 : early
 : condlet
 }
