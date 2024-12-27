(local
  {: flatten
   } (require :generic.list))

(lambda negate [f]
  (lambda [...]
    (not (f ...))))

(lambda f-or [...]
  (let [fns (flatten [...])]
    (lambda [...]
      (accumulate
        [res false
         _ f (ipairs fns)
         &until res]
        (or res (f ...))))))

(lambda f-and [...]
  (let [fns (flatten [...])]
    (lambda [...]
      (accumulate
        [res true
         _ f (ipairs fns)
         &until (not res)]
        (and res (f ...))))))

(lambda compose [...]
  (let
    [fns (flatten [...])
     len (length fns)
     result
       (fn inner [i ...]
         (if (< len i)
           ...
           (tail!
             (inner
               (+ 1 i)
               ((. fns i) ...)))))]
    (lambda [...]
      (result 1 ...))))

(lambda iterate [n f]
  (let
    [result
       (fn inner [i ...]
         (if (< n i)
           ...
           (tail!
             (inner
               (+ 1 i)
               (f ...)))))]
    (lambda [...]
      (result 1 ...))))

{: negate
 : f-or
 : f-and
 : compose
 : iterate
 }
