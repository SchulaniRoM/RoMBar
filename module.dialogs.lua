--======================== dialogs ======================

local RB = _G.RoMBar
local ME = {
	skipDialogs							= {
		-- TODO localize
		-- available options: npc, zone, pattern, button, modifier
		{npc = _glossary_00727, pattern = "Der Transport nach .* kostet"},			-- Sturobold
		{npc = "Ailics Gehilfe", pattern = "Der Transport nach .* kostet"},			-- Sturobold
		{npc = 361, zone = 4, pattern = "eintreten"},														-- Team Manager (Mysteriösen Palast betreten)
		{zone = 369, pattern = "verlassen"},																		-- Mysteriösen Bunker verlassen
		{zone = 360, pattern = "zurückkehren"},																	-- Andor Training verlassen
		{zone = 401, pattern = "Gildenburg verlassen", button = 0},							-- Gildenburg verlassen
		{pattern = "die Gildenburg betreten", button = 2},											-- Gildenburg betreten
		{zone = 353, npc = 997, pattern = "Bestätigen"},												-- Malatina Parcour des Schreckens verlassen
		{pattern = "was Ihr zu verkaufen habt"},																-- skip all merchant dialogs
		{pattern = "Ich möchte die Belohnungen"},																-- skip most special merchant dialogs
		{npc = 42, zone = 6, button = 2},																				-- Hajikar Mashes - Obsidian nach Dalanis
		{npc = 383, zone = 15, button = 1},																			-- Arina Kaiyinth - Dalanis nach Obsidian
		{zone = 401, pattern = "-Buff erhalten"},																-- Gildenburg-Buffs
		{pattern = "Postfach öffnen"},																					-- Postfächer öffnen
		{pattern = "Auktionshaus öffnen"},																			-- Auktionshäuser öffnen
		{zone = 400, pattern = "Klasse ändern", button = 2, modifier = "C"},		-- Hausmädchen inhouse - Klasse wechseln
		{zone = 400, pattern = "Haus verlassen", button = 1, modifier = "A"},		-- Hausmädchen inhouse - Haus verlassen
		{zone = 400, pattern = "Bank öffnen", button = 3, modifier = "ca"},			-- Hausmädchen inhouse - Bank öffnen
		{zone = 400, pattern = "Attribute", button = 7},												-- Hausmädchen inhouse
		{pattern = "klasse wechseln", button = 3, modifier = "C"},							-- Hausmädchen outhouse - Klasse wechseln
		{pattern = "Haus betreten", button = 1, modifier = "A"},								-- Hausmädchen outhouse - Haus betreten
		{pattern = "Bank öffnen.", button = 5, modifier = "ca"},								-- Hausmädchen outhouse - Bank öffnen
	},
}

local function CheckModifier(mod)
	local mod 		= tostring(mod)
	local a, c, s	= IsAltKeyDown(), IsCtrlKeyDown(), IsShiftKeyDown()
	if mod:match("A")=="A" and not a then return false end
	if mod:match("a")=="a" and a then return false end
	if mod:match("C")=="C" and not c then return false end
	if mod:match("c")=="c" and c then return false end
	if mod:match("S")=="S" and not s then return false end
	if mod:match("s")=="s" and s then return false end
	return true
end

local function CheckRequestDialogs(event, msg, ...)
	if CheckModifier("S") then return end
	RB.Debug(ME.name, "CheckRequestDialogs", event, msg, ...)
	if RB.settings.skipDialogs==true then
		for k,v in pairs(ME.skipDialogs) do
			local zOK, nOK, mOK = false, false, false
			if not v.zone or GetZoneID()==v.zone then zOK = true end
			if not v.npc or (UnitGUID("target")==tonumber(v.npc) or UnitName("target")==tostring(v.npc)) then nOK = true end
			if not v.modifier or CheckModifier(v.modifier) then mOK = true end
			if zOK and nOK and mOK then
				if not v.pattern or (msg and msg:match(v.pattern)) then
					ClickRequestDialogButton(v.button or 0)
					return
				end
			end
		end
	end
end

local function CheckQuestListDialog(event, ...)
	if CheckModifier("S") then return end
	RB.Debug(ME.name, "CheckQuestListDialog", event, ...)
	if RB.settings.skipDialogs==true then
		for k,v in pairs(ME.skipDialogs) do
			local zOK, nOK, mOK, pOK, but = false, false, false, false, 0
			if not v.zone or GetZoneID()==v.zone then zOK = true end
			if not v.npc or (UnitGUID("target")==tonumber(v.npc) or UnitName("target")==tostring(v.npc)) then nOK = true end
			if not v.modifier or CheckModifier(v.modifier) then mOK = true end
			if zOK and nOK and mOK then
				if not v.pattern and not v.button then
					pOK = true but = 1
				else
					local start,stop = math.max(v.button or 1, 1), v.button~=nil and start or (g_SpeakFrameData.count-1)
					for i=start,stop do
						if g_SpeakFrameData.count>=i and g_SpeakFrameData.option[i].type==56 then
							if not v.pattern or g_SpeakFrameData.option[i].title:match(v.pattern) then pOK = true end
							if not v.button or v.button==i then but = i end
						end
					end
				end
				if pOK and but>0 then
					RB.Debug(ME.name, "found something", v.zone, v.npc, v.pattern, v.button, v.modifier)
					CloseWindows()
					if event=="SHOW_REQUESTLIST_DIALOG" then
						SpeakFrame_ListDialogOption(56, but)
					else
						SpeakFrame_SpeakOption(56, but)
					end
					return
				end
			end
		end
	end
	if RB.settings.autoQuestComplete==true then
		if event=="SHOW_QUESTDETAIL_FROM_NPC" then
			if g_SpeakFrameData.count==2 and g_SpeakFrameData.option[1].type==3 then
				CompleteQuest()
				SpeakFrame_Hide()
			end
		else
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
-- 		if StaticPopupDialogs["LEADER_CHANNEL_CONFIRM"]:IsVisible() then
-- 			ClickRequestDialogButton(1)
-- 		end
	end
end

function ME.Init()
	RB.RegisterEvent(ME.name, {"LEADER_CHANNEL_CONFIRM", "PARTY_MEMBER_CHANGED"}, SilentChangeLeaderChannel)
	RB.RegisterEvent(ME.name, "SHOW_REQUEST_DIALOG", CheckRequestDialogs)
	RB.RegisterEvent(ME.name, {"SHOW_REQUESTLIST_DIALOG", "SHOW_QUESTLIST", "SHOW_QUESTDETAIL_FROM_NPC"}, CheckQuestListDialog)
end

RB.RegisterModule("dialogs", ME)
