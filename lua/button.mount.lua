--======================== Quest ======================

local RB = _G.RoMBar
local ME = {
	icon			= RB.addonPath.."/textures/SaddleGrey",
	events		= {"LOADING_END", "ZONE_CHANGED", "UNIT_BUFF_CHANGED", "PLAYER_BAG_CHANGED", "EXCHANGECLASS_CLOSED", "PLAYER_ALIVE"},
	mounts		= {},
	numMounts	= 0,
}

local mountPattern	= {"charger", "mount", "skill_kni5"}
local rentalTicket	= {203033, 205821}

local function IsMountableZone()
	return (GetZoneID()<=100 or GetZoneID()>400) and true or false
end

local function HasTicket()
	for _,v in pairs(rentalTicket) do
		if GetBagItemCount(v)>0 then
			return true
		end
	end
	return false
end

local function IsMounted()
	local i = 0
	repeat i = i + 1
		local name, icon = UnitBuff("player",i)
		if name and icon then
			for _,pattern in pairs(mountPattern) do
				if icon:find(pattern) then
					return true, i, icon
				end
			end
		end
	until not name or name==""
	return false, 0, nil
end

local function GetRandomMount()
	local tmp = {}
	if ME.numMounts>0 then
		for icon in pairs(ME.mounts) do
			tmp[#tmp+1]	= icon
		end
		return tmp[math.random(1,#tmp)]
	else
		return nil
	end
end

local function UpdateIcon()
	local oldIcon = ME.icon
	local mounted, buffID, icon 	= IsMounted()
	if not IsMountableZone() then
		ME.icon											= RB.addonPath.."/textures/SaddleGrey"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "NORIDE")
		ME.actions.RBUTTON.disabled	= true
	elseif mounted then
		ME.icon											= icon:gsub("\\", "/")
		RB.settings.lastMount				= ME.icon
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "DISMOUNT")
		ME.actions.RBUTTON.disabled = true
	elseif ME.numMounts>0 then
		ME.icon 										= RB.addonPath.."/textures/Saddle"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "MOUNT")
		ME.actions.RBUTTON.disabled = false
	elseif HasTicket() then
		ME.icon 										= RB.addonPath.."/textures/HorseRentalTicket"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "RENTAL")
		ME.actions.RBUTTON.disabled = true
	else
		ME.icon											= RB.addonPath.."/textures/SaddleGrey"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "NOMOUNT")
		ME.actions.RBUTTON.disabled	= true
	end
	if oldIcon~=ME.icon then
		RB.UpdateButtonIcon(ME.name)
	end
end

local function ScanBags()
	ME.mounts, ME.numMounts	= {}, 0
	local slot = 0
	for slot = 1,10 do
		for _,pattern in pairs(mountPattern) do
			local icon, id, name = PartnerFrame_GetPartnerInfo(2, slot)
			if name and icon and icon:find(pattern) then
				ME.mounts[icon]	= {bag = "pf", id = slot, name = name, icon = icon}
				ME.numMounts = ME.numMounts + 1
			end
		end
	end
	for slot = 1,60 do
		for _,pattern in pairs(mountPattern) do
			local icon, name = GetGoodsItemInfo(slot)
			if name and icon and icon:find(pattern) then
				ME.mounts[icon]	= {bag = "isb", id = slot, name = name, icon = icon}
				ME.numMounts = ME.numMounts + 1
			end
		end
	end
	local _,bTotal = GetBagCount()
	for slot = 1,bTotal do
		for _,pattern in pairs(mountPattern) do
			local slot, icon, name = GetBagItemInfo(slot)
			if name and icon and icon:find(pattern) then
				ME.mounts[icon]	= {bag = "bag", id = slot, name = name, icon = icon}
				ME.numMounts = ME.numMounts + 1
			end
		end
	end
	UpdateIcon()
end

local function Dismount()
	local mounted, buffNum, icon = IsMounted()
	if mounted then CancelPlayerBuff(buffNum) end
	UpdateIcon()
end

local function UseTicket()
	for _,v in pairs(rentalTicket) do
		if GetBagItemCount(v)>0 then
			UseItemByName(TEXT("Sys"..v.."_name"))
			break
		end
	end
	ScanBags()
end

local function Mount(mount)
	local mounted, buffNum, icon = IsMounted()
	RB.Debug("mount", icon, mount)
	if icon==mount then return end
	if ME.numMounts<=0 and HasTicket() then UseTicket() end
	if ME.numMounts<=0 then return end
	if not ME.mounts[mount] then mount = GetRandomMount() end

	if ME.mounts[mount].bag=="pf" then
		PartnerFrame_CallPartner(2, ME.mounts[mount].id)
	else
		UseItemByName(ME.mounts[mount].name)
	end
	RB.settings.lastMount	= mount
	UpdateIcon()
end

function ME.Update(event, arg1, ...)
	if event=="UNIT_BUFF_CHANGED" and arg1~="player" then return end
	ScanBags()
	if event=="PLAYER_ALIVE" or event=="EXCHANGECLASS_CLOSED" or event=="LOADING_END" then
		if IsMountableZone() then
			Mount(RB.settings.lastMount or GetRandomMount())
		end
	end
end

function ME.Tooltip(tooltip)
	if ME.numMounts>0 then
		for icon,mount in pairs(ME.mounts) do
			tooltip:AddLine(mount.name)
		end
		tooltip:AddSeparator()
	end
	for k,v in pairs(rentalTicket) do
		local cBag, cBank	= GetBagItemCount(v), RB.GetBankItemCount(v)
		tooltip:AddDoubleLine(
			RB.ColorByRarity(v, TEXT("Sys"..v.."_name")),
			sprintf("%s%s%s", RB.Dec(cBag), cBag>0 and cBank>0 and RB.Separator() or "", cBank>0 and RB.Dec(cBank) or "")
		)
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		if IsMountableZone() then
			tooltip:Hide()
			if IsMounted() then Dismount() else Mount(RB.settings.lastMount or GetRandomMount()) end
		end
	elseif key == "RBUTTON" then
		if IsMountableZone() then
			tooltip:Hide()
			Mount(GetRandomMount())
		end
	elseif key=="MBUTTON" then
	end
end

RB.RegisterButton("mount", ME)
