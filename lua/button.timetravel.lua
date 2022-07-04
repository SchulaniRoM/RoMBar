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
		540194,	-- Kodexbuch
		540001,	-- Rückruf
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
		sprintf("%s%s%s", os.date(RB.lang.DATE_STRING), RB.Separator(), os.date(RB.lang.TIME_STRING)),
 		sprintf("%s: %s%s%s: %s%s%s: %sMB", RB.lang["FPS"], RB.ColorByPercent(fps, 60, false, fps), RB.Separator(), RB.lang["PING"], RB.ColorByPercent(ping, 120, true, ping), RB.Separator(), RB.lang["MEMORY"], RB.Dec(mem))
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
		ToggleUIFrame(WorldMapFrame)
	elseif key=="RBUTTON" then
	elseif key=="MBUTTON" then
		ToggleUIFrame(TeleportBook)
	end
end

RB.RegisterButton("timetravel", ME)
