--======================== dropdown ======================

local RB = _G.RoMBar
local ME = {
	frame			= "RoMBarDropDownMenu",
}

local function DD_AddRaw(text, checked, value, func, tooltip, checkable, keepOpen, hasArrow, isTitle)
	UIDropDownMenu_AddButton({
		text							= text or " ",
		value							= value,
		func							= func,
		tooltipText				= tooltip,
		checked						= (checked==true),
		notCheckable			= (checkable~=true),
		keepShownOnClick	= (keepOpen~=false),
		hasArrow					= (hasArrow==true),
		isTitle						= (isTitle==true),
	}, UIDROPDOWNMENU_MENU_LEVEL or 1)
end

function ME.GetDropDownFrame()
	if type(ME.frame)=="string" and getglobal(ME.frame) then
		ME.frame	= getglobal(ME.frame)
	end
	return ME.frame
end

function ME.AddButton(text, func, value, tooltip)									DD_AddRaw(text, nil, value, func, tooltip, nil, nil, nil, nil) end
function ME.AddCheckBox(text, checked, value, func, tooltip)			DD_AddRaw(text, checked, value, func, tooltip, true, nil, nil, nil) end
function ME.AddMenu(text, value, func, tooltip)										DD_AddRaw(text, nil, value, func, tooltip, nil, nil, true, nil) end
function ME.AddCheckMenu(text, checked, value, func, tooltip)			DD_AddRaw(text, checked, value, func, tooltip, true, nil, true, nil) end
function ME.AddText(text)																					DD_AddRaw(text, nil, nil, nil, nil, nil, nil, nil, false) end
function ME.AddTitle(text)																				DD_AddRaw(text, nil, nil, nil, nil, nil, nil, nil, true) end
function ME.AddSeparator()																				DD_AddRaw() end

function ME.ShowDropDown(anchor, handler)
	local point, relativePoint, relativeTo, offsetX, offsetY = anchor:GetAnchor(0)
	UIDropDownMenu_Initialize(ME.GetDropDownFrame(), handler, "MENU")
	UIDropDownMenu_SetAnchor(ME.GetDropDownFrame(), offsetX, offsetY, point, relativePoint, relativeTo)
	ToggleDropDownMenu(ME.GetDropDownFrame())
	ME.GetDropDownFrame():SetBackdrop(RB.Backdrop())
	ME.GetDropDownFrame():SetScale(RB.settings.tooltipScale/100)
	anchor:Hide()
end

RB.RegisterModule("dropdown", ME)
