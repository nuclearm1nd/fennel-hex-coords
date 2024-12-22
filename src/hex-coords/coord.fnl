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

(local idiv
  #(math.floor (/ $1 $2)))

(lambda to-axial [[x y] ?origin]
  (let [[x0 y0] (or ?origin [0 0])
        q (- x x0)]
    (new
      [q
       (-> y (- y0) (+ (idiv q 2)))])))

(lambda to-oddq [[q r] ?origin]
  (let [[q0 r0] (or ?origin [0 0])
        x (- q q0)]
    (new
      [x
       (- r r0 (idiv x 2))])))

(lambda to-new-origin [[q r] [qo ro]]
  (new
    [(- q qo)
     (- r ro)]))

(lambda symmetric [[q r] ?origin]
  (if (not ?origin)
    (new [(- q) (- r)])
    (let [[qo ro] ?origin]
      (-> [q r]
          (to-new-origin [qo ro])
          symmetric
          (to-new-origin [(- qo) (- ro)])))))

(lambda distance [[q0 r0] ?crd1]
  (let [[q1 r1] (or ?crd1 [0 0])
        q (- q0 q1)
        r (- r0 r1)]
    (idiv (+ (math.abs q)
             (math.abs r)
             (math.abs (- q r)))
          2)))

{
 : new
 : to-axial
 : to-oddq
 : to-new-origin
 : symmetric
 : distance
 }
