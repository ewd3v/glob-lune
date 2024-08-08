# glob-lune
`glob` implementation in luau for lune runtime heavily inspired by [glob](https://www.npmjs.com/package/glob) from js

## Usage
Install with git submodule
```sh
git submodule add [url] [path/to/submodule]
```

Example code
```luau
local files = glob("**/*.js", { ignore = "node_modules\\**" })

print("glob result:", files)
```

## Dependencies
This library depends on [lune-path-fs](https://github.com/jiwonz/lune-path-fs) and [globrex-lune](https://github.com/kimpure/globrex-lune)

## Credits & Special thanks
- Inspiration: [glob](https://www.npmjs.com/package/glob)
- `glob` to regex: [globrex-lune](https://github.com/kimpure/globrex-lune)
- Beautiful & useful built-in libraries: [Lune](https://github.com/lune-org/lune)
