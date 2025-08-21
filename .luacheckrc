-- Luacheck configuration file
-- Exclude prosody-modules directories from linting

-- Exclude directories
exclude = {
    "prosody-modules",
    "prosody-modules-enabled",
    ".git"
}

-- Global variables that are commonly used in Prosody modules
globals = {
    -- Prosody globals
    "prosody",
    "module",
    "host",
    "module_host",
    "module_name",
    "module_path",
    "require",
    "package",
    
    -- Common Lua globals
    "print",
    "pairs",
    "ipairs",
    "next",
    "type",
    "tostring",
    "tonumber",
    "pcall",
    "xpcall",
    "error",
    "assert",
    "select",
    "unpack",
    "table",
    "string",
    "math",
    "os",
    "io",
    "coroutine",
    "debug"
}

-- Allow unused variables (common in module files)
unused = false

-- Allow redefined variables (common in module files)
redefined = false