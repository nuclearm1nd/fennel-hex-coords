(lambda draw-random [t]
  (. t (math.random (length t))))

(lambda round [x]
  (let [fl (math.floor x)
        cl (math.ceil x)]
    (if (< (math.abs (- x fl))
           (math.abs (- x cl)))
      fl
      cl)))

(lambda div [x y]
  (-> x
      (- (math.fmod x y))
      (/ y)))

(lambda sign [x]
  (if (= 0 x) 0
      (> 0 x) -1
      1))

(lambda idiv [x y]
  (math.floor (/ x y)))

{: draw-random
 : round
 : div
 : sign
 : idiv
 }
