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
	if tTotal>0 then
		RB.Debug("titles", tTotal)
		ME.titles	= {}
		for i=0, tTotal do
			_,tid	= GetTitleInfoByIndex(i)		-- name, titleID, geted, icon, classify1, classify2, note, brief, rare = GetTitleInfoByIndex( index )
			if tid and tid>0 then
				ME.titles[tid]	= i
			end
		end
	end
	return true
end

function ME.GetTitle(id)
	local title, icon, text = RB.lang.NOTITLE, "interface/icons/quest_paperstack03", ""
	if ME.titles[id] then
		local name,_,geted,ico,classify1,classify2,note,brief,rare = GetTitleInfoByIndex(ME.titles[id])
		if geted then
			if name=="???" then
				AchievementTitleFrame:Show()
				AchievementTitleFrame:Hide()
				name,_,geted,ico,classify1,classify2,note,brief,rare = GetTitleInfoByIndex(ME.titles[id])
			end
			title = name
			icon	= ico
			text	= note
		end
	elseif id==DF_CA_HT_CUSPMIZE then
		title = GetCusomizeTitle()	-- misspelling is correct
	end
	return title, icon, text
end

function ME.Update(event, ...)
	local dVal, dMax			= Daily_count()
	local title						= ME.GetTitle(GetCurrentTitle())

	RB.settings.titleList	= RB.settings.titleList or {}
	if GetCurrentTitle()>0 then
		RB.settings.titleList[GetCurrentTitle()] = true
	end

	RB.UpdateButtonText(ME.name,
		sprintf("%s: %s%s%s", RB.lang.DQUEST, RB.ColorByPercent(dVal, dMax, true, dVal), RB.Separator(), dMax),
		title
	)
end

function ME.Tooltip(tooltip)
	-- titles
	local tNum, tTotal = 0, GetTitleCount()
	for i=0,tTotal-1 do
		_,_,geted			= GetTitleInfoByIndex(i)		-- name, titleID, geted, icon, classify1, classify2, note, brief, rare = GetTitleInfoByIndex( index )
		tNum = tNum + (geted and 1 or 0)
	end
	tooltip:AddDoubleLine(
		RB.lang.TITLE,
		sprintf("%s%s%s", RB.ColorByPercent(tNum, tTotal), RB.Separator(), RB.Dec(tTotal))
	)
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
		RB.modules.dropdown.ShowDropDown(tooltip, ME.DropDownHandler)
	elseif key=="RBUTTON" then
	elseif key=="MBUTTON" then
	end
end

local function ChangeTitle(this)
	local id = this.value
	SetTitleRequest(this.value)
	CloseDropDownMenus()
end

function ME.DropDownHandler()
	local DD = RB.modules.dropdown
	if (UIDROPDOWNMENU_MENU_LEVEL or 1)==1 then
		DD.AddTitle(RB.lang[ME.name:upper().."_TITLE"])
		DD.AddCheckBox(RB.lang.NOTITLE, not GetCurrentTitle(), 0, ChangeTitle)
		RB.settings.titleList	= RB.settings.titleList or {}
		for id,_ in pairs(RB.settings.titleList) do
			DD.AddCheckBox(ME.GetTitle(id), GetCurrentTitle()==id, id, ChangeTitle)
		end
	end
end

RB.RegisterButton("titlequest", ME)
