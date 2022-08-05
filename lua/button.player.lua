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
		{dXP<0 and RB.ColorPosNeg(dXP) or nil, RB.ColorByPercent(cXP, mXP), RB.ColorByPercent(cXP, mXP, false, ("%d%%"):format(percent)), RB.Dec(mXP)}
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
		local class, token, level, cXP, mXP, debt = GetPlayerClassInfo(i, true)
		if class~=nil then
			RB.AddToTooltip(
				RB.ColorByClass(token, class.." "..level),
				{RB.ColorByPercent(cXP, mXP), RB.ColorByPercent(cXP, mXP, false, ("%d%%"):format(100/mXP*cXP)), RB.Dec(mXP)}
			)
		end
	end

	-- peak level
	local cXP, mXP, b							= GetPlayerExp(), GetPlayerMaxExp(), 0
	local mLevel, sLevel					= UnitLevel("player")
	local pLevel									= GetPeakLevel()
	local mTPc, mTPm							= GetTpExp(), GetTotalTpExp()
	if pLevel and mLevel==100 and sLevel==100 then
		RB.AddToTooltip(
			RB.ColorByName("PINK", pLevel),
			{RB.ColorByPercent(cXP, mXP), RB.ColorByPercent(cXP, mXP, false, ("%d%%"):format(100/mXP*cXP)), RB.Dec(mXP)}
		)
	end
	RB.AddToTooltip(
		RB.Lang(ME.name, "TP"),
		{RB.Dec(mTPc), ("%s: %s"):format(RB.Lang(ME.name, "TPALL"), RB.Dec(mTPm))}
	)
	RB.AddToTooltip("---")

	-- dept / boni
	local mXPd, mTPd, sXPd, sTPd	= GetPlayerExpDebt()
	local mXPb, mTPb							= GetPlayerExtraPoint()
	RB.AddToTooltip(
		RB.Lang(ME.name, "DEPT"),
		{("%s: %s"):format(RB.Lang(ME.name, "XP_SHORT"), RB.Dec(mXPd)), ("%s: %s"):format(RB.Lang(ME.name, "TP_SHORT"), RB.Dec(mTPd))}
	)
	RB.AddToTooltip(
		RB.Lang(ME.name, "BONUS"),
		{("%s: %s"):format(RB.Lang(ME.name, "XP_SHORT"), RB.Dec(mXPb)), ("%s: %s"):format(RB.Lang(ME.name, "TP_SHORT"), RB.Dec(mTPb))}
	)
	-- set skils
	local numSuitSkills	= {SetSuitSkill_List()}				-- warrior , scout , rogue , mage , priest , knight , warden , druid , common
	local pToken				= UnitClassToken("player")
	local pClass				= UnitClass("player")
	local pText, cText	= "", ""
  for i = 1, GetNumClasses() do
    local _,token = GetClassInfoByID(i)
    if token == pToken then
			for j=0,(numSuitSkills[i] or 0)-1 do
				local skill = GetSuitSkill_List(i,j)
				pText = sprintf("%s%s%s", #pText>0 and pText or "", #pText>0 and ", " or "", skill)
			end
			for j=0,(numSuitSkills[#numSuitSkills] or 0)-1 do
				local skill = GetSuitSkill_List(#numSuitSkills,j)
				cText = sprintf("%s%s%s", #cText>0 and cText or "", #cText>0 and ", " or "", skill)
			end
			if #pText>0 or #cText>0 then RB.AddToTooltip("---") end
			if #pText>0 then RB.AddToTooltip(RB.Lang(ME.name, "SUITSKILLCLASS", {pClass})..": "..pText) end
			if #cText>0 then RB.AddToTooltip(RB.Lang(ME.name, "SUITSKILLCOMMON")..": "..cText) end
      break
    end
  end
end

RB.RegisterButton("player", ME)
