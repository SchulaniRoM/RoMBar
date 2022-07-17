--======================== Hooks ======================

local RB = _G.RoMBar
local ME = {}

function Hook_UltimateMailMod()
	local _, error	= loadfile(sprintf("%s/personal.lua", RB.addonPath))
	if error then
		RB.Error(error)
	else
		local data	= dofile(sprintf("%s/personal.lua", RB.addonPath))
		UMM_OwnCharacters = UMM_OwnCharacters or {}
		local merge	= data.myTwinks
		for _,name in pairs(UMM_OwnCharacters) do	merge[name] = true end
		UMM_OwnCharacters = {}
		for name in pairs(merge) do
			table.insert(UMM_OwnCharacters, name)
		end
	end
	RB.UnregisterEvent(ME.name, "LOADING_END")
end

function ME.Init()
	RB.RegisterEvent(ME.name, "LOADING_END", Hook_UltimateMailMod)
end

RB.RegisterModule("hooks", ME)
