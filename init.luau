--!strict

local globrex = require("submodules/globrex")
local pathfs = require("submodules/pathfs")
local regex = require("@lune/regex")
local globstarOption = { globstar = true }

local DEFAULT_IGNORE_GLOBS = {
	`.**{pathfs.pathSeparator}*`,
	`**{pathfs.pathSeparator}.*`,
	`"**{pathfs.pathSeparator}.*{pathfs.pathSeparator}*"`
}
local EMPTY_TABLE = {}

type Option = {
	cwd: string?,
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

	local function scan(asPath: pathfs.AsPath)
		if unwrappedOption.maxDepth and unwrappedOption.maxDepth <= depth then
			return
		end
		local path = pathfs.Path.from(asPath)
		for _, v in pathfs.readDir(path) do
			local vp = path:join(v)
			if pathfs.isDir(vp) then
				scan(vp)
				if unwrappedOption.nodir then
					continue
				end
			end
			local noCurDirVP = pathfs.getNoCurDirPathOf(vp)
			local valid = true
			for _, globRegex in globRegexes do
				if not globRegex:isMatch(noCurDirVP:toString()) then
					valid = false
				end
			end
			for _, globRegex in ignoreGlobRegexes do
				if globRegex:isMatch(noCurDirVP:toString()) then
					valid = false
				end
			end
			if not valid then
				continue
			end
			if not unwrappedOption.dotRelative then
				vp = noCurDirVP
			end
			if unwrappedOption.absolute then
				vp = pathfs.getAbsolutePathOf(vp)
			end
			table.insert(result, vp)
		end
		depth += 1
	end
	scan(unwrappedOption.cwd or ".")

	return result
end
