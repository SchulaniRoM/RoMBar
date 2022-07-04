function ExtraEquipItemButton_OnLoad(this)
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("PLAYER_INVENTORY_CHANGED")
end

function ExtraEquipItemButton_OnEvent(this, event)
	local stringName = getglobal(this:GetName().."Dura")
	local slotName = string.sub(this:GetParent():GetName(), 6)
	local durableValue, durableMax, name = GetInventoryItemDurable("player", GetInventorySlotInfo(slotName))
	if not stringName then return end
	if name then
		if durableValue > 100 then
			stringName:SetColor(0, 1, 0)
		else
			stringName:SetColor(1, 1, 1)
		end
		stringName:SetText(durableValue.."/"..durableMax)
	else
		stringName:SetText("")
	end
end
