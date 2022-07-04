--======================== Bag ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0.5, 0.625, 0.25, 0.375},
	events		= {
		"PLAYER_BAG_CHANGED", "BAG_ITEM_UPDATE",
		"MAIL_SHOW",		"AUCTION_OPEN",		"BANK_OPEN",	"STORE_OPEN",
		"MAIL_CLOSED",	"AUCTION_CLOSE",	"BANK_CLOSE",	"STORE_CLOSE"},
}

function ME.Update(event, ...)
	if event=="MAIL_SHOW" or event=="AUCTION_OPEN" or event=="BANK_OPEN" or event=="STORE_OPEN" then
		ShowUIPanel(BagFrame)
	elseif event=="MAIL_CLOSED" or event=="AUCTION_CLOSE" or event=="BANK_CLOSE" or event=="STORE_CLOSE" then
		HideUIPanel(BagFrame)
	end

	local numBag, maxBag	= GetBagCount()
	local numIsb, maxIsb	= 0, 50	
	for i = 1, 50 do
		local _, _, count, _ = GetGoodsItemInfo(i)
		numIsb = numIsb + (count>0 and 1 or 0)
	end
	RB.UpdateButtonText(ME.name,
		sprintf("%s: %s%s%s", RB.lang["BAG"], RB.ColorByPercent(numBag, maxBag, true), RB.Separator(), RB.Dec(maxBag)),
		sprintf("%s: %s%s%s", RB.lang["ISB"], RB.ColorByPercent(numIsb, maxIsb, true), RB.Separator(), RB.Dec(maxIsb))
	)
end

function ME.Tooltip(tooltip)
	
	local function format_time(time)
		if time==nil or time<=0 then
			return BANK_LET_OVER_TIME
		else
			local day			= math.floor(time / 60 / 24)
			local hour		= math.floor((time - (day * 60 * 24)) / 60)
			local minute	= time - (day * 60 * 24) - (hour * 60)
			if day>365 then
				return ""
			else
				return sprintf(BANK_LETTIME_MSG, day, hour, minute)
			end
		end
	end
	
	for i = 1, 6 do
		local nBag = 0
		for j = 1, 30 do
			local _,_,_,count = GetBagItemInfo((i-1)*30+j)
			nBag	= nBag + (count>0 and 1 or 0)
		end
		local isLet, time		= false, 0
		if i>2 then
			isLet, time = GetBagPageLetTime(i)
		end
		if i<=2 or time>0 or nBag>0 then
			tooltip:AddDoubleLine(
				sprintf("%s %d %s", RB.lang.BAG_PAGE1TO6, i, i>2 and format_time(time) or ""),
				sprintf("%s%s%s", RB.ColorByPercent(nBag, 30, true), RB.Separator(), 30)
			)
		end
	end

	local numIsb, maxIsb	= 0, 50	
	for i = 1, 50 do
		local _, _, count = GetGoodsItemInfo(i)
		numIsb = numIsb + ((count>0 and 1) or 0)
	end
	tooltip:AddDoubleLine(
		sprintf("%s", RB.lang["BAG_PAGE7"]),
		sprintf("%s%s%s", RB.ColorByPercent(numIsb, maxIsb, true), RB.Separator(), maxIsb)
	)

	tooltip:AddSeparator()
	local numBank = {0,0,0,0,0,0}
	for i=1, 300 do
		local page = ((i<=200 and math.floor((i-1)/40) + 1) or 6)
		local _, name = GetBankItemInfo(i)
		numBank[page] = numBank[page] + ((name~=nil and 1) or 0)
	end
	for i=1,5 do
		local time		= 0
		if i>1 then
			time = TimeLet_GetLetTime("BankBag"..i)
		end
		if i<=1 or (numBank[i]>0 or time>0) then
			tooltip:AddDoubleLine(
				sprintf("%s %d %s", RB.lang["BANK_PAGE1TO5"], i,((i>1 and format_time(time)) or "")),
				sprintf("%s%s%s", RB.ColorByPercent(numBank[i], 40, true), RB.Separator(), 40)
			)
		end
	end
	tooltip:AddDoubleLine(
		sprintf("%s", RB.lang["BANK_PAGE6"]),
		sprintf("%s%s%s", RB.ColorByPercent(numBank[6], 100, true), RB.Separator(), 100)
	)
	
	tooltip:AddSeparator()
	local numArc, maxArc	= 0, ((_G.AMB~=nil and 10) or 5)
	for i = 51, 50+maxArc do
		local _, _, count, _ = GetGoodsItemInfo(i)
		numArc = numArc + ((count>0 and 1) or 0)
	end
	tooltip:AddDoubleLine(
		sprintf("%s", RB.lang["ARCANE_LONG"]),
		sprintf("%s%s%s", RB.ColorByPercent(numArc, maxArc, true), RB.Separator(), maxArc)
	)
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleBackpack()
	elseif key=="RBUTTON" then
		if TimeLet_GetLetTime("BankLet")<0 then
			ToggleUIFrame(BankFrame)
		else
			OpenMail()
		end
	elseif key=="MBUTTON" then
		ToggleUIFrame(GoodsFrame)
	end
end

RB.RegisterButton("bag", ME)
