local glob = require("../src/lib")

print("glob result:", glob("**/*.js", { ignore = "node_modules/**" }))
