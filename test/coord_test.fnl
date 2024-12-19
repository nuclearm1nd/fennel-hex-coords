(import-macros
  {: test
   : to-test-pairs
   } :util)

(local lu (require :luaunit))

(local
  {: new
   } (require :hex-coord.coord))

(test NewValidation
  (lu.assertError #(new 0))

  (lu.assertError #(new :a 1))

  (lu.assertError #(new 2 :b))

  (lu.assertError #(new [1 2] 3))

  (lu.assertError #(new [1 2 3]))
)

(test ImmutableValidation
  (lu.assertError
    #(let [crd (new 1 1)]
       (tset crd 1 0)))

  (lu.assertError
    #(let [crd (new 1 1)]
       (tset crd 3 5)))
)

(test New
  (to-test-pairs lu.assertEquals
    (= (new 2 3)
       (new 2 3))
    true

    (= (new [2 3])
       (new 2 3))
    true

    (= (new [3 4])
       (new [3 4]))
    true

    (= (new 3 2)
       (new 2 3))
    false

    (= (new 3 2)
       (new [2 3]))
    false

    (= (new [3 2])
       (new [2 3]))
    false
))

(test FieldAccess
  (to-test-pairs lu.assertEquals
    (-> [5 7]
        new
        (. 1))
    5

    (-> [5 7]
        new
        (. 2))
    7

    (-> [5 7]
        new
        (. 3))
    nil

    (let [[q _r] (new 2 4)]
      q)
    2

    (let [[_q r] (new 2 4)]
      r)
    4

    (let [crd (new 2 4)
          f (fn [[q r]] (+ q r))]
      (f crd))
    6
))

