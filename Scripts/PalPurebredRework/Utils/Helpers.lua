--- Helpers functions
---@class Helpers
local Helpers = {};


---@private
function Helpers:New()
  ---@class Helpers
  local instance = setmetatable({}, self);
  self.__index = self;

  return instance;
end

-- Convert an ingame Guid to string
---@param id FGuid
---@return string
function Helpers:ToStringGuid(id)
  return tostring(id.A)
    ..tostring(id.B)
    ..tostring(id.C)
    ..tostring(id.D);
end

---@param a FGuid
---@param b FGuid
---@return boolean
function Helpers:IsEqualGuid(a, b)
  return a.A == b.A
    and a.B == b.B
    and a.C == b.C
    and a.D == b.D;
end

-- Check if the Guid is valid as in properly loaded
---@param id FGuid
---@return boolean
function Helpers:IsValidGuid(id) return id.A ~= 0 end

---@generic T
---@param array T[]
function Helpers:ShuffleArray(array)
  -- Fisher-Yates Shuffle
  for i = #array, 2, -1 do
    local j = math.random(i) -- Generate a random index between 1 and i
    array[i], array[j] = array[j], array[i] -- Swap elements at index i and j
  end;
end

---@generic T
---@param tarray TArray
---@param array T[]
function Helpers:ReplaceTArrayWith(tarray, array)
  tarray:Empty();

  -- Manual resize of the TArray by accessing out of bound element
  -- This is a workaround until https://github.com/UE4SS-RE/RE-UE4SS/pull/436 is available
  for i = 1, #array do local _ = tarray[i + 1] end

  tarray:ForEach(function(index, element)
    element:set(array[index]);
  end);
end


---@param input string
---@param delimiter string
function Helpers:SplitString(input, delimiter)
  ---@type string[]
  local result = {};
  local pattern = string.format("([^%s]+)", delimiter);

  for match in (input..delimiter):gmatch(pattern) do result[#result+1] = match end;

  return result;
end

return Helpers:New();