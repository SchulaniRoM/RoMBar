--======================== Craft ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0.375, 0.5, 0.375, 0.5},
	events		= {"CRAFT_UNLOCK"},
}

function ME.Update(this)
	local gather, hightest = {}, {}
	for _,skill in pairs({"MINING", "LUMBERING", "HERBLISM"}) do
		local sVal, sMax = GetPlayerCurrentSkillValue(skill), GetPlayerMaxSkillValue(skill)
		local high, low = math.modf(sVal)
		if sMax>0 and sVal==sMax then
			gather[skill] = RB.ColorByQuality(sMax-1, sMax)
		elseif sVal>=1 then
			gather[skill] = sprintf("%s:%s", RB.ColorByQuality(sMax-1, high), RB.ColorByPercent(sMax-high, 20, false, sprintf("%d%%", low*100)))
		end
	end

	RB.UpdateButtonText(ME.name,
		{gather["MINING"], gather["LUMBERING"], gather["HERBLISM"]},
		{unpack(gather["LEGEND"] or {}), unpack(gather["MASTER"] or {}), unpack(gather["EXPERT"] or {})}
	)
end

function ME.Tooltip(tooltip)
	local skillLevel = {[20] = RB.lang.CRAFT_LEVEL1, [40] = RB.lang.CRAFT_LEVEL2, [60] = RB.lang.CRAFT_LEVEL3, [80] = RB.lang.CRAFT_LEVEL4, [100] = RB.lang.CRAFT_LEVEL5}
	local found = 0
	for c,craftGroup in pairs({Crafting_Group_Gather, Crafting_Group_Craft, Crafting_Group_Other}) do
		for i=1,#craftGroup.Items do
			local group 			= craftGroup.Items[i]
			local sVal, sMax	= GetPlayerCurrentSkillValue(group.ID), GetPlayerMaxSkillValue(group.ID)
			if sVal>=1 then
				local sVal1, sVal2 = math.modf(sVal)
				sVal2 = (sVal1==sVal and sVal2==0) and 1 or sVal2
				tooltip:AddDoubleLine(
					RB.ColorByQuality(sMax-1, group.Name.." "..sVal1),
					sprintf("%s%s%s%s%s", RB.ColorByPercent(sVal2, 1, false, sprintf("%d%%", 100*sVal2)), RB.Separator(), RB.ColorByQuality(sMax-1, skillLevel[sMax]), RB.Separator(), RB.ColorByQuality(sMax-1, RB.Dec(sMax)))
				)
				found = found + 1
			end
		end
	end
	if found==0 then
		tooltip:AddLine(RB.lang.CRAFT_NOCRAFT)
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleUIFrame(CraftFrame)
	elseif key=="RBUTTON" then
	elseif key=="MBUTTON" then
	end
end

RB.RegisterButton("craft", ME)
