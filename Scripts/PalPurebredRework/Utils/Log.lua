local config = require("config");

--- Logging utility
---@class Log
local Log = {};

---@private
function Log:New()
  ---@class Log
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.prefix = '@PalPurebredRework';

  ---@private
  instance.logLevel = config.log_level;

  return instance;
end

---@private
---@param prefix string
---@param ... unknown
function Log:Print(prefix, ...) 
  local arg = {...};
  local str = prefix;

  for i, v in ipairs(arg) do
    str = str..tostring(v);
    if i < #arg then
      str = str.." >> ";
    end;
  end;

  print(str.."\n");
end

function Log:IsErrorEnabled() return self.logLevel >= 1 end
function Log:IsInfoEnabled() return self.logLevel >= 2 end

function Log:Error(...)
  if self:IsErrorEnabled() then self:Print(self.prefix.." [ERROR] ", ...) end;
end

function Log:Info(...)
  if self:IsInfoEnabled() then self:Print(self.prefix.." [INFO] ", ...) end;
end


return Log:New();