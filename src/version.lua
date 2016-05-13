---
-- Version comparison library for Lua.
-- 
-- Comparison is simple and straightforward, no interpretation is done whatsoever 
-- regarding compatibility etc. If that's what you're looking for, then please 
-- checkout the semantic versioning specification (SemVer).
--
-- @usage
-- local ver = require("version")
-- 
-- local v = ver.version("3.1.0")
-- assert( v == ver.version("3.1"))   -- missing elements default to zero, and hence are equal
-- assert( v > ver.version("3.0"))
--
-- local r = ver.range("2.75", "3.50.3")
-- assert(r:matches(v))
--
-- local compatible = version.set("1.1","1.1.999999")  -- upwards compatibility check
-- assert(compatible:matches("1.1.3"))
--
-- -- adding elements in a chained fashion
-- compatible:allowed("2.1", "2.5"):disallowed("2.3") -- 2.3 was a buggy version...
--
-- assert(compatible:matches("1.1.3"))
-- assert(compatible:matches("2.4"))
-- assert(not compatible:matches("2.0"))
-- assert(not compatible:matches("2.3"))
-- 
-- @copyright Mashape Inc.
-- @author Thijs Schreijer
-- @license Apache 2.0

local _M = {}

-- Utility split function
local function split(str, pat)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)

  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end

    last_end = e + 1
    s, e, cap = str:find(fpat, last_end)
  end

  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end

  return t
end


-- @section version

local mt_version = {
    __eq = function(a,b)
      local l = math.max(#a, #b)
      for i = 1, l do
        if (a[i] or 0) ~= (b[i] or 0) then 
          return false 
        end
      end
      return true
    end,
    __lt = function(a,b)
      local l = math.max(#a, #b)
      for i = 1, l do
        if (a[i] or 0) < (b[i] or 0) then 
          return true 
        end
        if (a[i] or 0) > (b[i] or 0) then 
          return false 
        end
      end
      return false
    end,
    __tostring = function(self)
      return table.concat(self, ".")
    end,
}

--- Creates a new version object from a string. The returned table will have
-- comparison operators, eg. LT, EQ, GT. For all comparisons, any missing numbers
-- will be assumed to be "0" on the least significant side of the version string.
-- @param v String formatted as numbers separated by dots (no limit on number of elements).
-- @return version object
_M.version = function(v)
  local t = split(v, "%.")
  for i, s in ipairs(t) do
    local n = tonumber(s)
    assert(n, "Not a valid version element; "..tostring(s))
    t[i] = n
  end
  return setmetatable(t, mt_version)
end

-- @section range

local mt_range = {
  __index = {
      --- Matches a version on a range.
      -- @name range:matches
      -- @param v Version (string or `version` object) to match
      -- @return `true` when the version matches the range, `false` otherwise
      matches = function(self, v)
        if getmetatable(v) ~= mt_version then 
          v = _M.version(v)
        end
        
        return (v >= self.from) and (v <= self.to)
      end,
    },
    __tostring = function(self)
      local f, t = tostring(self.from), tostring(self.to)
      if f == t then 
        return f 
      else
        return f .. " to " .. t
      end
    end,
}

--- Creates a version range. 
-- @param v1 The FROM version of the range (string or `version` object). If `nil`, assumed to be 0.
-- @param v2 (optional) The TO version of the range (string or `version` object). If omitted it will default to `v1`.
-- @return range object with `from` and `to` fields and `set:matches` method.
_M.range = function(v1,v2)
  assert (v1 or v2, "At least one parameter is required")
  v1 = v1 or "0"
  v2 = v2 or v1
  if getmetatable(v1) ~= mt_version then v1 = _M.version(v1) end
  if getmetatable(v2) ~= mt_version then v2 = _M.version(v2) end
  assert(v1 <= v2, "FROM version must be less than or equal to the TO version, to be a proper range")
  
  return setmetatable({
    from = v1,
    to = v2,
  }, mt_range)
end

-- @section set
local insertr = function(t, v1, v2)
  if getmetatable(v1) == mt_range then
    assert (v2 == nil, "First parameter was a range, second must be nil.")
    table.insert(t, v1)
  else
    table.insert(t, _M.range(v1, v2))
  end
end

local mt_set = {
  __index = {
      --- Adds an ALLOWED range to the set.
      -- @name set:allowed
      -- @param v1 Version or range, if version, the FROM version in either string or `version` object format
      -- @param v2 Version (optional), TO version in either string or `version` object format
      -- @return The `set` object, to easy chain multiple allowed/disallowed ranges
      allowed = function(self, v1, v2)
        insertr(self.ok, v1, v2)
        return self
      end,
      --- Adds a DISALLOWED range to the set.
      -- @name set:disallowed
      -- @param v1 Version or range, if version, the FROM version in either string or `version` object format
      -- @param v2 Version (optional), TO version in either string or `version` object format
      -- @return The `set` object, to easy chain multiple allowed/disallowed ranges
      disallowed = function(self,v1, v2)
        insertr(self.nok, v1, v2)
        return self
      end,
      
      --- Matches a version against the set of allowed and disallowed versions.
      -- NOTE: disallowed has a higher precedence, so a version that matches the allowed-set,
      -- but also the dis-allowed set, will return `false`.
      -- @name set:matches
      -- @param v1 Version to match (either string or `version` object).
      -- @return `true` if the version matches the set, or `false` otherwise
      matches = function(self, v)
        if getmetatable(v) ~= mt_version then v = _M.version(v) end
        
        local success
        for _, range in pairs(self.ok) do
          if range:matches(v) then 
            success = true
            break 
          end
        end
        if not success then 
          return false
        end
        for _, range in pairs(self.nok) do
          if range:matches(v) then 
            return false 
          end
        end
        return true
      end,
    },
    __tostring = function(self)
      local ok, nok
      if #self.ok == 1 then
        ok = tostring(self.ok[1])
      elseif #self.ok > 1 then
        ok = tostring(self.ok[1])
        for i = 2, #self.ok - 1 do
          ok = ok .. ", " ..tostring(self.ok[i])
        end
        ok = ok .. " and " .. tostring(self.ok[#self.ok])
      end
      if #self.nok == 1 then
        nok = tostring(self.nok[1])
      elseif #self.nok > 1 then
        nok = tostring(self.nok[1])
        for i = 2, #self.nok - 1 do
          nok = nok .. ", " ..tostring(self.nok[i])
        end
        nok = nok .. " and " .. tostring(self.nok[#self.nok])
      end
      if ok and nok then
        return ok .. ", but not " .. nok
      else
        return ok
      end
    end,
}

--- Creates a version set. A set contains a number of allowed and disallowed version ranges.
-- @param ... initial version/range to allow, see `set:allowed` for parameter descriptions
-- @return a `set` object, with `ok` and `nok` lists and a `set:matches` method 
_M.set = function(...)
  return setmetatable({
    ok = {},
    nok = {},
  }, mt_set):allowed(...)
end

return _M

