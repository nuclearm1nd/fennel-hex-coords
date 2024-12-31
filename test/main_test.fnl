(local lu (require :luaunit))

(local CoordTest (require :test.coord_test))

(os.exit
  (do
    (print _VERSION)
    (print "Running tests")
    (lu.LuaUnit.run)))

