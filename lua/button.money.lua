--======================== Money ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/moneyframe/moneyicons", 0, 0.03125, 0, 1},
	events		= "PLAYER_MONEY",
}
local moneyItems = {
	{203038,nil,nil,3},	-- Phiriusmarken
	{203944,3,1,4},			-- Ehrenpunkte
	{206686,3,2,8},			-- Abzeichen der Prüfung
	{206879,2,1,9},			-- Alte Mementos
	{240181,1,1,11},		-- Phirius-Muscheln
	{201545,1,2,12},		-- Energie der Gerechtigkeit
	{241706,2,2,13},		-- Beweise des Mythos
	{240736,3,3,14},		-- Arenamarken (Abzeichen des Ruhms)
	{200222,2,3,15},		-- Spiegelscherben
	{244207,1,4,17},		-- Gipfelfragmente
	{244215,3,4,18},		-- kupferne Prügelmünze
	{244223,3,5,19},		-- silberne Prügelmünze
	-- {244224},					-- goldene Prügelmünze
	-- Sternenstaub (244198 oder 232221?)
	-- {2017772,2,4}, 		-- Spiegelweltticket (Schriftrolle des Neuanfangs für die Spiegelwelt ??)
	{244846,3,6},				-- Festtags-Glasperle
	{245372,3,7},				-- Kupfermünze der Prüfung
	{245373,3,8},				-- Silbermünze der Prüfung
	{208681,1,3},				-- Traumlandpioniersiegel
}

function ME.Init()
	RB.RegisterEvent("money", ME.events)
	return true
end

function ME.Update(event, ...)
	local phirius = RB.ColorByRarity(203038, GetPlayerMoney("billdin") + GetCountInBankByName(TEXT("Sys203038_name")))
	local diamond	= RB.ColorByName("diamond", GetPlayerMoney("account"))
	local ruby		= RB.ColorByName("ruby", GetPlayerMoney("bonus"))
	local arkane	= RB.ColorByName("arcane", GetMagicBoxEnergy())
	RB.UpdateButtonText(ME.name,
		RB.ColorByName("gold", RB.Dec(GetPlayerMoney("copper"))),
		{diamond, GetPlayerMoney("bonus")>0 and ruby or nil, phirius, arkane}
	)
end

function ME.Tooltip(tooltip)
	tooltip:AddDoubleLine(RB.Lang(ME.name, "GOLD")..":", 		RB.ColorByName("gold", GetPlayerMoney("copper")))
	tooltip:AddDoubleLine(RB.Lang(ME.name, "DIAMOND")..":", RB.ColorByName("diamond", GetPlayerMoney("account")))
	tooltip:AddDoubleLine(RB.Lang(ME.name, "RUBY")..":", 		RB.ColorByName("ruby", GetPlayerMoney("bonus")))
	tooltip:AddDoubleLine(RB.Lang(ME.name, "ARCANE")..":",	RB.ColorByName("arcane", GetMagicBoxEnergy()))
	tooltip:AddSeparator()
	for _,l in pairs(moneyItems) do
		local id, group, index, mType = unpack(l)
		local aVal, aBag, aBank, limit, text, name	= 0, 0, 0, 0, ""
		if group and index then
			aVal,limit	= GetPlayerPointInfo(group, index, "")
		end
		aBag, aBank	= GetBagItemCount(id), RB.GetBankItemCount(id)
		if aVal + aBag + aBank > 0 then
			name	= mType and RB.ColorByRarity(id, TEXT("SYS_MONEY_TYPE_"..mType)) or RB.ColorByRarity(id, TEXT("Sys"..id.."_name"))
			if aBag>0 or aBank>0 then
				text	= sprintf("%s + %s", RB.Dec(aBank), RB.Dec(aBag))
			end
			if aVal>0 then
				text	= sprintf("%s%s%s", text, #text>0 and " + " or "", limit>0 and RB.ColorByPercent(aVal, limit, true) or RB.Dec(aVal))
			end
			if limit>0 then
				text	= sprintf("%s%s%s", text, RB.Separator(), RB.Dec(limit))
			end
			tooltip:AddDoubleLine(name, text)
		end
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleCharacter("MoneyFrame")
	elseif key=="RBUTTON" then
	elseif key=="MBUTTON" then
		ToggleUIFrame(ItemMallFrame)
	end
end

RB.RegisterButton("money", ME)
