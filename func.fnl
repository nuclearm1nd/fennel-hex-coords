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

{: negate
 : f-or
 : f-and
 }
