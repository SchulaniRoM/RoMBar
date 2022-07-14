--======================== Bag ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0.5, 0.625, 0.25, 0.375},
	events		= {
		"PLAYER_BAG_CHANGED", "BAG_ITEM_UPDATE", "BANK_CAPACITY_CHANGED",
		"MAIL_SHOW",		"AUCTION_OPEN",		"BANK_OPEN",	"STORE_OPEN", "TRADE_SHOW",
		"MAIL_CLOSED",	"AUCTION_CLOSE",	"BANK_CLOSE",	"STORE_CLOSE", "TRADE_CLOSED",
	},
	actions		= {
		LBUTTON	= {text = RB.Lang("bag", "BAG"),	func = function() ToggleBackpack() end},
		RBUTTON	= {text = RB.Lang("bag", "BANK"),	func = function() if TimeLet_GetLetTime("BankLet")<0 then ToggleUIFrame(BankFrame) else OpenBank() end end},
		MBUTTON	= {text = RB.Lang("bag", "BAG7"),	func = function() ToggleUIFrame(GoodsFrame) end},
	},
}

function ME.Update(event, ...)
	if event=="MAIL_SHOW" or event=="AUCTION_OPEN" or event=="BANK_OPEN" or event=="STORE_OPEN" or event=="TRADE_SHOW" then
		return ShowUIPanel(BagFrame)
	elseif event=="MAIL_CLOSED" or event=="AUCTION_CLOSE" or event=="BANK_CLOSE" or event=="STORE_CLOSE" or event=="TRADE_CLOSED" then
		return HideUIPanel(BagFrame)
	end

	local numBag, maxBag	= GetBagCount()
	local numIsb, maxIsb	= 0, 50	
	for i = 1, 50 do
		local _, _, count, _ = GetGoodsItemInfo(i)
		numIsb = numIsb + (count>0 and 1 or 0)
	end
	RB.UpdateButtonText(ME.name,
		sprintf("%s: %s%s%s", RB.Lang(ME.name, "BAG_SHORT"), RB.ColorByPercent(numBag, maxBag, true), RB.Separator(), RB.Dec(maxBag)),
		sprintf("%s: %s%s%s", RB.Lang(ME.name, "BAG7_SHORT"), RB.ColorByPercent(numIsb, maxIsb, true), RB.Separator(), RB.Dec(maxIsb))
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
			RB.AddToTooltip(
				RB.Lang(ME.name, "BAG1TO6", {id = i, time = i>2 and format_time(time) or ""}),
				{RB.ColorByPercent(nBag, 30, true), 30}
			)
		end
	end

	local numIsb, maxIsb	= 0, 50	
	for i = 1, 50 do
		local _, _, count = GetGoodsItemInfo(i)
		numIsb = numIsb + ((count>0 and 1) or 0)
	end
	RB.AddToTooltip(RB.Lang(ME.name, "BAG7"), {RB.ColorByPercent(numIsb, maxIsb, true), maxIsb})
	RB.AddToTooltip("---")

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
			RB.AddToTooltip(
				RB.Lang(ME.name, "BANK1TO5", {id = i, time = i>1 and format_time(time) or ""}),
				{RB.ColorByPercent(numBank[i], 40, true), 40}
			)
		end
	end
	RB.AddToTooltip(RB.Lang(ME.name, "BANK6"), {RB.ColorByPercent(numBank[6], 100, true), 100})
	RB.AddToTooltip("---")

	local numArc, maxArc	= 0, ((_G.AMB~=nil and 10) or 5)
	for i = 51, 50+maxArc do
		local _, _, count, _ = GetGoodsItemInfo(i)
		numArc = numArc + ((count>0 and 1) or 0)
	end
	RB.AddToTooltip(
		RB.Lang(ME.name, "ARCANE"),
		{RB.ColorByPercent(numArc, maxArc, true), maxArc}
	)
end

RB.RegisterButton("bag", ME)
