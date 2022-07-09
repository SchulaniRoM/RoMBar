
RB = {
	addonName							= "Extended RoMBar",
	addonAuthor						= "Schulani & Celesteria@Kerub",
	addonVersion					= 2.16,
	addonPath							= "Interface/AddOns/RoMBar",
	addonSettings					= "RoMBarSettings",
	addonProfile					= "RoMBarProfile",
	-- internal
	updateEventInterval		= 1,
	coroutineInterval			= .2,
	buttonHolder					= {},
	buttonIndex						= {},
	modules								= {},
	settings							= {},
	defaults							= {},
	events								= {},
}
_G.RoMBar								= RB

--[[---------------------------------------------------------------------------
	internal
--]]---------------------------------------------------------------------------

local type = type
local pairs = pairs
local string = string
local tostring = tostring
local table = table
local tonumber = tonumber
local coroutine = coroutine
local math = math
local pcall = pcall
local assert = assert
local lloadfile = loadfile
local dofile = dofile

local function TableSize(tbl)
	local c = 0
	if type(tbl)=="table" then
		for _,_ in pairs(tbl) do c = c + 1 end
	end
	return c
end

local function TableJoin(tbl, sep)
	local txt, sep = "", sep or RB.Separator()
	if type(tbl)=="table" then
		for _,v in pairs(tbl) do
			if v then
				txt = sprintf("%s%s%s", txt, #txt>0 and sep or "", tostring(v))
			end
		end
	else
		txt = tostring(tbl)
	end
	return txt
end

local function TableIsEmpty(tbl)
	if type(tbl)=="table" then
		for _,_ in pairs(tbl) do return false end
	end
	return true
end

local function TableReverse(tbl)
	local tmp,v = {}
	for _,v in pairs(tbl) do
		table.insert(tmp, 1, v)
	end
	return tmp
end

local function Trim(str)
	str = str:match("^[%s%c]*(.-)[%s%c]*$")
	return str
end

local function VarFunc(tbl, var, default, ...)
	local varV, varF = tostring(var):lower(), tostring(var):sub(1,1):upper() .. tostring(var):sub(2):lower()
	if tbl[varF] and type(tbl[varF])=="function" then return tbl[varF](...) end
	if tbl[varV] then return tbl[varV] end
	return default
end

function Arglist(withKey, ...)
	local txt, sep = '', withKey and "\n" or " "
	local types = {
		['number']		= {[false] = "|cff00ff00%d|r",		[true] = "%s = |cff00ff00%d (num)|r"},
		['function']	= {[false] = "|cffff0000%s()|r",	[true] = "%s = |cffff0000%s() (func)|r"},
		['table']			= {[false] = "|cff00ffff%s|r",		[true] = "%s = |cff00ffff%s (tbl)|r"},
		['frame']			= {[false] = "|cffff00ff%s|r",		[true] = "%s = |cffff00ff%s (frm)|r"},
		['string']		= {[false] = "|cffffff00'%s'|r",	[true] = "%s = |cffffff00'%s' (str)|r"},
		['boolean']		= {[false] = "|cff0000ff%s|r",		[true] = "%s = |cff0000ff%s|r"},
		['other']			= {[false] = "|cffffffff%s|r",		[true] = "%s = |cffffffff%s|r"},
	}
	for k,arg in pairs({...}) do
		if type(arg)=="number" then												v = tonumber(arg)
		elseif type(arg)=="function" then									v = k
		elseif type(arg)=="table" and arg.GetParent then	v = arg:GetName()
		elseif type(arg)=="boolean" then									v = arg and "true" or "false"
		else																							v = tostring(arg)
		end
		txt = sprintf("%s%s"..types[type(arg) or 'other'][withKey], txt, #txt and sep or "", withKey and k or v, v)
	end
	return txt
end

--[[---------------------------------------------------------------------------
	handle event
--]]---------------------------------------------------------------------------

function RB.OnLoad(frame)
	RB.frame = frame
	RB.frame:RegisterEvent("VARIABLES_LOADED")
	RB.frame:RegisterEvent("SAVE_VARIABLES")
	RB.frame:RegisterEvent("WARNING_MEMORY")
	SaveVariablesPerCharacter(RB.addonProfile)
	SaveVariables(RB.addonSettings)
end

function RB.OnUpdate(elapsedTime)
	RB.coroutineTime	= (RB.coroutineTime or RB.coroutineInterval) + elapsedTime
	if RB.coroutineTime>=RB.coroutineInterval and not TableIsEmpty(RB.events.COROUTINE) then
		for k, func in pairs(RB.events.COROUTINE) do
			if type(func)=="thread" then
				coroutine.resume(func,RB.coroutineTime)
				if coroutine.status(func)=="dead" then
					RB.events.COROUTINE[k] = nil
				end
			end
		end
		RB.coroutineTime = 0
	end
	RB.updateTime	= (RB.updateTime or RB.updateEventInterval) + elapsedTime
	if RB.updateTime>=RB.updateEventInterval and not TableIsEmpty(RB.events.ONUPDATE) then
		for k, object in pairs(RB.events.ONUPDATE) do
			if type(object)=="function" or (object.loaded and object.initialized) then
				local func = type(object)=="function" and object or (object[event] or object.Update)
				if func and type(func)=="function" then
					local success, errMsg = pcall(func, "ONUPDATE", RB.updateTime)
					assert(success, errMsg)
				end
			end
		end
		RB.updateTime = 0
	end
end

function RB.OnEvent(event, ...)
	RB.events = RB.events or {}
	if event=="ONENTER" or event=="ONLEAVE" then
		return RB.ShowTooltip(event, ...)
	elseif event=="ONCLICK" then
		return RB.ButtonClick(...)
	elseif RB[event] then
		RB[event](event, ...)
	end
	if not TableIsEmpty(RB.events[event]) then
		for _,object in pairs(RB.events[event]) do
			if type(object)=="function" or (type(object)=="table" and (object.loaded and object.initialized)) then
				local func = type(object)=="function" and object or (object[event] or object.Update)
				if func and type(func)=="function" then
					local success, errMsg = pcall(func, event, ...)
					assert(success, errMsg)
				end
 			end
		end
	end
end

function RB.RegisterEvent(name, event, func)
	local evt
	if type(event)=="table" then
		for _,evt in pairs(event) do
			RB.RegisterEvent(name, evt, func)
		end
	elseif type(event)=="string" and #event>0 then
		local button = RB.GetButton(name)
		if TableIsEmpty(RB.events[event]) then
			RB.events[event]				= {}
			RB.frame:RegisterEvent(event)
		end
		RB.Debug("RegisterEvent", event, name, func or button)
		RB.events[event][name] = func and func or button
	end
end

function RB.UnregisterEvent(name, event)
	local e
	if type(event)=="table" then
		for _,e in pairs(event) do RB.UnregisterEvent(name, e) end
		return
	end
	if event then
		if name~="main" then button, name, _ = RB.GetButton(name) end
		if RB.events[event] and RB.events[event][name] then
			RB.events[event][name]	= nil
		end
		if TableIsEmpty(RB.events[event]) then
			RB.frame:UnregisterEvent(event)
			RB.events[event] 				= nil
		end
	end
end

function RB.VARIABLES_LOADED()
	local buttons,modules
	RB.buttonHolder, RB.buttonIndex, RB.modules = {}, {}, {}
	RB.defaults, buttons, modules = dofile(sprintf("%s/defaults.lua", RB.addonPath))
	for i=1,#modules do
		RB.modules[modules[i]] = {name = modules[i], loaded = false, initialized = false}
	end
	local side = {"ltr", "rtl"}
	buttons[2] = TableReverse(buttons[2])
	for s=1,2 do
		if buttons[s] then
			for i=1,#buttons[s] do
				RB.buttonHolder[#RB.buttonHolder+1]	= {name = buttons[s][i]:lower(), index = #RB.buttonHolder+1, side=side[s], loaded = false, initialized = false}
				RB.buttonIndex[buttons[s][i]:lower()]		= #RB.buttonHolder
			end
		end
	end

	local save = _G[RB.addonProfile] or {}
	for k,v in pairs(RB.defaults) do
		if save[k]==nil then RB.settings[k] = v else RB.settings[k] = save[k] end
	end
	RB.global = _G[RB.addonSettings] or {}

	ITEM_QUEUE_FRAME_UPSATETIME = 0
	ITEM_QUEUE_FRAME_INSERTITEM = 0

	RB.LoadModules()
	RB.Print(sprintf("|cff34CB93RoMBar %s|r %s", RB.addonVersion, RB.Lang("WELCOME")))

	RB.UpdateUI()
	RB.LoadButtons()

end

function RB.SAVE_VARIABLES()
	_G[RB.addonProfile]		= RB.settings
	_G[RB.addonSettings]	= RB.global
end

function RB.WARNING_MEMORY()
-- 	if StaticPopupDialogs["WARNING_MEMORY"]:IsVisible() then
-- 		ClickRequestDialogButton(0)
-- 	end
	RB.Print(TEXT("SYSTEM_WARNING_MEMORY"))
end

--[[---------------------------------------------------------------------------
	update interface
--]]---------------------------------------------------------------------------

function RB.UpdateButtons()
	local l, r, index = nil, nil
	RB.Debug("updating all buttons")
	for index in pairs(RB.buttonHolder) do
		local button, name, index	= RB.GetButton(index)
		if button.loaded then
			if not button.initialized then
				RB.Debug(" -> init button", name, index, button.frame)
				button.initialized = (VarFunc(button, "init", true)~=false)
				if button.Update then button.Update() end
				RB.RegisterEvent(name, button.events)
			end
			if VarFunc(button, "enabled", true) then
				RB.UpdateButtonIcon(name)
				RB.ResizeButton(name)
				button.frame:Show()
				if button.side=="rtl" then
					button.frame:ClearAllAnchors()
					button.frame:SetAnchor("RIGHT", r and "LEFT" or "RIGHT", r or "RoMBarMain", -2, 0)
					r = button.frame:GetName()
				elseif button.side=="ltr" then
					button.frame:ClearAllAnchors()
					button.frame:SetAnchor('LEFT', l and "RIGHT" or "LEFT", l or "RoMBarMain", 2, 0)
					l = button.frame:GetName()
				end
			else
				button.frame:Hide()
			end
		end
	end
end

function RB.UpdateUI(withButtons)
	if RB.settings.originalUI==true then
		MainMenuFrame:Show()
		ExperienceFrame:Show()
		ExperienceFrame:ClearAllAnchors()
		ExperienceFrame:SetAnchor("BOTTOMLEFT","BOTTOMLEFT","MainMenuFrame",100,0)
		ExperienceFrame:SetAnchor("BOTTOMRIGHT","BOTTOMRIGHT","MainMenuFrame",-100,0)
	else
		MainMenuFrame:Hide()
		ExperienceFrame:Hide()
	end

	RoMBarMain:ClearAllAnchors()
	if RB.settings.top==true then
		RoMBarMain:SetAnchor("TOPLEFT", "TOPLEFT", "UIParent", 0, 0)
		RoMBarMain:SetAnchor("TOPRIGHT", "TOPRIGHT", "UIParent", 0, 0)
		PlayerFrame:ClearAllAnchors()
		PlayerFrame:SetAnchor("TOPLEFT","BOTTOMLEFT","RoMBarMain",0,0)
		TargetFrame:ClearAllAnchors()
		TargetFrame:SetAnchor("TOP","BOTTOM","RoMBarMain",-64,2)
		PlayerBuffButton1:ClearAllAnchors()
		PlayerBuffButton1:SetAnchor("TOPRIGHT","BOTTOMRIGHT","RoMBarMain",-200,10)
		UnitFrame_party1:ClearAllAnchors()
		UnitFrame_party1:SetAnchor("TOPLEFT","BOTTOMLEFT","RoMBarMain",2,118)
		if not XMinimapGUI1 then
			MinimapFrame:ClearAllAnchors()
			MinimapFrame:SetAnchor("TOPRIGHT","BOTTOMRIGHT","RoMBarMain",-12,32)
			MinimapFrameBorder:ClearAllAnchors()
			MinimapFrameBorder:SetAnchor("TOPRIGHT","BOTTOMRIGHT","RoMBarMain",0,-1)
		end
		MainMenuFrame:ClearAllAnchors()
		MainMenuFrame:SetAnchor("BOTTOMLEFT","BOTTOMLEFT","UIParent",0,0)
		MainMenuFrame:SetAnchor("BOTTOMRIGHT","BOTTOMRIGHT","UIParent",0,0)
	else
		RoMBarMain:SetAnchor("BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 0, 0)
		RoMBarMain:SetAnchor("BOTTOMRIGHT", "BOTTOMRIGHT", "UIParent", 0, 0)
		PlayerFrame:ClearAllAnchors()
		PlayerFrame:SetAnchor("TOPLEFT","TOPLEFT","UIParent",0,0)
		TargetFrame:ClearAllAnchors()
		TargetFrame:SetAnchor("TOP","TOP","UIParent",-64,2)
		PlayerBuffButton1:ClearAllAnchors()
		PlayerBuffButton1:SetAnchor("TOPRIGHT","TOPRIGHT","UIParent",-200,10)
		UnitFrame_party1:ClearAllAnchors()
		UnitFrame_party1:SetAnchor("TOPLEFT","TOPLEFT","UIParent",2,118)
		if not XMinimapGUI1 then
			MinimapFrame:ClearAllAnchors()
			MinimapFrame:SetAnchor("TOPRIGHT","TOPRIGHT","UIParent",-12,32)
			MinimapFrameBorder:ClearAllAnchors()
			MinimapFrameBorder:SetAnchor("TOPRIGHT","TOPRIGHT","UIParent",0,-1)
		end
		MainMenuFrame:ClearAllAnchors()
		MainMenuFrame:SetAnchor("BOTTOMLEFT","TOPLEFT","RoMBarMain",0,0)
		MainMenuFrame:SetAnchor("BOTTOMRIGHT","TOPRIGHT","RoMBarMain",0,0)
	end

	-- expand buffs
	MAX_BUFF_SIZE = 40
	PlayerBuffFrame_OnLoad(PlayerBuffFrame)
	
	-- extend actionbars
	for _,b in pairs({"Main", "Bottom", "Right", "Left", "Pet", "Extra" }) do
		for i = 1,20 do
			local actionButton = getglobal(("%sActionBarFrameButton%d"):format(b,i))
			if actionButton then
				actionButton.__uiLuaOnMouseEnter__	= RB.ActionbarTooltip
				actionButton.__uiLuaOnDragBegin__		= function(this)
					if not RB.settings.tweekAB or IsShiftKeyDown() then
						PickupAction(ActionButton_GetButtonID(this))
					end
				end
				actionButton.__uiLuaOnReceiveDrag__		= function(this)
					if CursorHasItem() then
						PickupAction(ActionButton_GetButtonID(this))
					end
				end
			end
		end
	end

	if withButtons==true then RB.UpdateButtons() end
	RB.SetupTooltipPosition(GetActionBarLocked())
end

--[[---------------------------------------------------------------------------
	actionbars and tooltip
--]]---------------------------------------------------------------------------

function RB.ActionbarTooltip(button)
	ActionButton_OnEnter(button)
	if RB.settings.actionbarTooltip.enabled==true then
		local anchor	= RB.settings.actionbarTooltip.anchor
		GameTooltip:ClearAllAnchors()
		GameTooltip:SetAnchor(anchor, anchor, "RoMBarTooltipPositioner")
	end
	if HasAction(ActionButton_GetButtonID(button))==true then
		GameTooltip:Show()
	end
end

function RB.SetupTooltipPosition(lock)
	local frame, posX, posY, anchor, enabled	= getglobal("RoMBarTooltipPositioner"), 0, 0, "TOPLEFT", false
	local a	= {["TOPLEFT"] = 1, ["TOPRIGHT"] = 2, ["BOTTOMRIGHT"] = 3, ["BOTTOMLEFT"] = 4}
	if RB.settings.actionbarTooltip then
		posX 		= RB.settings.actionbarTooltip.posX
		posY 		= RB.settings.actionbarTooltip.posY
		anchor	= RB.settings.actionbarTooltip.anchor
		enabled	= RB.settings.actionbarTooltip.enabled
	end
	frame:ClearAllAnchors();
	frame:SetAnchor("TOPLEFT", "TOPLEFT", "UIParent", posX, posY );
	getglobal(frame:GetName()..'Text'):SetText(RB.Lang("TOOLTIP_INFO"))
  getglobal(frame:GetName()..'Radio'..a[anchor]):SetChecked(true)

	if lock==true or enabled==false then
		frame:Hide()
	else
		frame:Show()
	end

	for i = 1, 20 do
		for _,j in pairs({"Main", "Bottom", "Left", "Right"}) do
			if lock==true then
				getglobal(j.."ActionBarFrameButton"..i.."Border"):Hide()
			else
				getglobal(j.."ActionBarFrameButton"..i.."Border"):Show()
				getglobal(j.."ActionBarFrameButton"..i.."Border"):SetColor(1,0,0)
			end
		end
	end
end

function RB.Backdrop(typ)
	typ = typ and "bg_"..typ:lower() or "background"
	return {
		edgeFile	= sprintf("%s/%s", RB.addonPath, "textures/edge"),
		bgFile 		= sprintf("%s/%s/%s", RB.addonPath, "textures", typ),
		BackgroundInsets = {top = 0, left = 0, bottom = 0, right = 0},
		EdgeSize	= 8,
		TileSize	= 8,
	}
end

function RB.SaveTooltipPosition()
	local frame						= getglobal("RoMBarTooltipPositioner")
	local _,_,_, x, y			= frame:GetAnchor()
	local sW, sH					= UIParent:GetSize()
	local pW, pH					= frame:GetSize()
	local anchor					= "BOTTOMRIGHT"

	if getglobal(frame:GetName()..'Radio1'):IsChecked() then			anchor			= "TOPLEFT"
	elseif getglobal(frame:GetName()..'Radio2'):IsChecked() then	anchor			= "TOPRIGHT"
	elseif getglobal(frame:GetName()..'Radio3'):IsChecked() then	anchor			= "BOTTOMRIGHT"
	elseif getglobal(frame:GetName()..'Radio4'):IsChecked() then	anchor			= "BOTTOMLEFT"
	end

	RB.settings.actionbarTooltip				= RB.settings.actionbarTooltip or {enabled = false}
	RB.settings.actionbarTooltip.posX		= math.floor(math.max(0, math.min(sW - pW, x)) + .5)
	RB.settings.actionbarTooltip.posY		= math.floor(math.max(0, math.min(sH - pH, y)) + .5)
	RB.settings.actionbarTooltip.anchor	= anchor

	RB.SetupTooltipPosition(GetActionBarLocked())
end

function RB.GameTooltip_OnUpdate(this, elapsedTime)
	RB.tooltipTime	= (RB.tooltipTime or 0) + elapsedTime
	if RB.tooltipTime>.1 then
		local anchorPoint, relativePoint, relativeTo, xOffset, yOffset = this:GetAnchor()
		local changePosition = false
		if this:GetTop()<0										then yOffset = yOffset - this:GetTop() 							changePosition = true end
-- 		if this:GetBottom()>GetScreenHeight()	then yOffset = GetScreenHeight() - this:GetBottom() changePosition = true end
		if this:GetLeft()<0 									then xOffset = xOffset - this:GetLeft()							changePosition = true end
-- 		if this:GetRight()>GetScreenWidth()		then xOffset = GetScreenWidth() - this:GetRight()		changePosition = true end
		if changePosition then
			this:ClearAllAnchors()
			this:SetAnchor(anchorPoint, relativePoint, relativeTo, xOffset, yOffset)
			return
		end
		RB.tooltipTime = 0
	end
	RB.GetOriginalFunction(_G, "GameTooltip_OnUpdate")(this, elapsedTime)
end

function RB.CooldownFrame_SetTime(this, duration, remaining)
	if ( duration > 0 or remaining > 0 ) then
		getglobal(this:GetName().."Text"):SetText(RB.FormatCooldownTime(remaining))
		getglobal(this:GetName().."Texture"):SetCooldown(duration, remaining)
		this.starting = 1
		this.duration = duration
		this.remaining = remaining
		this:Show()
	else
		this:Hide()
	end
end

--[[---------------------------------------------------------------------------
	buttons
--]]---------------------------------------------------------------------------

function RB.GetButton(value)
	local button, index
	if type(value)=="number" then
		index		= math.floor(tonumber(value))
		button	= RB.buttonHolder[index]
	elseif type(value)=="string" then
		index		= RB.buttonIndex[value:lower()]
		button	= RB.buttonHolder[index]
	elseif type(value)=="table" then
		if value.GetParent then	-- its a frame
			index 	= value:GetName():gsub("[%D]*", "") index = tonumber(index)
			button	= index and RB.buttonHolder[index] or nil
		else	-- its a button
			index		= value.index
			button	= value
		end
	end
	if button then
		return button, button.name, index
	else
		return nil, nil, nil
	end
end

function RB.LoadButtons()
	local index,button
	for index,button in pairs(RB.buttonHolder) do
		local path 		= sprintf("%s/lua/button.%s.lua", RB.addonPath, button.name)
		button.frame	= getglobal("RoMBarButton"..index)

		RB.Debug("load button", button.name, button.frame, path)

		local success,err	= pcall(dofile, path)
		if not success then RB.Error(err) end
	end
	RB.UpdateButtons()
end

function RB.LoadModules()
	local index,button
	for module in pairs(RB.modules) do
		local path 		= sprintf("%s/lua/module.%s.lua", RB.addonPath, module)

		RB.Debug("load module", module, path)

		local success,err	= pcall(dofile, path)
		if not success then RB.Error(err) end
	end
	for _,module in pairs(RB.modules) do
		if type(module)=="table" then
			module.initialized = module.Init and module.Init() or true
		end
	end
end

function RB.RegisterButton(name, object)
	local button, name, index	= RB.GetButton(name)
	if not button then return end
	RB.Debug("register button", name)
	local object							= object or {}
	object.name								= name
	object.side								= button.side
	object.frame							= button.frame
	object.index							= index
	object.loaded							= true
	object.initialized				= false
	object.actions						= object.actions or {}

	for c,b in pairs({LCLICK = "LBUTTON", RCLICK = "RBUTTON", MCLICK = "MBUTTON"}) do
		object.actions[b]						= object.actions[b] or {}
		object.actions[b].text			= object.actions[b].text or RB.Lang(name, c, nil, "")
		object.actions[b].func			= object.actions[b].func or button.Click
		object.actions[b].disabled	= object.actions[b].disabled or (object.actions[b].text=="")
	end

	RB.buttonHolder[index]		= object
	return object
end

function RB.RegisterModule(name, object)
	if not RB.modules[name] then return end
	RB.Debug("register module", name)
	local object							= object or {}
	object.name								= name
	object.loaded							= true
	object.initialized				= false
	RB.modules[name]					= object
	return object
end

function RB.ResizeButton(name)
	local button, name, index	= RB.GetButton(name)
	if not button then return end

	local T,M,B	= getglobal(button.frame:GetName().."TextT"), getglobal(button.frame:GetName().."TextM"), getglobal(button.frame:GetName().."TextB")
	local W 		= math.ceil(math.min(200, math.max(18, T:GetDisplayWidth(), M:GetDisplayWidth(), B:GetDisplayWidth())))
	T:SetWidth(W) M:SetWidth(W) B:SetWidth(W)
	if W<=18 then
		button.frame:SetWidth(18)
	else
		button.frame:SetWidth(W + 28)
	end
end

function RB.UpdateButtonIcon(name)
	local button, name, index	= RB.GetButton(name)
	if not button then return end
	local icon = VarFunc(button, "icon")
	RB.Debug(" ---> update buttonicon", name, index, icon, getglobal(button.frame:GetName().."IconNormal"))
	if icon then
		if type(icon)=="table" then
			getglobal(button.frame:GetName().."Icon"):SetTexture(icon[1])
			getglobal(button.frame:GetName().."Icon"):SetTexCoord(icon[2] or 0, icon[3] or 1, icon[4] or 0, icon[5] or 1)
		elseif type(icon)=="string" then
			getglobal(button.frame:GetName().."Icon"):SetTexture(icon)
			getglobal(button.frame:GetName().."Icon"):SetTexCoord(0, 1, 0, 1)
		end
	end
end

function RB.UpdateButtonText(name, line1, line2, iconText)
	local button, name, index	= RB.GetButton(name)
	if not button then return end

	local T,M,B,I = getglobal(button.frame:GetName().."TextT"), getglobal(button.frame:GetName().."TextM"), getglobal(button.frame:GetName().."TextB"), getglobal(button.frame:GetName().."TextI")

	line1	= line1 and (type(line1)=="table" and TableJoin(line1) or tostring(line1)) or ""
	line2	= line2 and (type(line2)=="table" and TableJoin(line2) or tostring(line2)) or ""

	if line1~="" and line2~="" then
		if line1 then T:SetText(line1) end
		if line2 then B:SetText(line2) end
		M:SetText("")
	else
		T:SetText("")
		B:SetText("")
		M:SetText(line1 or line2)
	end
	if I and iconText then I:SetText(iconText) end
	RB.ResizeButton(name)
end

function RB.ShowTooltip(event, frame)
	local button, name, index	= RB.GetButton(frame)
	if event=="ONLEAVE" or not button or frame==nil then return RoMBarTooltip:Hide() end

	if button.actions then
		local tooltip, name, B, T, L, R, X, Y = RoMBarTooltip, name:upper()
		local bX, bY = button.frame:GetLeft(), button.frame:GetTop()
		if bY>GetScreenHeight()/2 	then	T, B, Y	= "TOP", "BOTTOM", -5	else	T, B, Y	= "BOTTOM", "TOP", 5	end
		if bX<GetScreenWidth()-250	then	L, R, X	= "LEFT", "RIGHT", 0	else	L, R, X	= "RIGHT", "LEFT", 0		end

		RB.Debug("Tooltip", frame, name, index, B..L, T..L, X, Y)

		tooltip:ClearAllAnchors()
		tooltip:SetBackdrop(RB.Backdrop())
		tooltip:SetScale(RB.settings.tooltipScale/100)
		tooltip:SetAnchor(B..L, T..L, button.frame, X, Y)
		tooltip:SetText(RB.ColorByName("yellow", VarFunc(button, "title", RB.Lang(button.name, "TITLE"))))
		tooltip:AddSeparator(1, 1, 1)
		tooltip:Show()

		if button.Tooltip then
			button.Tooltip(tooltip)
			tooltip:AddSeparator(1, 1, 1)
		end

		for c,b in pairs({LCLICK = "LBUTTON", RCLICK = "RBUTTON", MCLICK = "MBUTTON"}) do
			if button.actions[b] and not button.actions[b].disabled then
				tooltip:AddDoubleLine(RB.ColorByName("LIGHT_BLUE", RB.Lang(c)), RB.ColorByName("LIGHT_BLUE", button.actions[b].text or RB.Lang(name, c)))
			end
		end

		CloseDropDownMenus()
	else
		tooltip:SetScale(1)
		tooltip:Hide()
	end
end

function RB.AddToTooltip(left, right)
	if left=="---" then
		RoMBarTooltip:AddSeparator()
	else
		left	= left and (type(left)=="table" and TableJoin(left) or tostring(left)) or ""
		right	= right and (type(right)=="table" and TableJoin(right) or tostring(right)) or ""
		if left and right then
			RoMBarTooltip:AddDoubleLine(left, right)
		elseif left then
			RoMBarTooltip:AddLine(left)
		end
	end
end

function RB.ButtonClick(frame, key)
	local button, name, index	= RB.GetButton(frame)
	if button and button.actions and button.actions[key] and not button.actions[key].disabled then
		local func = button.actions[key].func or button.Click
		if func and type(func)=="function" then
			RB.Debug("Click", frame, button, name, index, key)
			local success,err = pcall(func, key, RoMBarTooltip)
			if not success then RB.Error(err) end
		end
	end
end

--[[---------------------------------------------------------------------------
	helper
--]]---------------------------------------------------------------------------

function RB.Hook(funcRoot, funcName, newFunc)
	if funcRoot[funcName] then
		funcRoot.RoMBarHookedFunctions = funcRoot.RoMBarHookedFunctions or {}
		if not funcRoot.RoMBarHookedFunctions[funcName] then
			funcRoot.RoMBarHookedFunctions[funcName] = funcRoot[funcName]
		end
	end
	funcRoot[funcName] = newFunc
	return RB.GetOriginalFunction(funcRoot, funcName)
end

function RB.GetOriginalFunction(funcRoot, funcName)
	return funcRoot.RoMBarHookedFunctions and funcRoot.RoMBarHookedFunctions[funcName] or nil
end

function RB.Print(...)
	local txt = ''
	for k,arg in pairs({...}) do txt = sprintf("%s%s ", txt, tostring(arg)) end
	DEFAULT_CHAT_FRAME:AddMessage(txt, 1, 1, 1)
end

function RB.Debug(...)
	if not RB.settings.debug==true then return end
	local txt, chatFrame, k = Arglist(false,...), DEFAULT_CHAT_FRAME
	for k=1,10 do if GetChatWindowInfo(k):lower()=="debug" then chatFrame = getglobal("ChatFrame"..k) break end end
	chatFrame:AddMessage(txt, 1, 1, 1)
end

function RB.Error(str, ...)
	str = select("#",...)>0 and tostring(str):format(...) or tostring(str)
	DEFAULT_CHAT_FRAME:AddMessage(str, .9, .3, .3)
end

function RB.Format(text, object)
	if text and type(text)=="string" and text~="" then
		for k,v in pairs(object or {}) do
			text = text:gsub("<<"..tostring(k)..">>", type(v)=="number" and RB.Dec(v) or tostring(v))
		end
	end
	return text
end

function RB.FormatCooldownTime(time)
	local h = math.floor(time/60/60)
	local m = math.floor(((time/60/60) - math.floor(time/60/60)) * 60)
	local s = math.floor(((time/60) - math.floor(time/60)) * 60)
	if h>1 then
		return string.format("%dh%02d", h, m)
	elseif m>10 then
		return string.format("%dm", m)
	elseif m>2 then
		return string.format("%dm%02d", m, s)
	elseif time>=2 then
		return string.format("%d", m*60 + s)
	elseif time>=0.1 then
		return string.format("%0.1f", time)
	else
		return ""
	end
end

function RB.RGB2HEX(arg1, arg2, arg3)
	local r	= tonumber(type(arg1)=="table" and (arg1.r~=nil and arg1.r or arg1[1]) or arg1)
	local g	= tonumber(type(arg1)=="table" and (arg1.g~=nil and arg1.g or arg1[2]) or arg2)
	local b	= tonumber(type(arg1)=="table" and (arg1.b~=nil and arg1.b or arg1[3]) or arg3)
	r = math.max(0, math.min(255, r and (r>1 and math.floor(r) or math.floor(r*255)) or 255))
	g = math.max(0, math.min(255, g and (g>1 and math.floor(g) or math.floor(g*255)) or 255))
	b = math.max(0, math.min(255, b and (b>1 and math.floor(b) or math.floor(b*255)) or 255))
	return sprintf("%02x%02x%02x", r, g, b)
end

function RB.Dec(value)
	local val = MoneyNormalization(math.abs(value or 0))
	return value<0 and RB.ColorByName("red", "-"..val) or tostring(val)
end

function RB.ColorByClass(class, text)
	local token, color
	RB.colors	= RB.colors or {}
	if not RB.colors.classes then
		RB.colors.classes = {ROM = {}, WOW = {}}
		for token,color in pairs({
			WARRIOR			= {0.78, 0.61, 0.43},
			RANGER			= {0.67, 0.83, 0.45},
			THIEF				= {1.00, 0.96, 0.41},
			MAGE				= {0.41, 0.80, 0.94},
			AUGUR				= {1.00, 1.00, 1.00},
			DRUID				= {1.00, 0.49, 0.04},
			WARDEN			= {0.77, 0.12, 0.23},
			KNIGHT			= {0.96, 0.55, 0.73},
			PSYRON			= {0.04, 0.00, 1.00},
			HARPSYN			= {0.58, 0.28, 1.00},
			DUELIST			= {0.50, 0.50, 0.50},
		}) do
			RB.colors.classes.WOW[token]													= RB.RGB2HEX(color)
			RB.colors.classes.WOW[TEXT("SYS_CLASSNAME_"..token)]	= RB.colors.classes.WOW[token]
			RB.colors.classes.ROM[token]													= RB.RGB2HEX(g_ClassColors[token] and g_ClassColors[token] or {.5, .5, .5})
			RB.colors.classes.ROM[TEXT("SYS_CLASSNAME_"..token)]	= RB.colors.classes.ROM[token]
		end
	end
	color	= RB.settings.useWoWColors==true and RB.colors.classes.WOW[class] or RB.colors.classes.ROM[class]
	return RB.ColorTag(color, text)
end

function RB.ColorByRarity(index, text)
	RB.colors	= RB.colors or {}
	if not RB.colors.rarity then
		RB.colors.rarity = {}
		for i = 1,10 do
			RB.colors.rarity[i] = RB.RGB2HEX(GetItemQualityColor(i))
		end
	end
	local color	= RB.colors.rarity[index<=10 and math.floor(index) or GetQualityByGUID(index)]
	return RB.ColorTag(color, text)
end

function RB.ColorByQuality(value, text)
	return RB.ColorByRarity(math.floor((tonumber(value) or 0)/20), text)
end

function RB.ColorByPercent(value, maxValue, reverse, text)
	local vMax			= maxValue and tonumber(maxValue) or 1
	local vVal			= math.min(vMax, tonumber(value))
	local percent	 	= 1 / vMax * vVal
	local r					= reverse==true and percent or (1 - percent)
	local g					= reverse==true and (1 - percent) or percent
	local color			= RB.RGB2HEX(r*512, g*512, 0)
-- 	text	= text and (type(text)=="number" and RB.Dec(text) or tostring(text)) or RB.Dec(value)
	return RB.ColorTag(color, text or value)
end

function RB.ColorByName(cName, text)
	local token, color
	RB.colors	= RB.colors or {}
	if not RB.colors.names then
		RB.colors.names = {ROM = {}, WOW = {}}
		for token,color in pairs({
			GOLD					= {0.90,	0.90,	0.10},
			DIAMOND				= {0.10,	0.90,	0.90},
			RUBY					= {0.90,	0.10,	0.10},
			ARCANE				= {0.90,	0.50,	0.10},
			RED						= {1.00,	0.00,	0.00},
			DARK_RED			= {0.50,	0.00,	0.00},
			LIGHT_RED			= {0.96,	0.60,	0.47}, -- raid chat
			PINK					= {1.00,	0.80,	0.80},
			GREY					=	{0.60,	0.60,	0.60},
			WHITE					= {1.00,	1.00,	1.00},
			BLUE					= {0.00,	0.75,	0.95}, -- party chat
			LIGHT_BLUE		= {0.00,	1.00,	1.00}, -- channel chat
			DARK_BLUE			= {0.00,	0.23,	1.00}, -- npc
			GREEN					= {0.25,	1.00,	0.25}, -- guild chat
			DARK_GREEN		= {0.04,	0.37,	0.04}, -- zone / quest
			ORANGE				= {1.00,	0.50,	0.00}, -- system chat
			YELLOW				= {0.90,	0.90,	0.10}, -- gm chat
			BROWN					= {0.96,	0.60,	0.47}, -- bg chat
			VIOLET				= {0.76,	0.56,	0.94}, -- yell chat
			PURPLE				= {0.91,	0.10,	0.54}, -- combat chat
			BRIGHT_PURPLE	= {0.92,	0.47,	0.86}, -- whisper chat
		}) do
			RB.colors.names[token]	= RB.RGB2HEX(color)
		end
	end
	color	= RB.colors.names[cName:upper()]
	return RB.ColorTag(color, text)
end

function RB.ColorPosNeg(value, reverse, text)
	local pn 		= {[-1] = "BE3B3B", [0] = "3BBE3B", [1] = "3BBE3B"}
	local val		= value~=0 and math.floor(reverse and (value / -value) or (value / value)) or 0
-- 	local text	= (text==nil or type(text)=="number") and RB.Dec(text or value) or tostring(text)
	return RB.ColorTag(color, text or value)
end

function RB.ColorTag(color, value)
	local text	= value==nil and "" or (type(value)=="number" and RB.Dec(value) or tostring(value))
	return sprintf("|cff%s%s%s", color or "ffffff", text, #text>0 and "|r" or "")
end

function RB.GetBankItemCount(item, IsOnly)
	local item, total = type(item)=="number" and TEXT("Sys"..item.."_name") or item, 0
	for i = (IsOnly and 200 or 1), 300 do
		local icon, name, count, locked = GetBankItemInfo(i)
		total = total + (name==item and count or 0)
	end
	return total
end

function RB.GetSkillBookIndexes(skillName)
	for tab = 1, 5 do
		local numSkills = GetNumSkill(tab)
		if numSkills then
			for skill = 1, numSkills do
				local name, _, icon, _, rank, type, upgradeCost, isSkillable, isAvailable = GetSkillDetail(tab, skill)
				if name==skillName or string.find(name, skillName) then
					return tab, skill, isAvailable
				end
			end
		end
	end
	return nil, nil, false
end

function RB.Lang(name, token, replace, default)
	if RB.modules and RB.modules.locale then
		return RB.modules.locale.Lang(name, token, replace, default)
	else
		return "<nolang>"
	end
end

function RB.Separator()
	return '|cffaaaaaa | |r';
end

--[[---------------------------------------------------------------------------
	hooks
--]]---------------------------------------------------------------------------

RB.Hook(_G, "GameTooltip_OnUpdate", RB.GameTooltip_OnUpdate)
RB.Hook(_G, "CooldownFrame_SetTime", RB.CooldownFrame_SetTime)
