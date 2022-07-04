--======================== XP ======================

local RB = _G.RoMBar
local ME = {
	icon			= RB.addonPath.."/textures/icon_stats",
	events		= {"PLAYER_EXP_CHANGED", "TP_EXP_UPDATE"},
	actions		= {
		LBUTTON	= {func = function() ToggleUIFrame(UI_SkillBook) 		end},
		MBUTTON	= {func = function() ToggleUIFrame(SkillSuitFrame)	end},
		RBUTTON	= {func = function() ToggleUIFrame(DrawRuneFrame)		end},
	},
}

function ME.Update(event, ...)
	local cXP, mXP	= GetPlayerExp(), GetPlayerMaxExp()
	local cTP, mTP	= GetTpExp(), GetTotalTpExp()
	local dXP, dTP 	= GetPlayerExpDebt()
	local percent		= 100/mXP*cXP
	RB.UpdateButtonText(ME.name,
		{dXP>0 and RB.ColorPosNeg(dXP) or nil, RB.ColorByPercent(cXP, mXP), RB.Dec(mXP), RB.ColorByPercent(cXP, mXP, false, sprintf("%d%%", percent))},
		{dTP>0 and RB.ColorPosNeg(dTP) or nil, RB.Dec(cTP), RB.Dec(mTP)}
	)
end

-- function ME.Tooltip(tooltip)
-- end

RB.RegisterButton("exp", ME)
