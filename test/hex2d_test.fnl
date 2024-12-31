(import-macros
  {: test
   : to-test-pairs
   } :util)

(local lu (require :luaunit))

(local
  {:map mapv
   } (require :generic.list))

(local Set (require :generic.set))

(local
  {: new
   : is-crd?
   : coalesce
   : to-axial
   : to-oddq
   : to-new-origin
   : symmetric
   : distance
   : neighbors
   : zone
   : belt
   : collection-neighbors
   : line-distance
   : line-constraint
   : line-area
   : line-area-border
   : connecting-line
   : constraint-difference
   } (require :maps.hex2d))

(lambda to-string-array [t]
  (if (Set.is-set? t)
    (icollect [item (t:iterator)]
      (tostring item))
    (mapv #(-> $1 coalesce tostring) t)))

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

(test ToString
  (to-test-pairs lu.assertEquals
    (tostring (new [1 2]))
    "[1;2]"

    (tostring (new [-1 3]))
    "[-1;3]"
))

(test IsCrd
  (to-test-pairs lu.assertEquals
    (is-crd? 1)
    false

    (is-crd? :a)
    false

    (is-crd? [1 2])
    false

    (is-crd? (new 1 2))
    true
))

(test Coalesce
  (to-test-pairs lu.assertEquals
    (coalesce [5 10])
    (new 5 10)

    (coalesce (new 15 20))
    (new [15 20])
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

(test Neighbors
  (to-test-pairs lu.assertItemsEquals
    (to-string-array
      (neighbors [1 2] 0))
    []

    (to-string-array
      (neighbors [1 2]))
    (to-string-array
      [[0 1] [1 1] [0 2] [2 2] [1 3] [2 3]])

    (to-string-array
      (neighbors [1 2] 2))
    (to-string-array
      [[-1 0]
       [-1 1]
       [-1 2]
       [0 0]
       [0 1]
       [0 2]
       [0 3]
       [1 0]
       [1 1]
       [1 3]
       [1 4]
       [2 1]
       [2 2]
       [2 3]
       [2 4]
       [3 2]
       [3 3]
       [3 4]])
))

(test Zone
  (to-test-pairs lu.assertItemsEquals
    (to-string-array
      (zone [1 2] 0))
    (to-string-array
      [[1 2]])

    (to-string-array
      (zone [1 2]))
    (to-string-array
      [[1 2] [0 1] [1 1] [0 2] [2 2] [1 3] [2 3]])

    (to-string-array
      (zone [1 2] 2))
    (to-string-array
      [[1 2]
       [-1 0]
       [-1 1]
       [-1 2]
       [0 0]
       [0 1]
       [0 2]
       [0 3]
       [1 0]
       [1 1]
       [1 3]
       [1 4]
       [2 1]
       [2 2]
       [2 3]
       [2 4]
       [3 2]
       [3 3]
       [3 4]])
))

(test Belt
  (to-test-pairs lu.assertItemsEquals
    (to-string-array
      (belt 1 2 [1 2]))
    (to-string-array
      [[-1 0]
       [-1 1]
       [-1 2]
       [0 0]
       [1 0]
       [0 3]
       [1 4]
       [2 1]
       [2 4]
       [3 2]
       [3 3]
       [3 4]])
))

(test CollectionNeighbors
  (to-test-pairs lu.assertItemsEquals
    (to-string-array
      (collection-neighbors [[0 1] [1 2]]))
    (to-string-array
      [[0 2]
       [1 3]
       [2 3]
       [2 2]
       [1 1]
       [0 0]
       [-1 0]
       [-1 1]])
))

(test LineDistance
  (to-test-pairs lu.assertEquals
    (line-distance [:horizontal 0] [0 0])
    0

    (line-distance [:horizontal 0] [2 1])
    0

    (line-distance [:horizontal 0] [4 2])
    0

    (line-distance [:horizontal 0] [3 2])
    1

    (line-distance [:horizontal 1] [1 1])
    0

    (line-distance [:horizontal 1] [-1 0])
    0

    (line-distance [:horizontal 1] [-3 -1])
    0

    (line-distance [:horizontal 1] [0 0])
    -1

    (line-distance [:horizontal 1] [0 3])
    3

    (line-distance [:- 1] [1 3])
    2

    (line-distance [:- -3] [2 4])
    5

    (line-distance [:- 4] [-1 -2])
    -4

    (line-distance [:- 3] [4 2])
    -2

    (line-distance [:- 2] [4 2])
    -1

    (line-distance [:- -5] [4 5])
    6

    (line-distance [:vertical 0] [0 0])
    0

    (line-distance [:| 0] [0 5])
    0

    (line-distance [:| 0] [3 5])
    3

    (line-distance [:| 0] [-3 -2])
    -3

    (line-distance [:incline-right 0] [0 0])
    0

    (line-distance [:/ 0] [3 1])
    1

    (line-distance [:/ 0] [-2 1])
    1

    (line-distance [:/ 0] [-2 -3])
    -3

    (line-distance [:/ -2] [3 4])
    6

    (line-distance [:/ -2] [3 -4])
    -2

    (line-distance [:incline-left 0] [0 0])
    0

    (line-distance [:incline-left 0] [-2 0])
    -2

    (line-distance [:\ 2] [4 1])
    1
))

(test LineConstraint
  (lu.assertError #(line-constraint [:- 0] :right))
  (lu.assertError #(line-constraint [:horizontal 0] :left))

  (lu.assertError #(line-constraint [:vertical 0] :below))
  (lu.assertError #(line-constraint [:| 0] :above))

  (let [constraint (line-constraint [:- -1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [1 0])
      false

      (constraint [5 3])
      true

      (constraint [5 2])
      false))

  (let [constraint (line-constraint [:| -1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [1 0])
      true

      (constraint [-2 3])
      false

      (constraint [-1 -5])
      false))

  (let [constraint (line-constraint [:/ 1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [1 0])
      false

      (constraint [-2 3])
      true

      (constraint [-4 1])
      false))

  (let [constraint (line-constraint [:/ 1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [1 0])
      false

      (constraint [-2 3])
      true

      (constraint [-4 1])
      false))

  (let [constraint (line-constraint [:\ 1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [4 2])
      true

      (constraint [4 3])
      false))

  (let [constraint (line-constraint [:\ 1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [4 2])
      false

      (constraint [4 3])
      false

      (constraint [4 4])
      true
      ))
)

(test AreaContraint
  (let [constraint
          (line-area
            [:+ :-  0
             :- :- 11
             :+ :|  0
             :- :|  6 ])]
    (to-test-pairs lu.assertEquals
      (constraint [1 1])
      true

      (constraint [5 3])
      true

      (constraint [5 7])
      true

      (constraint [1 5])
      true

      (constraint [0 1])
      false

      (constraint [6 3])
      false

      (constraint [5 8])
      false

      (constraint [1 6])
      false)
))

(test LineAreaBorderContraint
  (let [constraint
          (line-area-border
            [:+ :-  0
             :- :- 11
             :+ :|  0
             :- :|  6])]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [0 1])
      true

      (constraint [1 0])
      false

      (constraint [4 2])
      true

      (constraint [1 1])
      false

      (constraint [6 3])
      true

      (constraint [5 8])
      true

      (constraint [1 6])
      true
)))

(test ConnectingLine
  (to-test-pairs lu.assertItemsEquals
    (to-string-array
      (connecting-line
        [0 0] [0 0]))
    (to-string-array
      [[0 0]])

    (to-string-array
      (connecting-line
        [0 0] [1 1]))
    (to-string-array
      [[0 0] [1 1]])

    (to-string-array
      (connecting-line
        [27 21] [29 22]))
    (to-string-array
      [[27 21] [28 22] [29 22]])

    (to-string-array
      (connecting-line
        [0 0] [1 2]))
    (to-string-array
      [[0 0] [1 1] [1 2]])

    (to-string-array
      (connecting-line
        [0 0] [6 4]))
    (to-string-array
      [[0 0] [1 1] [2 1] [3 2] [4 3] [5 3] [6 4]])

    (to-string-array
      (connecting-line
        [0 0] [-4 -3]))
    (to-string-array
      [[0 0] [-1 -1] [-2 -1] [-3 -2] [-4 -3]])

    (to-string-array
      (connecting-line
        [-1 -3] [1 4]))
    (to-string-array
      [[-1 -3] [-1 -2] [0 -1] [0 0] [0 1] [0 2] [1 3] [1 4]])
))

(test ConstraintDifference
  (let [area1
         (line-area
           [:+ :-  0
            :- :- 11
            :+ :|  0
            :- :|  6 ])
        area2
         (line-area
           [:+ :-  3
            :- :- 11
            :+ :|  3
            :- :|  6 ])
        constraint (constraint-difference area1 area2)]
    (to-test-pairs lu.assertEquals
      (constraint [1 1])
      true

      (constraint [5 3])
      true

      (constraint [5 7])
      false

      (constraint [1 5])
      true

      (constraint [0 1])
      false

      (constraint [4 3])
      true

      (constraint [5 5])
      false

      (constraint [1 5])
      true
)))
