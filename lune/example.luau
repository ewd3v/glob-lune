local glob = require("../")

print("glob result:", glob("**/*.js", { ignore = "node_modules/**" }))
