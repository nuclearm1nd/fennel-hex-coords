(local lu (require :luaunit))

(local Hex2dTest (require :test.hex2d_test))

(os.exit
  (do
    (print _VERSION)
    (print "Running tests")
    (lu.LuaUnit.run)))

