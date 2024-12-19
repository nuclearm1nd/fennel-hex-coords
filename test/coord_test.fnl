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
