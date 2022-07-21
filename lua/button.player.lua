--======================== Player ======================

local RB = _G.RoMBar
local ME = {
	events		= {"LOADING_END", "EXCHANGECLASS_SUCCESS", "UNIT_LEVEL", "PLAYER_LEVEL_UP", "PLAYER_EXP_CHANGED", "TP_EXP_UPDATE", "UPDATE_COLORS_ROMWOW"},
	actions		= {
		LBUTTON	= {func = function() ToggleUIFrame(UI_SkillBook) 		end},
		MBUTTON	= {func = function() ToggleUIFrame(SkillSuitFrame)	end},
		RBUTTON	= {func = function() ToggleUIFrame(DrawRuneFrame)		end},
	},
}

local function RomToDec(rom)
	local trans = {I=1,II=2,III=3,IV=4,V=5,VI=6,VII=7,VIII=8,IX=9,XX=10}
	return trans[rom] or rom
end

local function GetPeakLevel()
	local b,peak,name,id = 0,nil
	repeat b = b + 1
		name,_,_,id = UnitBuff("player", b)
		if id and id>626025 and id<=626045 then
			peak = name
			break
		end
	until not id
	if peak then
		local level 	= RomToDec(peak:match("([IXV]*)$"))
		return peak, level
	end
	return nil, 0
end

function ME.Update(event, ...)
	local mClass, sClass	= UnitClass("player")
	local mToken, sToken	= UnitClassToken("player")
	local mLevel, sLevel	= UnitLevel("player")
	if not mLevel or mLevel<=0 then	-- bug
		RB.RegisterEvent(ME.name, "ONUPDATE", ME)
		return
	else
		RB.UnregisterEvent(ME.name, "ONUPDATE")
	end
	local cXP, mXP		= GetPlayerExp(), GetPlayerMaxExp()
	local cTP, mTP		= GetTpExp(), GetTotalTpExp()
	local dXP, dTP 		= GetPlayerExpDebt()
	local percent			= 100/mXP*cXP
	local peak				= GetPeakLevel()
	RB.UpdateButtonText(ME.name,
		{RB.ColorByClass(mToken, mClass.." "..mLevel), sLevel>0 and RB.ColorByClass(sToken, sClass.." "..sLevel) or nil, (peak and #peak>0) and RB.ColorByName("PINK", peak:match("([IXV]*)$")) or nil},
		{dXP<0 and RB.ColorPosNeg(dXP) or nil, RB.ColorByPercent(cXP, mXP), RB.Dec(mXP), RB.ColorByPercent(cXP, mXP, false, sprintf("%d%%", percent))}
	)
	local oldIcon		= ME.icon
	if sToken and sToken~="" then
		ME.icon = sprintf("Interface/widgeticons/classicon_%s_%s.tga", mToken, sToken)
	else
		ME.icon = sprintf("Interface/widgeticons/classicon_%s.tga", mToken)
	end
	if oldIcon~=ME.icon then
		RB.UpdateButtonIcon(ME.name)
	end
end

function ME.Tooltip(tooltip)
	-- classes
	for i = 1, 16 do
		local class, token, level, currXP, maxXP, debt = GetPlayerClassInfo(i, true)
		if class~=nil then
			tooltip:AddDoubleLine(
				RB.ColorByClass(token, class.." "..level),
				sprintf("%s%s%s", RB.ColorByPercent(currXP, maxXP), RB.Separator(), RB.Dec(maxXP))
			)
		end
	end

	-- peak level
	local cXP, mXP, b							= GetPlayerExp(), GetPlayerMaxExp(), 0
	local mLevel, sLevel					= UnitLevel("player")
	local pLevel									= GetPeakLevel()
	local mTPc, mTPm							= GetTpExp(), GetTotalTpExp()
	if pLevel and mLevel==100 and sLevel==100 then
		tooltip:AddDoubleLine(
			RB.ColorByName("PINK", pLevel),
			sprintf("%s%s%s", RB.ColorByPercent(cXP, mXP), RB.Separator(), RB.Dec(mXP))
		)
	end
	tooltip:AddDoubleLine(RB.Lang(ME.name, "TP"), sprintf("%s%s%s", RB.Dec(mTPc), RB.Separator(), RB.Dec(mTPm)))
	tooltip:AddSeparator()

	-- dept / boni
	local mXPd, mTPd, sXPd, sTPd	= GetPlayerExpDebt()
	local mXPb, mTPb							= GetPlayerExtraPoint()
	tooltip:AddDoubleLine(RB.Lang(ME.name, "DEPT"), 		sprintf("%s: %s%s%s: %s", RB.Lang(ME.name, "XP_SHORT"), RB.Dec(mXPd), RB.Separator(), RB.Lang(ME.name, "TP_SHORT"), RB.Dec(mTPd)))
	tooltip:AddDoubleLine(RB.Lang(ME.name, "BONUS"),		sprintf("%s: %s%s%s: %s", RB.Lang(ME.name, "XP_SHORT"), RB.Dec(mXPb), RB.Separator(), RB.Lang(ME.name, "TP_SHORT"), RB.Dec(mTPb)))
end

RB.RegisterButton("player", ME)
