--======================== Quest ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0, 0.125, 0.125, 0.25},
	events		= {"LOADING_END", "RESET_QUESTTRACK", "PLAYER_TITLE_ID_CHANGED", "ELITE_BOSS_BELL"},
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
	local title, icon, text = RB.Lang(ME.name, "NOTITLE"), "interface/icons/quest_paperstack03", ""
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
		{sprintf("%s: %s", RB.Lang(ME.name, "DAILY_SHORT"), RB.ColorByPercent(dVal, dMax, true, dVal)), dMax},
		title
	)
end

function ME.ELITE_BOSS_BELL(event, msg, ...)
	if RB.settings.bossBell==true then
		RB.Debug(ME.name, event, msg, ...)
		local m				= GetCurrentWorldMapID()
		local x, y		= GetPlayerWorldMapPos(m)
		local object	= {
			name		= msg:gsub("Ihr seid(.*)schon sehr nahe gekommen. Seid bitte vorsichtig!", "%1"),
			x				= math.floor(1000*x)/10,
			y				= math.floor(1000*y)/10,
			zone		= GetZoneName(),
			channel	= GetCurrentParallelID() or 1,
		}
		object.name = object.name:match("^[%s%c]*(.-)[%s%c]*$")
		if object.name and object.name~="" then
			SendChatMessage(RB.Format(RB.Lang(ME.name, "BOSS_BELL"), object), "guild")
		end
	end
end

function ME.Tooltip(tooltip)
	-- titles
	local tNum, tTotal = 0, GetTitleCount()
	for i=0,tTotal-1 do
		_,_,geted			= GetTitleInfoByIndex(i)		-- name, titleID, geted, icon, classify1, classify2, note, brief, rare = GetTitleInfoByIndex( index )
		tNum = tNum + (geted and 1 or 0)
	end
	tooltip:AddDoubleLine(
		RB.Lang(ME.name, "TITLES"),
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
		RB.Lang(ME.name, "CARDS"),
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
		DD.AddTitle(RB.Lang(ME.name, "TITLE"))
		DD.AddCheckBox(RB.Lang(ME.name, "NOTITLE"), not GetCurrentTitle(), 0, ChangeTitle)
		RB.settings.titleList	= RB.settings.titleList or {}
		for id,_ in pairs(RB.settings.titleList) do
			DD.AddCheckBox(ME.GetTitle(id), GetCurrentTitle()==id, id, ChangeTitle)
		end
	end
end

RB.RegisterButton("titlequest", ME)