--======================== Social ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0, 0.125, 0.375, 0.5},
	events		= {
		"RESET_FRIEND", "UPDATE_GUILD_MEMBER", "LOADING_END",
		"PARTY_INVITE_REQUEST", "RIDE_INVITE_REQUEST", "DUEL_REQUESTED",
		"CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_WISPER",
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
		if ME.importState~=IMPORTSTATE_DONE then return end
		RB.global.friends[GetCurrentRealm()] = ME.GetFriendList()
	end

	RB.Debug("Update", event, ...)

	local gNum, gMax	= 0, IsInGuild() and GetNumGuildMembers() or 0
	local fNum, fMax	= 0, GetFriendCount(DF_Socal_Token_Friend)
	for i=1, gMax do
		local _,_,_,_,_,_,_,_,_,_,online	= GetGuildRosterInfo(i)
		gNum = gNum + (online and 1 or 0)
	end
	for i=1, fMax do
		local _,_,online	= GetFriendInfo(DF_Socal_Token_Friend, i)
		fNum = fNum + (online and 1 or 0)
	end
	if IsInGuild() then
		RB.UpdateButtonText(ME.name,
			sprintf("%s: %s%s%s", RB.lang.GUILD, RB.Dec(gNum), RB.Separator(), RB.Dec(gMax)),
			sprintf("%s: %s%s%s", RB.lang.FRIEND, RB.Dec(fNum), RB.Separator(), RB.Dec(fMax))
		)
	else
		RB.UpdateButtonText(ME.name,
			sprintf("%s: %s%s%s", RB.lang.FRIEND, RB.Dec(fNum), RB.Separator(), RB.Dec(fMax))
		)
	end
end

function ME.Tooltip(tooltip)
	local members, gMax, sep = {}, GetNumGuildMembers(), false
	if IsInGuild() then
		for i=1,gMax do
			--local name, rank, class, level, subClass, subLevel, isHeader, isCollapsed, dbid, guildTitle, IsOnLine, LogOutTime, Zone, Note = GetGuildRosterInfo(index)
			local name, _, mClass, mLevel, sClass, sLevel, _,_,_,_, online, _, map, _ = GetGuildRosterInfo(i)
			if name~=nil and online then
				members[name] = RB.ColorByClass(mClass, name)
				tooltip:AddDoubleLine(
					sprintf("%s%s%s%s%s",
						RB.ColorByClass(mClass, name), RB.Separator(),
						RB.ColorByClass(mClass, sprintf("%s%d", mClass:sub(1,1), mLevel)), sLevel>0 and RB.Separator() or "",
						sLevel>0 and RB.ColorByClass(sClass, sprintf("%s%d", sClass:sub(1,1), sLevel)) or ""
					),
					map or RB.lang.NOLOCA
				)
			end
		end
	end

	local fMax	= GetFriendCount(DF_Socal_Token_Friend)
	local list				= ""
	for i=1, fMax do
		local name, groupID, online, eachOther, unmodifiable, top, killMeCount, revengeCount, relationType, relationLv = GetFriendInfo(DF_Socal_Token_Friend, i)
		if name~=nil and online then
			list = sprintf("%s%s%s", list, #list>0 and RB.Separator() or "", members[name] or name)
		end
	end
	if #list>0 then
		tooltip:AddSeparator()
		tooltip:AddLine(sprintf("%s: %s", RB.lang.FRIENDS, list))
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleUIFrame(GuildFrame)
	elseif key=="RBUTTON" then
		ToggleSocialFrame("Friend")
	elseif key=="MBUTTON" then
	end
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
	if ME.importState>IMPORTSTATE_NONE or RB.settings.friendSync==false then return end
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

function InviteRequest(event, name)
	RB.Debug("InviteReuest", event, name)
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
			if StaticPopup1:IsVisible() then StaticPopup1:Hide() end
		end
	end
	if event=="RIDE_INVITE_REQUEST" then
		if	(RB.settings["acceptRideFriend"] and IsMyFriend(name)) or
				(RB.settings["acceptRideGuild"] and IsInMyGuild(name)) then
			AcceptRideMount()
			if StaticPopup1:IsVisible() then StaticPopup1:Hide() end
		end
	end
	if event=="DUEL_REQUESTED" and RB.settings["declineDuel"] then
		CancelDuel()
		if StaticPopup1:IsVisible() then StaticPopup1:Hide() end
	end
end

ME.PARTY_INVITE_REQUEST	= InviteRequest
ME.RIDE_INVITE_REQUEST 	= InviteRequest
ME.DUEL_REQUESTED				= InviteRequest

RB.RegisterButton("social", ME)
