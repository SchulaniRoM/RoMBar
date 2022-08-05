--======================== Macro ======================

local RB = _G.RoMBar
local ME = {
	exports		= {
		"HasBuff",
		"HasDebuff",
		"HasQuest",
		"IsCasting",
		"RB_Kitty",
		"NextTarget",
		"TargetNearestEnemy",
		"TargetUnitByName",
		"FocusUnitByName",
		"UnitIsCasting",
		"MacroCD",
		"UseItem",
		"GetNextFreeBagSlot",
	},
	macroSlots	= {},
	npcData = {	-- some usefull npc positions
		[178]			= { name = "Schwarzes Brett von Logar",							friendly = true,	zone = 1,		xPos = 0.5132465363,	yPos = 0.4033938944 },
		[162]			= { name = "Meydo",																	friendly = true,	zone = 1,		xPos = 0.5261850357,	yPos = 0.4194592834 },
		[198]			= { name = "Cid",																		friendly = true,	zone = 1,		xPos = 0.5164897442,	yPos = 0.4325945973 },
		[366]			= { name = "Dell",																	friendly = true,	zone = 1,		xPos = 0.5106179118,	yPos = 0.4246239364 },
		[313]			= { name = "Schwarzes Brett im Harf-Handelsposten",	friendly = true,	zone = 5,		xPos = 0.4659762383,	yPos = 0.2174482346 },
		[398]			= { name = "Tanilof",																friendly = true,	zone = 5,		xPos = 0.4760056734,	yPos = 0.2194341868 },
		[611]			= { name = "Anthony Taz",														friendly = true,	zone = 22,	xPos = 0.4723008573,	yPos = 0.5794661045 },
	},
}

function ME.Init()
	for _,func in pairs(ME.exports) do
		if ME[func] then
			if _G[func] then
				RB.Hook(_G, func, ME[func])
			else
				_G[func] = ME[func]
			end
		end
	end
end

--[[----------------------------------------------------------------------------------------------

checking buffs and debuffs by ID or name

* syntax:
		HasBuff(ID or name, [target])
		HasDebuff(ID or name, [target])

* returns:
		pos 		- position of the buff in the bufflist
		name		- full name of the buff/debuff
		id			- id of the buff/debuff
		count		- number of stacks
		params	- additional params given by the system

* examples:
		HasBuff(12345)										- check if player has a buff with the given id
		HasBuff("mybuffname", "target")		- check if target has a buff with the given name

--]]----------------------------------------------------------------------------------------------

local function CheckBuff(ID_Name, debuff, target)
	local t, n, d		= target or "player", 0, debuff==true or false
	local id, name	= type(ID_Name)=="number" and ID_Name or nil, type(ID_Name)=="string" and ID_Name or nil
	repeat n = n + 1
		local _name, _icon, _count, _id, _params = d and UnitDebuff(t, n) or UnitBuff(t, n)
		if _name and (_id==id or _name==name) then
			return n, _name, _id, _count, _params
		end
	until not _id or n>40
	return 0, nil, nil, nil, nil
end

function ME.HasDebuff(ID_Name, target)
	return CheckBuff(ID_Name, true, target)
end

function ME.HasBuff(ID_Name, target)
	return CheckBuff(ID_Name, false, target)
end

--[[----------------------------------------------------------------------------------------------

checking quest by ID

* syntax:
		HasQuest(QuestID)

* returns:
		true/false

--]]----------------------------------------------------------------------------------------------

function ME.HasQuest(id)
	for i=1,30 do
		if select(9, GetQuestInfo(i)) == id then
			return true
		end
	end
	return false
end

--[[----------------------------------------------------------------------------------------------

check if you or your target is casting

* syntax:
		UnitIsCasting([pattern], [target])

* returns:
		true/false

* examples:
		if UnitIsCasting() then ...											- checks if player is casting anything
		if UnitIsCasting(nil, "target") then ...				- checks if target is casting anything
		if UnitIsCasting("castName", "target") then ...	- checks if your target is casting a cast containing "castName"


--]]----------------------------------------------------------------------------------------------

function ME.UnitIsCasting(pattern, target)
	local trgt = target or "player"
	local cast, tTime, cTime = UnitCastingTime(target)
	if cast and cast~="" and cTime<tTime then
		if pattern and pattern~="" then
			if cast==pattern or string.find(cast, pattern) then
				return true
			end
		else
			return true
		end
	end
	return false
end

--[[----------------------------------------------------------------------------------------------

replacement for TargetNearestEnemy - first targets enemy that are attacking you

* syntax:
		TargetNearestEnemy(reverseOrder)

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

function ME.TargetNearestEnemy(reverse)
	local orig,first = RB.GetOriginalFunction(_G, "TargetNearestEnemy"), 0
	for i=1,20 do
		orig(reverse)
		if UnitName("target") and not UnitIsDeadOrGhost("target") then
			if i==1 then
				first = UnitGUID("target")
			elseif UnitGUID("target")==first then
				break
			end
			if UnitName("targettarget")==UnitName("player") then
				break
			end
		end
	end
end

--[[----------------------------------------------------------------------------------------------

target a unit by its name if in range and targetable

* syntax:
		TargetUnitByName(pattern, [friendly])

* returns:
		true/false

--]]----------------------------------------------------------------------------------------------

local function CheckName(pattern, target)
	target = target or "target"
	if type(pattern)~="table" then pattern = {pattern} end
	if UnitName(target) then
		for _,pat in pairs(pattern) do
			if UnitName(target)==tostring(pat) or UnitName(target):find(tostring(pat)) then
-- RB.Print("found:", UnitName(target))
				return true
			end
		end
	end
	return false
end

function ME.TargetUnitByName(pattern, friendly)
	local i, first = 0, nil
	repeat i = i + 1
		if UnitName("target") then
			first = first or UnitGUID("target")
-- 			RB.Print("'"..tostring(UnitName("target")).."'", UnitGUID("target"))
			if CheckName(pattern, "target") then return true end
		end
		if friendly==true then TargetNearestFriend() else TargetNearestEnemy() end
	until not UnitName("target") or first==UnitGUID("target") or i>=30
-- RB.Print("not found")
	TargetUnit()
	return false
end

--[[----------------------------------------------------------------------------------------------

target a unit by its name if in range and targetable and puts it to the next free focus-slot

* syntax:
		FocusUnitByName(pattern, [friendly])

* returns:
		focus-id or false

--]]----------------------------------------------------------------------------------------------

function ME.FocusUnitByName(pattern, friendly)
	local i
	for i=1,12 do
		if UnitName("focus"..i)==nil then
			break
		elseif CheckName(pattern, "focus"..i) then
			TargetUnit("focus"..i)
			return i
		end
	end
	if TargetUnitByName(pattern, friendly) then
		FocusUnit(i, "target")
		return i
	else
		return false
	end
end

--[[----------------------------------------------------------------------------------------------

shows cooldown on actionbar buttons with macro

* syntax:
		MacroCD(name, time)

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

local function UpdateMacroCD(event, elapsedTime)
	ME.macroSlots				= ME.macroSlots or {}
	local numRunning		= 0
	for k,v in pairs(ME.macroSlots) do
		ME.macroSlots[k].remaining = math.max(0, ME.macroSlots[k].remaining - elapsedTime)
		numRunning = numRunning + (ME.macroSlots[k].remaining>0 and 1 or 0)
	end
	for i,b in pairs({"Main", "Bottom", "Right", "Left"}) do
		for j = 1, ACTIONBAR_NUM_BUTTONS do
			local id = (i-1)*ACTIONBAR_NUM_BUTTONS+j
			local icon, name, count = GetActionInfo(id)
			if icon~=nil and name~=nil and ME.macroSlots[name]~=nil then
				local buttFrame = getglobal(("%sActionBarFrameButton%d"):format(b,j))
				local timeFrame = getglobal(("%sActionBarFrameButton%dCooldown"):format(b,j))
				CooldownFrame_SetTime(timeFrame, ME.macroSlots[name].duration, ME.macroSlots[name].remaining)
				if ME.macroSlots[name].remaining<=0 then
					ME.macroSlots[name] = nil
				end
			end
		end
	end
	if numRunning<=0 then
		RB.UnregisterEvent(ME.name, "ONUPDATE")
	end
end

function ME.MacroCD(name, time, invalid)
	assert(type(name)=="string", "error: this macro needs a name for MacroCD")
	ME.macroSlots				= ME.macroSlots or {}
	ME.macroSlots[name] = ME.macroSlots[name] or {}
	ME.macroSlots[name].duration	= time
	ME.macroSlots[name].remaining	= time
	ME.macroSlots[name].invalid		= invalid or false
	RB.RegisterEvent(ME.name, "ONUPDATE", UpdateMacroCD)
	RB.Debug(ME.name, "MacroCD", name, time)
end

--[[----------------------------------------------------------------------------------------------

use an item if it was found in bag by id or name

* syntax:
		UseItem(ID or Name)

* returns:
		boolean success

--]]----------------------------------------------------------------------------------------------

function ME.UseItem(IDorName)
	local cnt = type(IDorName)=="number" and GetBagItemCount(IDorName) or CountInBagByName(IDorName)
	if cnt>0 then
		UseItemByName(type(IDorName)=="number" and TEXT("Sys"..IDorName.."_name") or IDorName)
		return true
	end
	return false
end

--[[----------------------------------------------------------------------------------------------

find free bag slot between start and finish

* syntax:
		GetNextFreeBagSlot([start], [finish])

* returns:
		number or false

--]]----------------------------------------------------------------------------------------------

function ME.GetNextFreeBagSlot(start, finish)
	local i, bagID, item
	local start		= start or 1
	local finish	= finish or 180
	for i = start,finish do
		bagID,_,item,_,_,_ = GetBagItemInfo(i)
		if not item or item=="" then
			return bagID
		end
	end
	return false
end

RB.RegisterModule("macro", ME)
