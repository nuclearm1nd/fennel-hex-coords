(local coord-index {})
(local coord-proxy {})

(local coord-meta
  {:__index
     (fn [t k]
       (-?> coord-proxy
            (. t)
            (. k)))
   :__newindex
     (fn []
       (error "attempt to update a coordinate" 2))})

(lambda get-or-add! [q r]
  (if (not (. coord-index q))
    (tset coord-index q {}))
  (let [inner (. coord-index q)
        crd (. inner r)]
    (if (~= nil crd)
      crd
      (let [proxy [q r]
            new-crd {}]
        (tset inner r new-crd)
        (tset coord-proxy new-crd proxy)
        (setmetatable new-crd coord-meta)
        new-crd))))

(lambda new [t ?r]
  (let [T (type t)]
    (case T
      :table
        (if (~= nil ?r)
          (error "too many arguments to new coordinate")
          (do
            (assert (= 2 (length t))
              "too many arguments to new coordinate")
            (get-or-add! (. t 1) (. t 2))))
      :number
        (do
          (assert (and (~= nil ?r)
                       (= :number (type ?r)))
            "expected a number in second position")
          (get-or-add! t ?r))
      _ (error ("Bad arguments to new coordinate")))))

{: new}
