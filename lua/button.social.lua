--======================== Social ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0, 0.125, 0.375, 0.5},
	events		= {
		"RESET_FRIEND", "UPDATE_GUILD_MEMBER",
		"PARTY_INVITE_REQUEST", "RIDE_INVITE_REQUEST", "DUEL_REQUESTED",
		"CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_WISPER",
	},
}

function ME.Update(event, ...)
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
	RB.UpdateButtonText(ME.name,
		IsInGuild() and sprintf("%s: %s%s%s", RB.lang.GUILD, RB.Dec(gNum), RB.Separator(), RB.Dec(gMax)) or RB.lang.NOGUILD,
		sprintf("%s: %s%s%s", RB.lang.FRIEND, RB.Dec(fNum), RB.Separator(), RB.Dec(fMax))
	)
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

function ME.Init()
	if RB.global.friends and RB.global.friends[GetCurrentRealm()] then
		ME.SetFriendList(RB.global.friends[GetCurrentRealm()])
	end
	RB.global.friends[GetCurrentRealm()]	= ME.GetFriendList()
	return true
end

local OrigAddFriend = RB.Hook(_G, "AddFriend", function(type, name)
	RB.Print("adding "..name.." to friendlist")
	RB.global.friends = RB.global.friends or {}
	RB.global.friends[GetCurrentRealm()]	= ME.GetFriendList()
	RB.GetOriginalFunction(_G, "AddFriend")(type, name)
end)

local OrigDelFriend = RB.Hook(_G, "DelFriend", function(type, name)
	RB.Print("removing "..name.." from friendlist")
	RB.global.friends = RB.global.friends or {}
	RB.global.friends[GetCurrentRealm()]	= ME.GetFriendList()
	RB.GetOriginalFunction(_G, "DelFriend")(type, name)
end)

function ME.GetFriendList()
	local friends, acc	= {_groups = {}}, 0
	local fMax, gMax		= GetFriendCount(DF_Socal_Token_Friend), GetSocalGroupCount(DF_Socal_Token_Friend)
	for i=0,gMax do
		local gID,name		= GetSocalGroupInfo(DF_Socal_Token_Friend, i)
		if gID and name then
			friends._groups[gID] = name
			if name==GetAccountName() then acc = gID end
		end
	end
	for i=1,fMax+1 do
		local name,gID	= GetFriendInfo(DF_Socal_Token_Friend, i)
		if name then friends[name] = gID end
	end
	if UnitName("player") then
		friends[UnitName("player")] = acc>0 and acc or (gMax+1)
	end
	return friends
end

function ME.SetFriendList(list)
-- 	if ME.imported == true or RB.settings.friendSync==false then return end
-- 	local localFriends		= ME.GetFriendList()
--
-- 	local globalFriends		= RB.global.friends[GetCurrentRealm()] or {}
-- 	local fMax, add, del	= GetFriendCount(DF_Socal_Token_Friend), {}, {}
-- 	for name,gID in pairs(globalFriends) do
-- 		if name~="_groups" and name~=UnitName("player") then
-- 			if not IsMyFriend(name) then
-- 				todo[name]			= "add"
-- 			end
-- 			localFriends[name] = globalFriends[name]
-- 		end
-- 	end
-- 	for name,gID in pairs(localFriends) do
-- 		if name~="_groups" and name~=UnitName("player") then
-- 			if IsMyFriend(name) and globalFriends[name]==nil then
-- 				todo[name]			= "del"
-- 			end
-- 		end
-- 	end
-- 	for name,todo in pairs(todoList) do
-- 		if todo=="add" then
-- 			OrigAddFriend(DF_Socal_Token_Friend, name)
-- 		elseif todo=="del" then
-- 			OrigDelFriend(DF_Socal_Token_Friend, name)
-- 		end
-- 	end
-- 	ME.imported = true;
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
