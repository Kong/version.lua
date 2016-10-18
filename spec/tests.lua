local v = require("version")
local version = v.version
local range = v.range
local set = v.set

v.strict = false
local lua = version("Lua 5.3")
assert(tostring(lua) == "5.3")

v.strict = true
local success, lua = pcall(version, "Lua 5.3")
assert(success == false)

v1 = version("0")
assert(v1[1] == 0)
assert(v1[2] == nil)
assert(tostring(v1) == "0") 

v2 = version("3.4.8.10022")
assert(v2[1] == 3)
assert(v2[2] == 4)
assert(v2[3] == 8)
assert(v2[4] == 10022)
assert(v2[5] == nil)
assert(tostring(v2) == "3.4.8.10022") 

v3 = version("1.2")
assert(v3[1] == 1)
assert(v3[2] == 2)
assert(v3[3] == nil)

v4 = version("1.2.0")
assert(v4[1] == 1)
assert(v4[2] == 2)
assert(v4[3] == 0)
assert(v4[4] == nil)

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
assert(tostring(r1) == "1.2 to 1.4") 

s1 = set("1.2.0", "2.4.3"):allowed("3.5", "3.9.9"):allowed("5.0"):disallowed("1.3", "1.4"):disallowed("3.6")
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
assert(tostring(s1) == "1.2.0 to 2.4.3, 3.5 to 3.9.9 and 5.0, but not 1.3 to 1.4 and 3.6") 

s2 = set("1.2.0")
assert(tostring(s2) == "1.2.0")
s2:disallowed("9.9")
assert(tostring(s2) == "1.2.0, but not 9.9")

s3 = set("1.2.0", "2.4.3")
assert(tostring(s3) == "1.2.0 to 2.4.3")

print ("All tests successful")
