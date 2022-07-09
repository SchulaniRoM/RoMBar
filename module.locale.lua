--======================== languages ======================

local RB = _G.RoMBar
local ME = {
	lang		= {},
}

function ME.Init()
	local lang	= GetLanguage():upper():sub(1,2)
	local _,err = loadfile(sprintf("%s/lang/%s.lua", RB.addonPath, lang))
	if err then
		RB.Error("RoMBar can't find translation for your client language, default (DE) loaded.")
		ME.lang	= dofile(sprintf("%s/lang/DE.lua", RB.addonPath))
	else
		ME.lang	= dofile(sprintf("%s/lang/%s.lua", RB.addonPath, lang))
	end
end

function ME.Lang(name, token, replace, default)
	local name 	= tostring(name or ""):upper()
	local token	= tostring(token or ""):upper()
	local text	= sprintf("%s:%s.%s", ME.lang._lang, name, token)
	if ME.lang[name] and type(ME.lang[name])=="table" and ME.lang[name][token] then
		text	= ME.lang[name][token]
	elseif ME.lang[name.."_"..token] and type(ME.lang[name.."_"..token])=="string" then
		text	= ME.lang[name.."_"..token]
	elseif token=="" and ME.lang[name] and type(ME.lang[name])=="string" then
		text	= ME.lang[name]
	elseif default~=nil then
		return default
	end
	if replace and type(replace)=="table" and text:find("<<") then
		text	= RB.Format(text, replace)
	end
	return text
end

RB.RegisterModule("locale", ME)
