(import-macros
  {: test
   : to-test-pairs
   } :util)

(local lu (require :luaunit))

(local
  {: new
   : to-axial
   : to-oddq
   : to-new-origin
   : symmetric
   : distance
   } (require :hex-coords.coord))

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

(test ToAxial
  (to-test-pairs lu.assertEquals
    (to-axial [0 0])
    (new [0 0])

    (to-axial [1 1])
    (new [1 1])

    (to-axial [2 1])
    (new [2 2])

    (to-axial [3 1])
    (new [3 2])

    (to-axial [10 5])
    (new [10 10])

    (to-axial [4 4])
    (new [4 6])

    (to-axial [8 3])
    (new [8 7])

    (to-axial [4 2] [4 2])
    (new [0 0])

    (to-axial [8 7] [4 2])
    (new [4 7])

    (to-axial [2 3] [4 2])
    (new [-2 0])
))

(test ToOddq
  (to-test-pairs lu.assertEquals
    (to-oddq [0 0])
    (new [0 0])

    (to-oddq [1 1])
    (new [1 1])

    (to-oddq [2 2])
    (new [2 1])

    (to-oddq [3 2])
    (new [3 1])

    (to-oddq [10 10])
    (new [10 5])

    (to-oddq [4 6])
    (new [4 4])

    (to-oddq [8 7])
    (new [8 3])

    (to-oddq [-4 -4] [-4 -4])
    (new [0 0])

    (to-oddq [4 7] [-4 -4])
    (new [8 7])

    (to-oddq [-2 0] [-4 -4])
    (new [2 3])
))

(test ToNewOrigin
  (to-test-pairs lu.assertEquals
    (to-new-origin [2 0] [3 2])
    (new [-1 -2])

    (to-new-origin [4 4] [3 2])
    (new [1 2])

    (to-new-origin [0 0] [3 2])
    (new [-3 -2])
))

(test Symmetric
  (to-test-pairs lu.assertEquals
    (symmetric [-2 -3])
    (new [2 3])

    (symmetric [2 0] [3 2])
    (new [4 4])

    (symmetric [4 1] [3 2])
    (new [2 3])

    (symmetric [0 -1] [0.5 0.5])
    (new [1 2])

    (symmetric [-1 -2] [0.5 0.5])
    (new [2 3])

    (symmetric [3 2] [2.5 3.5])
    (new [2 5])
))

(test Distance
  (to-test-pairs lu.assertEquals
    (distance [0 0] [0 0])
    0

    (distance [2 5] [2 5])
    0

    (distance [2 3] [3 0])
    4

    (distance [-1 1] [1 -1])
    4

    (distance [1 2] [2 1])
    2
))
