Fork of https://github.com/jiwonz/glob-lune containing my fixes & updates that may not merged into the official repository yet.

# glob-lune

`glob` implementation in luau for lune runtime heavily inspired by [glob](https://www.npmjs.com/package/glob)

## Installation
Install via pesde (Recommended)
```sh
pesde add jiwonz/glob
```

## Example code
```luau
local files = glob("**/*.js", { ignore = "node_modules\\**" })

print("glob result:", files)
```

## Credits & Special thanks

- Inspiration: [glob](https://www.npmjs.com/package/glob)
- `glob` to regex: [globrex-lune](https://github.com/kimpure/globrex-lune)
- Beautiful & useful built-in libraries: [Lune](https://github.com/lune-org/lune)
