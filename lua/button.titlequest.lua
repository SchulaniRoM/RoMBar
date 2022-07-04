--======================== Quest ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0, 0.125, 0.125, 0.25},
	events		= {"LOADING_END", "RESET_QUESTTRACK", "PLAYER_TITLE_ID_CHANGED"},
	actions		= {
 		MBUTTON	= {func = function() ToggleUIFrame(AchievementTitleFrame) end},
		RBUTTON	= {func = function() ToggleUIFrame(UI_QuestBook) end},
	},
	titles		= {},
}

function ME.Init()
	local tTotal		= GetTitleCount()
	if tTotal==0 then
		AchievementTitleFrame:Show()
		AchievementTitleFrame:Hide()
		tTotal = GetTitleCount()
	end
	if tTotal==0 then return "" end
	RB.Debug("titles", tTotal)
	ME.titles	= {}
	for i=0,tTotal-1 do
		_, tid, geted			= GetTitleInfoByIndex(i)		-- name, titleID, geted, icon, classify1, classify2, note, brief, rare = GetTitleInfoByIndex( index )
		if tid>0 then
			ME.titles[tid]	= i
		end
	end
	return true
end

function ME.GetTitle(id)
	local title = RB.lang.NOTITLE
	if ME.titles[id] then
		title = GetTitleInfoByIndex(ME.titles[id])
	elseif id==DF_CA_HT_CUSPMIZE then
		title = GetCusomizeTitle()	-- misspelling is correct
	end
	return title
end

function ME.Update(event, ...)
	local dVal, dMax			= Daily_count()
	local title						= ME.GetTitle(GetCurrentTitle())

	RB.settings.titleList	= RB.settings.titleList or {}
	RB.settings.titleList[GetCurrentTitle()] = true

	RB.UpdateButtonText(ME.name,
		sprintf("%s: %s%s%s", RB.lang.DQUEST, RB.ColorByPercent(dVal, dMax, true, dVal), RB.Separator(), dMax),
		title or RB.lang.NOTITLE
	)
end

function ME.Tooltip(tooltip)
	-- titles
	local tNum, tTotal = 0, GetTitleCount()
	RB.settings.titleList	= RB.settings.titleList or {}
	for i=0,tTotal-1 do
		local name, id, flag = GetTitleInfoByIndex(i)
		tNum = tNum + (flag==true and 1 or 0)
		if RB.settings.titleList[id] then
			tooltip:AddLine(name)
		end
	end
	tooltip:AddDoubleLine(
		RB.lang.TITLE,
		sprintf("%s%s%s", RB.ColorByPercent(tNum, tTotal), RB.Separator(), RB.Dec(tTotal))
	)
	tooltip:AddSeparator()

	-- cards
	local cNum, cTotal = 0, 0
	for i=0,15 do
		local cnt = LuaFunc_GetCardMaxCount(i)
		if cnt>0 then
			cTotal	= cTotal + cnt
			for j=0,cnt-1 do
				local _,flag	= LuaFunc_GetCardInfo(i, j)
				cNum = cNum + (flag==1 and 1 or 0)
			end
		end
	end
	tooltip:AddDoubleLine(
		RB.lang.CARDS,
		sprintf("%s%s%s", RB.ColorByPercent(cNum, cTotal), RB.Separator(), RB.Dec(cTotal))
	)
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
	elseif key=="RBUTTON" then
	elseif key=="MBUTTON" then
	end
end

RB.RegisterButton("titlequest", ME)
