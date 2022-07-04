--======================== LootIt ======================

local RB = _G.RoMBar
local ME = {}

function ME.Init()
	if ME.Enabled() then
		_G.LootIt_MinimapButton:Hide()
		_G.LI_Data.Options.minimap = false
		return true
	end
	return false
end

function ME.Click(key, tooltip)
	if ME.Enabled() then
		local point, relativePoint, relativeTo, offsetX, offsetY = tooltip:GetAnchor(0)
		if key=="LBUTTON" then
			if LootIt_Dropdown:IsVisible() then
				LootIt_Dropdown:Hide()
			else
				LI.MiniConfigShow(relativeTo, relativePoint, point, offsetX, offsetY)
				tooltip:Hide()
			end
		elseif key=="RBUTTON" then
			if LootIt_ItemFilter:IsVisible() then
				LootIt_ItemFilter:Hide()
			else
				LootIt_ItemFilter:Show()
			end
		elseif key=="MBUTTON" then
			if LootIt_Optionen:IsVisible() then
				LootIt_Optionen:Hide()
			else
				LootIt_Optionen:Show()
			end
		end
	end
end

function ME.Enabled()
	return (_G.LI~=nil)
end

function ME.Icon()
	return ME.Enabled() and LI.Path.."/textures/minimapbutton-normal" or nil
end

RB.RegisterButton("lootit", ME)
