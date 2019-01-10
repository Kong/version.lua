local version = require("version")
local range = version.range
local set = version.set

local ok, err
------------------------------------------
-- strict and relaxed parsing
------------------------------------------
local lua
lua, err = version("Lua 5.3")
assert(tostring(lua) == "5.3")

lua, err = version.strict("Lua 5.3")
print(lua, err)
assert(lua == nil)
assert(err == "Not a valid version element: 'Lua 5.3'")

------------------------------------------
-- Version object
------------------------------------------
assert(tostring(version("1.0")) == "1.0")
assert(tostring(version("text 1.0")) == "1.0")
assert(tostring(version("1.0 text")) == "1.0")
assert(tostring(version("1.0 text 2.0")) == "1.0")
assert(tostring(version("1.")) == "1")
assert(tostring(version("1..2")) == "nil")
assert(tostring(version("1.x")) == "1")
assert(tostring(version("x.1")) == "1")

assert(tostring(version.strict("1.0")) == "1.0")
assert(tostring(version.strict("text 1.0")) == "nil")
assert(tostring(version.strict("1.0 text")) == "nil")
assert(tostring(version.strict("1.0 text 2.0")) == "nil")
assert(tostring(version.strict("1.")) == "nil")
assert(tostring(version.strict("1..2")) == "nil")
assert(tostring(version.strict("1.x")) == "nil")
assert(tostring(version.strict("x.1")) == "nil")

local v1 = version("0")
assert(v1[1] == 0)
assert(v1[2] == nil)
assert(tostring(v1) == "0")

local v2 = version("3.4.8.10022")
assert(v2[1] == 3)
assert(v2[2] == 4)
assert(v2[3] == 8)
assert(v2[4] == 10022)
assert(v2[5] == nil)
assert(tostring(v2) == "3.4.8.10022")

local v3 = version("1.2")
assert(v3[1] == 1)
assert(v3[2] == 2)
assert(v3[3] == nil)

local v4 = version("1.2.0")
assert(v4[1] == 1)
assert(v4[2] == 2)
assert(v4[3] == 0)
assert(v4[4] == nil)

assert(v1 < v2)
assert(v2 > v3)
assert(v3 > v1)
assert(v4 == v3)

assert(version("0.4") < version("4.0"))

ok, err = pcall(function() return version("0.4") > {} end)
assert(ok == false)
print(err)
assert(err:find("cannot compare a 'version' to a 'table'", 1, true) or  -- Lua 5.2+
       err:find("attempt to compare two table values", 1, true))        -- Lua 5.1

local sv1 = version("1.2.0.3")  -- too many elements
ok, err = sv1:semver("1.2.2")
print(ok, err)
assert(not ok)
assert(err == "Version has too many elements (semver max 3)")

local sv2 = version("0.2.0")    -- major == 0
assert(sv2:semver("0.2.0"))
assert(not sv2:semver("0.2.1"))

local sv3 = version("1.2.3")
assert(not sv3:semver("0.2.3"))
assert(not sv3:semver("1.1.3"))
assert(not sv3:semver("1.2.2"))
assert(sv3:semver("1.2.3"))
assert(sv3:semver("1.2.4"))
assert(sv3:semver("1.3.3"))
assert(sv3:semver("1.99999"))
assert(not sv3:semver("2"))


------------------------------------------
-- Range object
------------------------------------------
local r1
r1, err = range("1.2", "xxx")
print(r1, err)
assert(r1 == nil)
assert(err == "Not a valid version element: 'xxx'")

r1, err = range("xxx", "1.2")
print(r1, err)
assert(r1 == nil)
assert(err == "Not a valid version element: 'xxx'")

r1, err = range("1.4", "1.2")
print(r1, err)
assert(r1 == nil)
assert(err == "FROM version must be less than or equal to the TO version")

r1 = range("1.2", "1.4.0")
local r
r, err = r1:matches("xxx")
print(r, err)
assert(r == nil)
assert(err == "Not a valid version element: 'xxx'")

assert(r1:matches("1.2"))
assert(r1:matches("1.2.0"))
assert(r1:matches("1.3"))
assert(r1:matches("1.4"))
assert(r1:matches("1.4.0"))
assert(not r1:matches("1.4.1"))
assert(not r1:matches("0.4.0"))
assert(not r1:matches("1.5"))
assert(not r1:matches("0.5"))
assert(tostring(r1) == "1.2 to 1.4.0")

------------------------------------------
-- Set object
------------------------------------------
local s1
s1, err = set("xxx")
print(s1, err)
assert(s1 == nil)
assert(err == "Not a valid version element: 'xxx'")

s1, err = set(range("xxx"))
print(s1, err)
assert(s1 == nil)
assert(err == "Not a valid version element: 'Not a valid version element: 'xxx''")

s1, err = set(range("1.2", "xxx"))
print(s1, err)
assert(s1 == nil)
assert(err == "Not a valid version element: 'Not a valid version element: 'xxx''")

s1 = set("1.2.0", "2.4.3"):allowed("3.5", "3.9.9"):allowed("5.0"):disallowed("1.3", "1.4"):disallowed("3.6"):disallowed("3.9.8")
ok, err = s1:matches("xxx")
print(ok, err)
assert(ok == nil)
assert(err == "Not a valid version element: 'xxx'")

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
assert(tostring(s1) == "1.2.0 to 2.4.3, 3.5 to 3.9.9, and 5.0, but not 1.3 to 1.4, 3.6, and 3.9.8")

local s2 = set("1.2.0")
assert(tostring(s2) == "1.2.0")
s2:disallowed("9.9")
assert(tostring(s2) == "1.2.0, but not 9.9")

local s3 = set("1.2.0", "2.4.3")
assert(tostring(s3) == "1.2.0 to 2.4.3")
s3:allowed(range("2.5","4"))
s3:disallowed(range("3.0", "3.9"))
print(tostring(s3))
assert(tostring(s3) == "1.2.0 to 2.4.3, and 2.5 to 4, but not 3.0 to 3.9")

r = range("1.0", "1.3")
ok, err = pcall(function() s3:allowed(r, "1.4") end)
assert(ok == false)
assert(err:find("First parameter was a range, second must be nil.", 1, true))

r = range("1.0", "1.3")
ok, err = pcall(function() s3:disallowed(r, "1.3") end)
assert(ok == false)
assert(err:find("First parameter was a range, second must be nil.", 1, true))


print ("All tests successful")
