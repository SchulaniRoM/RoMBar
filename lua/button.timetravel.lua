--======================== Time ======================

local RB = _G.RoMBar
local ME = {
	icon				= {"Interface/transportbook/tb_button-normal", 0.234375, 0.75, 0.203125, 0.71875},
	events			= "ONUPDATE",
}

local teleport = {
	casts = {
		540190,	-- Logar
		540191,	-- Reifort
		540192,	-- Tal der Vorbereitung
		540193,	-- Heffnerlager
		540001,	-- Rückruf
		540194,	-- Kodexbuch
	},
	items = {
		{ 208786, 208787, 208788, 203784 },	-- Gildenburg-Transportstein (30/14/7 Tage, einzeln)
		{ 208783, 208784, 208785, 202435 },	-- Trautes Heim (30/14/7 Tage, einzeln)
	},
}


function ME.Update(event, ...)
 	local fps		= math.floor(GetFramerate() or 0)
	local ping	= math.floor(GetPing() or 0)
	local mem		= math.floor((collectgarbage("count") or 0)/1024)
	RB.UpdateButtonText(ME.name,
		os and {os.date(RB.Lang(ME.name, "DATE_FORMAT")), os.date(RB.Lang(ME.name, "TIME_FORMAT"))} or nil,
 		{
			RB.Lang(ME.name, "FPS",			{RB.ColorByPercent(fps, 60, false)}),
			RB.Lang(ME.name, "PING",		{RB.ColorByPercent(ping, 120, true)}),
			RB.Lang(ME.name, "MEMORY",	{RB.ColorByPercent(mem, 150, true)})
		}
	)
end

function ME.Tooltip(tooltip)
	for k,v in pairs({
		202902,	-- Markierungstinte
		202903,	-- Transportrune
		202904,	-- Portalrune
		202905,	-- Durchgangsrune
		203784,	-- Gildenburg-Transportstein
		202435,	-- Trautes Heim
	}) do
		local cBag, cBank	= GetBagItemCount(v), RB.GetBankItemCount(v)
		if cBag+cBank>0 then
			tooltip:AddDoubleLine(
				RB.ColorByRarity(v, TEXT("Sys"..v.."_name")),
				sprintf("%s%s%s", cBag>0 and RB.Dec(cBag) or "", cBag>0 and cBank>0 and RB.Separator() or "", cBank>0 and RB.Dec(cBank) or "")
			)
		end
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleUIFrame(TeleportBook)
	elseif key=="RBUTTON" then
		RB.modules.dropdown.ShowDropDown(tooltip, ME.DropDownHandler)
	elseif key=="MBUTTON" then
	end
end

function ME.DropDownHandler()
	local DD = RB.modules.dropdown
	if (UIDROPDOWNMENU_MENU_LEVEL or 1)==1 then
		DD.AddTitle(RB.Lang(ME.name, "TELEPORT"))
		for _,cID in pairs(teleport.casts) do
			local cast		= TEXT("Sys"..cID.."_name")
			local page,id	= RB.GetSkillBookIndexes(cast)
			if page and id then
				local name, _, icon, _, rank, type, upgradeCost, isSkillable, isAvailable = GetSkillDetail(page,id)
				local cooldown, remaining = GetSkillCooldown(page, id)
				local text
				if cID==540001 and RB.settings.recallLocation then
					text 		= remaining>0 and sprintf("%s%s (%s)", cast, ": "..RB.settings.recallLocation or "", os.date("%Mm%Ss", remaining)) or cast
				else
					text 		= remaining>0 and sprintf("%s (%s)", cast, os.date("%Mm%Ss", remaining)) or cast
				end
				local func		= not isAvailable or remaining>0 and nil or function(this) CloseDropDownMenus() CastSpellByName(this.value) end
				local tooltip = not isAvailable and RB.Lang(ME.name, "NOTELEPORT") or nil,
				DD.AddButton(text, func, cast, tooltip)
			end
		end
		DD.AddSeparator()
		for _,lst in ipairs(teleport.items) do
			for _,iID in ipairs(lst) do
				local cnt = GetBagItemCount(iID)
				if cnt>0 then
					local name	= TEXT("Sys"..iID.."_name")
					DD.AddButton(sprintf("%s x%d", RB.ColorByRarity(iID, name), cnt), function(this) UseItemByName(this.value) end, name)
					break
				end
			end
		end
	end
end

function ME.SpeakFrame_AddOption(string, script, type, iconid, id, highlight)
	local text	= string or ""
	local func	= nil
	local oFunc = RB.GetOriginalFunction(_G, "SpeakFrame_AddOption")
	if string.find(text, TEXT("SC_111256_S")) or string.find(text, TEXT("SO_110561_5")) then
		func	= function(t,i) script(t,i) RB.settings.recallLocation = GetZoneName() end
	end
	oFunc(string, func or script, type, iconid, id, highlight)
end
RB.Hook(_G, "SpeakFrame_AddOption", ME.SpeakFrame_AddOption)

RB.RegisterButton("timetravel", ME)
