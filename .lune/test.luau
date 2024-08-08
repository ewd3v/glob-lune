-- local globrex = require("../submodules/globrex")

-- local result = globrex("**/*.luau", { globstar = true })
-- print(result.regex:isMatch("test.luau"), result)

local glob = require("..")

print("glob result:", glob("**/*.js", { ignore = "node_modules\\**" }))
