---@class ModConfig
local config = {

  -- Set the logger behavior
  --  0 -> No logs (Default)
  --  1 -> Enable error
  --  2 -> Enable error, info
  log_level = 0,

  -- Enable some QOL change when working on the mod
  -- Default -> false
  is_debug_session = false,
};

return config;