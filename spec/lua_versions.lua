local set = require("version").set

-- define something compatible with Lua 5.1 through 5.3
-- NOTE: disallowed versions/ranges override allowed versions/ranges
local compatible = set("5.1","5.4"):disallowed("5.4")

local lua = { 
  "5.1", "5.1.0", "5.1.1", "5.1.2", "5.1.3", "5.1.4", "5.1.5",
  "5.2", "5.2.0", "5.2.1", "5.2.2", "5.2.3", "5.2.4",
  "5.3", "5.3.0", "5.3.1", "5.3.2",
}

local not_lua = {
  "5.0", "5.0.0", "5.0.1", "5.0.2", "5.0.3",
  "5.4", "5.5",
  "6", "6.0"
}

local str = tostring(compatible)

for _, v in ipairs(lua) do
  assert(compatible:matches(v))
end
for _, v in ipairs(not_lua) do
  assert(not compatible:matches(v))
end

print("Success!")
