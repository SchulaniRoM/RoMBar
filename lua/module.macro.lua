--======================== Class ======================

local RB = _G.RoMBar
local ME = {
	exports		= {
		"FindString",	-- for developement
		"HasBuff",
		"HasDebuff",
		"HasQuest",
		"IsCasting",
		"RB_Kitty",
		"TargetNearestEnemy",
		"TargetUnitByName",
		"FocusUnitByName",
		"UnitIsCasting",
		"GetNpcID",
		"GetPosition",
		"MacroCD",
		"SH_loot",
		"SH_unbox",
	},
	macroSlots	= {},
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

function ME.FindString(str, root)
	local k,v,i,t1,t2
	for k,v in pairs(root or _G) do
		if tostring(v):match(str) then
			RB.Print("found in", tostring(k), ":", tostring(v))
		end
	end
	for i=100000,999999 do
		t1 = "Sys"..i.."_name"	t2 = TEXT(t1)
		if t1~=t2 and t2:match(str) then
			RB.Print("found in", i, ":", t1, t2)
		end
		t1 = "SC_"..i.."_S"	t2 = TEXT(t1)
		if t1~=t2 and t2:match(str) then
			RB.Print("found in", i, ":", t1, t2)
		end
		for j=0,9 do
			t1 = "SO_"..i.."_"..j	t2 = TEXT(t1)
			if t1~=t2 and t2:match(str) then
				RB.Print("found in", i, ":", t1, t2)
			end
		end
	end
	RB.Print("--- ende ---")
end

--[[----------------------------------------------------------------------------------------------

checking buffs and debuffs by ID or name

* syntax:
		HasBuff(ID or name, [target])
		HasDebuff(ID or name, [target])

* returns:
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
		_name, _icon, _count, _id, _params = debuff and UnitDebuff(t, n) or UnitBuff(t, n)
		if name and (_id==id or _name==name) then
			return _name, _id, _count, _params
		end
	until not _id
	return nil, nil, nil, nil
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

running kitty-combo after looting and target changes to next enemy

* syntax:
		RB_Kitty(yourKittyToken(s))

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

function ME.RB_Kitty(kittyToken)
	if kittyToken=="auto" then
		kittyToken = UnitClassToken("player")
	end
	if UnitIsDeadOrGhost("target") then
		CastSpellByName(TEXT("Sys540000_name"))
		TargetUnit()
	elseif not UnitName(t) then
		TargetNearestEnemy()
	end
	if UnitName(t) and UnitCanAttack("player", "target") then
		Kitty.attack(kittyToken or nil)
	end
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

local function UpdateMacroCD(elapsedTime)
	ME.macroSlots				= ME.macroSlots or {}
	local numRunning		= 0
	for k,v in pairs(ME.macroSlots) do
		ME.macroSlots[k].remaining = math.max(0, ME.macroSlots[k].remaining - elapsedTime)
		numRunning = numRunning + (ME.macroSlots[k].remaining>0 and 1 or 0)
	end

	for i,ab in pairs({"Main", "Bottom", "Right", "Left"}) do
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

shows your current position in chat - for dev use

* syntax:
		GetPosition()

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

function ME.GetPosition()
	local m		= GetCurrentWorldMapID()
	local z,n = GetZoneID(), GetZoneName()
	local x,y = GetPlayerWorldMapPos(m)
	DEFAULT_CHAT_FRAME:AddMessage(sprintf("zone: %s (%d) xPos: %.10f yPos: %.10f", n or "unknown", z or 0, x or 0, y or 0))
end

--[[----------------------------------------------------------------------------------------------

shows id of a npc - for dev use

* syntax:
		GetNpcID([target])

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

function ME.GetNpcID(target)
	target = target or "target"
	DEFAULT_CHAT_FRAME:AddMessage(sprintf("npcID of %s: %d", target, UnitGUID(target) or 0))
end

--[[----------------------------------------------------------------------------------------------

loot macro for sturmhöhe - targets next chest and click it to loot

* syntax:
		SH_loot()

* returns:
		nothing

--]]----------------------------------------------------------------------------------------------

function ME.SH_loot()
	local i, n = 0, "Geheimnisvolle"
	if UnitName("target")==nil then
		TargetUnit("player")
	end
	if string.match(UnitName("target"), n)==n then
		FocusUnit(1, "target")
	end
	repeat
		if string.match(UnitName("target"), n)~=n or UnitIsUnit("player", "focus1")==false then
			TargetNearestFriend()
			i=i+1
		end
	until i==40 or string.match(UnitName("target"), n)==n
	if string.match(UnitName("target"), n)~=n then
		TargetUnit("player")
	end
	if string.match(UnitName("target"), n)==n then
		FocusUnit(1, "target")
		CastSpellByName("Angreifen")
	end
end

--[[----------------------------------------------------------------------------------------------

unbox macro for sturmhöhe - unpacks next chest (I to XX) if at least 3 slots available in bag

* syntax:
		SH_unbox()

* returns:
		true/false

* usage:
	/run SH_unbox()
	/wait .1
	/run SH_unbox()
	/wait .1
	/run SH_unbox()
	/wait .1
	/run SH_unbox()
	...

--]]----------------------------------------------------------------------------------------------

function ME.SH_unbox()
	ITEM_QUEUE_FRAME_UPSATETIME = 0
	ITEM_QUEUE_FRAME_INSERTITEM = 0
	local _,s,_ = GetBagCount()
	if s>3 then
		for i=203256,208371 do
			if i==203266 then i=208361 end
			local b	= GetBagItemCount(i)
			if b>0 then
				UseItemByName(TEXT("Sys"..i.."_name"))
				return true
			end
		end
		RB.Print("nothing to unpack")
	else
		RB.Print("need more space")
	end
	return false
end

-- function ME.SH_unbox()
-- 	ITEM_QUEUE_FRAME_UPSATETIME = 0
-- 	ITEM_QUEUE_FRAME_INSERTITEM = 0
-- 	_G.NEXT_CHEST = _G.NEXT_CHEST or 203256
-- 	function run()
-- 		local _,s,_ = GetBagCount()
-- 		local b			= GetBagItemCount(_G.NEXT_CHEST)
-- 		if s>3 and b>0 then
-- 			UseItemByName(TEXT("Sys".._G.NEXT_CHEST.."_name"))
-- 			return true
-- 		else
-- 			return false
-- 		end
-- 	end
-- 	while not run() do
-- 		_G.NEXT_CHEST = _G.NEXT_CHEST + 1
-- 		if _G.NEXT_CHEST==203266 then
-- 			_G.NEXT_CHEST = 208361
-- 		end
-- 		if _G.NEXT_CHEST==208371 then
-- 			_G.NEXT_CHEST = 203256
-- 			break
-- 		end
-- 	end
-- end

RB.RegisterModule("macro", ME)
