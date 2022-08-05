--======================== dialogs ======================

local RB = _G.RoMBar
local ME = {
	skipDialogs							= {
		-- available options: npc (GUID), zone, pattern, button, modifier
		-- zone 400 and 401 must be defined to check - otherwise this zones will be ignored
		{npc = _glossary_00727, 	pattern = "SC_111256_DIALOG_0", replace = {["(%[$VAR%d%])"]=".*"}},	-- Der Transport nach "[$VAR1]" kostet [$VAR2] Gold. - Sturobold
		{npc = "Sys113050_name",	pattern = "SC_111256_DIALOG_0", replace = {["(%[$VAR%d%])"]=".*"}},	--  -''- - Ailics Gehilfe

		{zone = 4,		npc = 361,	pattern = "SC_423493_16"},										-- Ihr dürft eintreten ...	- Team Manager (Mysteriösen Palast betreten)
		{zone = 369,							pattern = "verlassen"},												-- Mysteriösen Bunker verlassen	- TODO check BACK_MIRRORINSTANCE_BUTTON_TIPS
		{zone = 360,							pattern = "SC_422995_1"},											-- Andor Training verlassen
		{zone = 353,	npc = 997,	pattern = C_SURE},														-- Bestätigen - Malatina Parcour des Schreckens verlassen
		{zone = 6,		npc = 42,		button = 2},																	-- Hajikar Mashes - Transport Obsidian nach Dalanis
		{zone = 15,		npc = 383,	button = 1},																	-- Arina Kaiyinth - Transport Dalanis nach Obsidian
-- 		{zone = 33,								pattern = "Z34_QUEST427360_02"},							-- Portal Wehr von Mularan nach Lager der Silberspuren
-- 		{zone = 34,								pattern = "Z34_QUEST427360_02"},							-- Portal Lager der Silberspuren nach Wehr von Mularan


		{pattern = "SC_421614_0"},																							-- Lasst mich sehen, was Ihr zu verkaufen habt ...
		{pattern = "SO_110439_0"},																							-- Ich möchte sehen, was Ihr zu verkaufen habt.
		{pattern = "SC_240181_SHOP_02"},																				-- Ich möchte die Belohnungen, die Ihr habt, sehen.
		{pattern = "SO_OPENMAIL"},																							-- Postfächer öffnen
		{pattern = "SO_OPENAC"},																								-- Auktionshaus öffnen

		{zone = 402,	pattern = "SC_BUFFTOWER_01",	replace = {["(<CS>.*</CS>)"]=""}},	-- Gildenburg-Buffs (BK)
		{zone = 402,	pattern = "Sys492712_name",		replace = {["( X)"]=""}},		-- Pferdehaltung X (BK)
		{zone = 401,	pattern = "SC_GUILDHOUSE_02", button = 0},								-- Ich möchte die Gildenburg verlassen. - dialog
		{zone = 401,	pattern = "SC_BUFFTOWER_01",	replace = {["(<CS>.*</CS>)"]=""}},	-- Gildenburg-Buffs
		{zone = 401,	pattern = "Sys492712_name",		replace = {["( X)"]=""}},		-- Pferdehaltung X
		{zone = 401,	pattern = "SO_OPENMAIL"},																	-- Gilden-Postfächer öffnen
		{pattern = "SC_GUILDHOUSE_01", button = 2},															-- Ich möchte die Gildenburg betreten.

		{zone = 400,	pattern = "HOUSE_MAID_HOUSE_CHANGEJOB",				button = 2,	modifier = "sCa"},	-- Hausmädchen inhouse - Klasse wechseln
		{zone = 400,	pattern = "HOUSE_MAID_HOUSE_CHANGEJOB",				button = 2,	modifier = "sCA"},	-- Hausmädchen inhouse - Klasse tauschen (mit ceh)
		{zone = 400,	pattern = "HOUSE_MAID_LEAVE_HOUSE",						button = 1,	modifier = "scA"},	-- Hausmädchen inhouse - Haus verlassen
		{zone = 400,	pattern = "HOUSE_MAID_HOUSE_OPENBANK", 				button = 3,	modifier = "sca"},	-- Hausmädchen inhouse - Bank öffnen
		{zone = 400,	pattern = "C_HOUSESERVANT_TALK_OPTION_VIEW",	button = 7},										-- Personal inhouse

		{pattern = "SO_ENTERHOME",	modifier = "scA"},													-- Hausmädchen outhouse - Ich möchte mein Haus betreten.
		{pattern = "SO_110581_1",		modifier = "sCa"},													-- Hausmädchen outhouse - Ich möchte meine Primär- und Sekundärklasse wechseln.
		{pattern = "SO_110581_1",		modifier = "sCA"},													-- Hausmädchen outhouse - Ich möchte meine Primär- und Sekundärklasse wechseln. - klassen tauschen
		{pattern = "SC_HOUSEBANK",	modifier = "sca"},													-- Hausmädchen outhouse - Ich möchte die Bank öffnen.
	},
}

local function GetPreparedData()
	if not ME.preparedData then
		-- prepare for faster access
		ME.preparedData = {}
		for _,v in pairs(ME.skipDialogs) do
			local pat = v.pattern and TEXT(v.pattern) or true
			if v.pattern and v.replace then
				for f,r in pairs(v.replace) do
					pat = pat:gsub(f, r)
				end
			end
			local idx  = sprintf("%s:%s", v.zone or "*", v.npc and TEXT(v.npc) or "*")
			local mod  = v.modifier and (v.modifier=="sca" and "*" or v.modifier) or "*"
			local but  = v.button or "*"
			ME.preparedData[idx]								= ME.preparedData[idx] or {}
			ME.preparedData[idx][mod]						= ME.preparedData[idx][mod] or {}
			ME.preparedData[idx][mod][but]			= ME.preparedData[idx][mod][but] or {}
			table.insert(ME.preparedData[idx][mod][but], pat)
			RB.Debug("prepared:", idx, mod, but, pat)
		end
		ME.skipDialogs = nil
	end
	return ME.preparedData
end

local function CompareData(b, t)
	local z, n1, n2, m	= GetZoneID(), UnitGUID("target") or "*", UnitName("target") or "*", RB.GetModifierStatus()
	local data, ret			= GetPreparedData()
	ret	= data[z..":"..n1] or data[z..":"..n2] or data[z..":*"] or nil
	if not ret and z~=400 and z~=401 then
		ret	= data["*:"..n1] or data["*:"..n2] or data["*:*"] or nil
	end
	RB.Debug(Arglist(true, ret))
	if ret then
		ret = ret[m] or ret["*"]
	RB.Debug(Arglist(true, ret))
		if ret then
			ret = ret[b] or ret["*"]
	RB.Debug(Arglist(true, ret))
			if ret and type(ret)=="table" then
				for _,pattern in pairs(ret) do
					if pattern==true or t==pattern or t:match(pattern) then return true end
				end
			end
		end
	end
	return false
end

local function CheckRequestDialogs(event, msg, ...)
	if RB.GetModifierStatus()=="Sca" then return end
	if RB.settings.skipDialogs==true then
		RB.Debug(ME.name, "CheckRequestDialogs", event, msg, ...)
		if CompareData(0, msg) then
			ClickRequestDialogButton(v.button or 0)
			return
		end
	end
end

local function CheckQuestListDialog(event, ...)
	if RB.GetModifierStatus()=="Sca" then return end
	local but = 0
	if RB.settings.skipDialogs==true then
		RB.Debug(ME.name, "CheckQuestListDialog", event, ...)
		for i=1,g_SpeakFrameData.count-1 do
			if g_SpeakFrameData.option[i].type==56 then
				if CompareData(i, g_SpeakFrameData.option[i].title) then
					RB.Debug("-->", g_SpeakFrameData.option[i].title)
					but = i break
				end
			end
		end
	end
	if but>0 then
		CloseWindows()
		if event=="SHOW_REQUESTLIST_DIALOG" then
			SpeakFrame_ListDialogOption(56, but)
		else
			SpeakFrame_SpeakOption(56, but)
		end
		return
	end
	-- autoquest
	if RB.settings.autoQuestComplete==true then
		if event=="SHOW_QUESTDETAIL_FROM_NPC" then
			if g_SpeakFrameData.count==2 and g_SpeakFrameData.option[1].type==3 then
				CompleteQuest()
				SpeakFrame_Hide()
			end
		elseif UnitName("target") then	-- BUG kodex-book will not open if target selected
			if GetNumQuest(3)>0 then
				OnClick_QuestListButton(3, 1)
			end
		end
	end
end

function SilentChangeLeaderChannel(event, ...)
-- GetParalleZonesInfo
-- GetNumParalleZones
-- GetNumZoneChannels
-- IsZoneChannelOnLine
-- GetCurrentParallelID

	RB.Debug(ME.name, event, ...)

	local currChannel		= GetCurrentParallelID() or 1
	local name,realChan = GetParalleZonesInfo(currChannel)		-- name, linkedChan
	if currChannel~=realChan then
		ChangeParallelID(realChan)
		CancelChangeParallelID()
		RB.CancelPopup("LEADER_CHANNEL_CONFIRM")
	end
end

function ME.Init()
-- 	RB.RegisterEvent(ME.name, {"LEADER_CHANNEL_CONFIRM", "PARTY_MEMBER_CHANGED"}, SilentChangeLeaderChannel)
	RB.RegisterEvent(ME.name, "SHOW_REQUEST_DIALOG", CheckRequestDialogs)
	RB.RegisterEvent(ME.name, {"SHOW_REQUESTLIST_DIALOG", "SHOW_QUESTLIST", "SHOW_QUESTDETAIL_FROM_NPC"}, CheckQuestListDialog)
end

RB.RegisterModule("dialogs", ME)
