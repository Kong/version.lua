local version = require("version").version
local range = require("version").range
local set = require("version").set

v1 = version("0")
assert (v1[1] == 0)
assert (v1[2] == nil)

v2 = version("3.4.8.10022")
assert (v2[1] == 3)
assert (v2[2] == 4)
assert (v2[3] == 8)
assert (v2[4] == 10022)
assert (v2[5] == nil)

v3 = version("1.2")
assert (v3[1] == 1)
assert (v3[2] == 2)
assert (v3[3] == nil)

v4 = version("1.2.0")
assert (v4[1] == 1)
assert (v4[2] == 2)
assert (v4[3] == 0)
assert (v4[4] == nil)

assert(v1 < v2)
assert(v2 > v3)
assert(v3 > v1)
assert(v4 == v3)

assert(version("0.4") < version("4.0"))

r1 = range("1.2", "1.4")
assert(r1:matches("1.2"))
assert(r1:matches("1.2.0"))
assert(r1:matches("1.3"))
assert(r1:matches("1.4"))
assert(r1:matches("1.4.0"))
assert(not r1:matches("1.4.1"))
assert(not r1:matches("0.4.0"))
assert(not r1:matches("1.5"))
assert(not r1:matches("0.5"))

s1 = set():allowed("1.2.0", "2.4.3"):allowed("3.5", "3.9.9"):allowed("5.0"):disallowed("1.3", "1.4"):disallowed("3.6")
assert(not s1:matches("0.1"))
assert(s1:matches("1.2.0"))
assert(s1:matches("2"))
assert(s1:matches("2.4.3"))
assert(not s1:matches("3.0"))
assert(s1:matches("3.5"))
assert(s1:matches("3.9"))
assert(not s1:matches("4.0"))
assert(s1:matches("5.0"))
assert(not s1:matches("1.3"))
assert(not s1:matches("1.3.5"))
assert(not s1:matches("1.4"))
assert(not s1:matches("3.6"))

print ("All tests successful")
