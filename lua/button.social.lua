--======================== Social ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0, 0.125, 0.375, 0.5},
	events		= {
		"RESET_FRIEND", "UPDATE_GUILD_MEMBER", "PLAYER_LEVEL_UP", "LOADING_END",
		"PARTY_INVITE_REQUEST", "RIDE_INVITE_REQUEST", "DUEL_REQUESTED",
		"TRADE_REQUEST", "TRADE_ACCEPT_UPDATE",
		"CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_WISPER",
		"HOUSESFRAME_SHOW",
	},
	actions		= {
 		LBUTTON	= {func = function() ToggleUIFrame(GuildFrame) end},
		MBUTTON	= {func = function() ToggleSocialFrame("Friend") end},
	},
	importState	= 0,
}
local IMPORTSTATE_NONE = 0
local IMPORTSTATE_WORK = 1
local IMPORTSTATE_DONE = 2

function ME.Update(event, ...)

	if event=="LOADING_END" and ME.importState==IMPORTSTATE_NONE then
		RB.global.friends	= RB.global.friends or {}
		if RB.global.friends[GetCurrentRealm()] then
			ME.SetFriendList(RB.global.friends[GetCurrentRealm()])
		end
	end

	if event=="RESET_FRIEND" then
		if ME.importState==IMPORTSTATE_DONE then
			RB.global.friends[GetCurrentRealm()] = ME.GetFriendList()
		end
	end

	if event=="RESET_FRIEND" or event=="UPDATE_GUILD_MEMBER" or event=="LOADING_END" then
		ME.socialList	= ME.GetSocialList(true)
		RB.UpdateButtonText(ME.name,
			IsInGuild() and sprintf("%s: %s%s%s", RB.Lang(ME.name, "GUILD"), RB.Dec(ME.socialCount.gNum), RB.Separator(), RB.Dec(ME.socialCount.gMax)) or nil,
			sprintf("%s: %s%s%s", RB.Lang(ME.name, "FRIEND"), RB.Dec(ME.socialCount.fNum), RB.Separator(), RB.Dec(ME.socialCount.fMax))
		)
		ME.actions.RBUTTON.text			= RB.Lang(ME.name, "WISPER").."/"..RB.Lang(ME.name, "INVITE")
		ME.actions.RBUTTON.disabled	= (ME.socialCount.fNum==0 and ME.socialCount.gNum==0) and true or false
	end
end

function ME.Tooltip(tooltip)
	local friends, sep = "", false
	ME.socialList	= ME.socialList	 or ME.GetSocialList(true)
	for _,name in pairs(ME.socialListIndex) do
		local data = ME.socialList[name]
		if data.guild == true and data.online == true then
			sep = true
			RB.AddToTooltip(
				{
					RB.ColorByClass(data.pClass, name),
					RB.ColorByClass(data.pClass, ("%s%d"):format(data.pClass:sub(1,1), data.pLevel)),
					data.sLevel>0 and RB.ColorByClass(data.sClass, ("%s%d"):format(data.sClass:sub(1,1), data.sLevel)) or nil
				},
				data.location or RB.Lang(ME.name, "NOLOCATION")
			)
		end
		if data.friend == true and data.online then
			friends	= ("%s%s%s"):format(friends, #friends>0 and RB.Separator() or "", RB.ColorByClass(data.pClass, name))
		end
	end
	if not sep then
		RB.AddToTooltip(RB.Lang(ME.name, IsInGuild() and "GUILDNOONLINE" or "NOGUILD"))
	end
	RB.AddToTooltip("---")
	RB.AddToTooltip(sprintf("%s: %s", RB.Lang(ME.name, "FRIENDLIST"), #friends>0 and friends or RB.Lang(ME.name, "FRIENDNOONLINE")))
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
	elseif key=="RBUTTON" then
		RB.modules.dropdown.ShowDropDown(tooltip, ME.DropDownHandler)
	elseif key=="MBUTTON" then
	end
end

function ME.DropDownHandler()
	local DD 		= RB.modules.dropdown
	for _,name in pairs(ME.socialListIndex) do
		local data = ME.socialList[name]
		if name~=UnitName("player") then
			if (UIDROPDOWNMENU_MENU_LEVEL or 1)==1 then
				if data.online then
					DD.AddMenu(RB.ColorByClass(data.pClass, name), name)
				end
			elseif UIDROPDOWNMENU_MENU_LEVEL==2 then
				if name==UIDROPDOWNMENU_MENU_VALUE then
					DD.AddButton(RB.Lang(ME.name, "WISPER"), function(this) ChatFrame_SendTell(UIDROPDOWNMENU_MENU_VALUE) CloseDropDownMenus() end)
					DD.AddButton(RB.Lang(ME.name, "INVITE"), function(this) InviteByName(UIDROPDOWNMENU_MENU_VALUE) CloseDropDownMenus() end)
				end
			end
		end
	end
end

function ME.GetSocialList(forceUpdate)
	if not ME.socialList or forceUpdate==true then
		RB.Debug(ME.name, "updating social list")
		local fMax, gMax, i	= GetFriendCount(DF_Socal_Token_Friend), GetNumGuildMembers(DF_Socal_Token_Friend)
		ME.socialList				= {}
		ME.socialListIndex	= {}
		ME.socialCount			= {fNum = 0, fMax = fMax, gNum = 0, gMax = gMax}
		if IsInGuild() then
			for i=1, gMax do
				local name, rank, pClass, pLevel, sClass, sLevel, isHeader, isCollapsed, dbid, guildTitle, online, logOutTime, location, note = GetGuildRosterInfo(i)
				if name and name~="" then
					ME.socialCount.gNum	= ME.socialCount.gNum + (online and 1 or 0)
					ME.socialList[name]	= {guild = true, friend = false, online = online, pClass = pClass, pLevel = pLevel, sClass = sClass, sLevel = sLevel, location = location}
					table.insert(ME.socialListIndex, name)
				end
			end
		end
		for i=1, fMax do
			local name, groupID, online, eachOther, unmodifiable, top, killMeCount, revengeCount, relationType, relationLv = GetFriendInfo(DF_Socal_Token_Friend, i)
			if name and name~="" then
				ME.socialCount.fNum	= ME.socialCount.fNum + (online and 1 or 0)
				if ME.socialList[name]~=nil then
					ME.socialList[name].friend = true
				else
					ME.socialList[name]	= {guild = false, friend = true, online = online, pClass = "unknown", pLevel = 0, sClass = "unknown", sLevel = 0}
					table.insert(ME.socialListIndex, name)
				end
			end
		end
		table.sort(ME.socialListIndex)
	end
	return ME.socialList
end

function ME.GetFriendList()
	local friends, groups	= {}, {}
	local fMax, gMax			= GetFriendCount(DF_Socal_Token_Friend), GetSocalGroupCount(DF_Socal_Token_Friend)
	for i=1, gMax do
		local gID, name	= GetSocalGroupInfo(DF_Socal_Token_Friend, i)
		groups[gID]			= name
	end

	for i=1,fMax do
		local name, gID	= GetFriendInfo(DF_Socal_Token_Friend, i)
		if name then friends[name] = groups[gID] end
	end
	if UnitName("player") then
		friends[UnitName("player")] = GetAccountName()
	end
	return friends
end

function ME.SetFriendList(list)
	if ME.importState>IMPORTSTATE_NONE then return end
	if RB.settings.friendSync==false then ME.importState = IMPORTSTATE_DONE return end
	ME.importState = IMPORTSTATE_WORK
	RB.Debug("start friend import")
	refreshGroups = function()
		local tmp = {}
		for i=1, GetSocalGroupCount(DF_Socal_Token_Friend) do
			local gID, name	= GetSocalGroupInfo(DF_Socal_Token_Friend, i)
			tmp[name]		= gID
		end
		return tmp
	end
	local localFriends		= ME.GetFriendList()
	local groups					= refreshGroups()
	for name, group in pairs(list) do
		if name~=UnitName("player") then
			if not IsMyFriend(name) then
				AddFriend(DF_Socal_Token_Friend, name)
			end
			if groups[group]==nil then
				AddSocalGroup(DF_Socal_Token_Friend, group)
				groups = refreshGroups()
			end
			SetFriendGroup(DF_Socal_Token_Friend, name, groups[group])
		end
	end
	for name,_ in pairs(localFriends) do
		if name~=UnitName("player") then
			if IsMyFriend(name) and list[name]==nil then
				DelFriend(DF_Socal_Token_Friend, name)
			end
		end
	end
	ME.importState = IMPORTSTATE_DONE
end

function ME.HOUSESFRAME_SHOW()
	if not Houses_IsOwner() or RB.settings.autoHouseFriend==false then return end
	local _, error	= loadfile(sprintf("%s/personal.lua", RB.addonPath))
	if not error then
		local data	= dofile(sprintf("%s/personal.lua", RB.addonPath))
		local merge	= data.myTwinks or {}
		merge[UnitName("player")] = nil
		for i=1,Houses_GetFriendCount() do
			local name 	= Houses_GetFriendInfo(i)
			if merge[name] then merge[name] = nil end
		end
		for name in pairs(merge) do
			Houses_AddFriend(name)
		end
	end
end

function ChatBeep(event)
	if event=='CHAT_MSG_GUILD' and RB.settings.beepGuild==true then
		PlaySoundByPath(sprintf("%s/sounds/%s", RB.addonPath, "guild.mp3"))
	elseif event=='CHAT_MSG_PARTY' and RB.settings.beepParty==true then
		PlaySoundByPath(sprintf("%s/sounds/%s", RB.addonPath, "party.mp3"))
	elseif event=='CHAT_MSG_WHISPER' and RB.settings.beepWisper==true then
		PlaySoundByPath(sprintf("%s/sounds/%s", RB.addonPath, "wisper.mp3"))
	end
end

ME.CHAT_MSG_GUILD		= ChatBeep
ME.CHAT_MSG_PARTY		= ChatBeep
ME.CHAT_MSG_WHISPER	= ChatBeep

function HandleRequest_OnUpdate(elapsedTime)
	RB.UnregisterEvent(ME.name, "ONUPDATE")
	AgreeTrade()
end

function HandleRequest(event, ...)
	local name, arg1, arg2 = select(1,...), select(1,...), select(2,...)
	RB.Debug("HandleRequest", event, arg1, arg2)
	local function IsInMyGuild(name)
		for i=1, GetNumGuildMembers() do
			local guildi = GetGuildRosterInfo(i)
			if name == guildi then return true end
		end
		return false
	end
	if event=="PARTY_INVITE_REQUEST" then
		if (RB.settings["acceptPartyFriend"] and IsMyFriend(name)) or
			(RB.settings["acceptPartyGuild"] and IsInMyGuild(name)) then
			AcceptGroup()
			RB.CancelPopup("PARTY_INVITE_REQUEST")
		end
	end
	if event=="RIDE_INVITE_REQUEST" then
		if	(RB.settings["acceptRideFriend"] and IsMyFriend(name)) or
				(RB.settings["acceptRideGuild"] and IsInMyGuild(name)) then
			AcceptRideMount()
			RB.CancelPopup("RIDE_INVITE_REQUEST")
		end
	end
	if event=="TRADE_REQUEST" then
		if	(RB.settings["acceptTradeFriend"] and IsMyFriend(name)) or
				(RB.settings["acceptTradeGuild"] and IsInMyGuild(name)) or
				(RB.settings["acceptTradeGroup"] and (InPartyByName(name) or InRaidByName(name))) then
			RB.RegisterEvent(ME.name, "ONUPDATE", HandleRequest_OnUpdate)
			RB.CancelPopup("TRADE")
		end
	end
	if event=="TRADE_ACCEPT_UPDATE" then
		for i=1,8 do
			_, name = GetTradePlayerItemInfo(i);
			if name then return end
		end
		if GetTradePlayerMoney()>0 then return end
		if (arg1 == 0 and arg2 == 1) or (arg1 == 1 and arg2 == 2) then
			RB.Debug("AcceptTrade", arg1, arg2)
			AcceptTrade("")
		end
	end
	if event=="DUEL_REQUESTED" and RB.settings["declineDuel"] then
		CancelDuel()
		RB.CancelPopup("DUEL_REQUESTED")
	end
end

ME.PARTY_INVITE_REQUEST	= HandleRequest
ME.RIDE_INVITE_REQUEST 	= HandleRequest
ME.TRADE_REQUEST 				= HandleRequest
ME.TRADE_ACCEPT_UPDATE	= HandleRequest
ME.DUEL_REQUESTED				= HandleRequest

RB.RegisterButton("social", ME)
