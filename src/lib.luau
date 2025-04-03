local globrex = require("../lune_packages/globrex_lune")
local pathfs = require("../lune_packages/pathfs")
local fs = pathfs.fs
local globstarOption = { globstar = true, extended = true }

local DEFAULT_IGNORE_GLOBS = {
	`.**{pathfs.pathSeparator}*`,
	`**{pathfs.pathSeparator}.*`,
	`"**{pathfs.pathSeparator}.*{pathfs.pathSeparator}*"`
}
local EMPTY_TABLE = {}

export type Option = {
	cwd: pathfs.AsPath?,
	noglobstar: boolean?,
	maxDepth: number?,
	nodir: boolean?,
	ignore: (string | { string })?,
	absolute: boolean?,
	platform: typeof(require("@lune/process").os)?,
	dotRelative: boolean?,
}

return function(pattern: string | { string }, option: Option?): { pathfs.Path }
	local result = {}
	local depth = 0
	local globrexOption: typeof(globstarOption)? = globstarOption
	local unwrappedOption = (option or EMPTY_TABLE) :: Option
	if unwrappedOption.noglobstar then
		globrexOption = nil
	end
	local globRegexes do
		if type(pattern) == "string" then
			globRegexes = { globrex(pattern, globrexOption).regex }
		elseif type(pattern) == "table" then
			globRegexes = pattern :: any
			for i, v in pattern do
				globRegexes[i] = globrex(v, globrexOption).regex
			end
		else
			error("Glob pattern must be a string or table")
		end
	end

	local ignoreGlobRegexes = table.create(#DEFAULT_IGNORE_GLOBS) do
		local ignore = table.clone(DEFAULT_IGNORE_GLOBS)
		if unwrappedOption.ignore then
			if type(unwrappedOption.ignore) == "string" then
				table.insert(ignore, unwrappedOption.ignore)
			elseif type(unwrappedOption.ignore) == "table" then
				for _, v in unwrappedOption.ignore do
					table.insert(ignore, v)
				end
			end
		end
		for i, v in ignore do
			ignoreGlobRegexes[i] = globrex(v, globstarOption).regex
		end
	end

	local function scan(fullPath: pathfs.Path, path: pathfs.Path)
		if unwrappedOption.maxDepth and unwrappedOption.maxDepth <= depth then
			return
		end
		for _, v in fs.readDir(fullPath) do
			local vfp = fullPath:join(v)
			local vp = path:join(v)
			if fs.isDir(vfp) then
				scan(vfp, vp)
				if unwrappedOption.nodir then
					continue
				end
			end
			local noCurDirVP = pathfs.withoutCurDir(vp)
			local valid = true
			for _, globRegex in globRegexes do
				if not globRegex:test(noCurDirVP:toString()) then
					valid = false
					break
				end
			end
			for _, globRegex in ignoreGlobRegexes do
				if globRegex:test(noCurDirVP:toString()) then
					valid = false
					break
				end
			end
			if not valid then
				continue
			end
			if not unwrappedOption.dotRelative then
				vfp = pathfs.withoutCurDir(vfp)
			end
			if unwrappedOption.absolute then
				vfp = pathfs.absolute(vfp)
			end
			table.insert(result, vfp)
		end
		depth += 1
	end

	local cwd = tostring(unwrappedOption.cwd)
	if not cwd or cwd == "" then
		cwd = "."
	end

	scan(pathfs.Path.from(cwd), pathfs.Path.from("."))

	return result
end
