--======================== Fusion ======================

local RB = _G.RoMBar
local ME = {
	manaStoneT1	= 202840,
	fusionStone	= {
		TEXT("Sys203000_name"), 	-- Fusi
		TEXT("Sys202999_name"),		-- Gewöhnlicher Fusi
	},
	defaultItemFilter = {
		minTier		= 5,
		quality		= {
			[0]			= {minStats = 0},	-- use every white t5-item
			[1]			= {minStats = 0},	-- use every green t5-item
			[2]			= {minStats = 2}, -- use blue t5-item with at least 2 stats
			[3]			= {minStats = 2, maxStats = 5, maxDura = 101},	-- use lila t5-item with 2-5 stats and keep üdura-items
		},
	},
	maxGrade	= 8,
}

local function ParseItem(bagID)
	local iType,iLink,_ = ParseHyperlink(GetBagItemLink(bagID, false)) --Itemlink parsen: rückgaben: item(immer true),ID,dura{dura maxdura},tiered,quality,plus,runeslots,stats,runes,bound
	if iType~="item" then return nil end
	if type(iLink)=="string" and string.match(iLink,"(%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+)") then
		local id, bound, data, stat12, stat34, stat56, rune1, rune2, rune3, rune4, dura, hash = string.match(iLink,"(%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+) (%x+)")
		id	= tonumber(id, 16)
		if id >= 210000 and id < 240000 then
			if string.match(bound,"%x*(%x)$") and tonumber(string.match(bound,"%x*(%x)$"),16) >=8 then --Gesperrte/nicht fusionierbare items
				return nil
			end
			local item = {
				id							= id,
				bound						= tonumber(bound, 16),
				quality					= GetQualityByGUID(id),
				stats						= {},
			}
			item.stats[1], item.stats[2] = string.match(stat12,"(%x%x%x%x)(%x*)")
			item.stats[3], item.stats[4] = string.match(stat34,"(%x%x%x%x)(%x*)")
			item.stats[5], item.stats[6] = string.match(stat56,"(%x%x%x%x)(%x*)")
			for i=1, 6 do
				item.stats[i] 	= (item.stats[i] and item.stats[i]~="") and tonumber("7"..item.stats[i], 16) or nil
			end
			item.runes = {tonumber(rune1,16), tonumber(rune2,16), tonumber(rune3,16), tonumber(rune4,16)}
			for i=1, 4 do
				if item.runes[i]==0 then item.runes[i] = nil end
			end
			item.dura = tonumber(dura, 16) / 100
			while #data<8 do data = "0"..data end
			local _,p,t,m		= string.match(data, "(%x%x)(%x%x)(%x%x)(%x%x)")
			t	= tonumber(t, 16)
			p	= tonumber(p, 16)
			m = tonumber(m, 16)
			item.maxDura		= m
			item.rarity			= math.floor(t / 32)
			item.tier				= t - (item.rarity * 32) - 10
			item.runeSlots	= math.floor(p / 32) + #item.runes
			item.plus				= p - item.runeSlots * 32
			local level			= 100	-- TODO TODO TODO TODO TODO
			item.level			= level

			if item.quality > 0 then
				level = level + 2
			end
			if item.quality > 1 then
				level = level + (item.quality - 1) * 4
			end
			item.grade			= math.floor(level/20) + 1

			return item
		end
	end
	return nil
end

function ME.GetNextItem()
	for i=1,180 do
		local bagID,_,_,itemCount,locked,invalid = GetBagItemInfo(i)
		if itemCount==1 and not locked then
			local item = ParseItem(bagID)
			if item then
				RB.Debug("check item", item.rarity, item.grade, item.tier, item.quality, #item.stats, #item.runes, item.runeSlots)
				if item.grade>=ME.fuseDirty.minTier then
					local filter = ME.fuseDirty.quality[item.quality]
					if filter then
						if not filter.minStats or #item.stats>=filter.minStats then
							if not filter.maxStats or #items.stats<filter.maxStats then
								if not filter.maxDura or item.maxDura<=filter.maxDura then
									return bagID
								end
							end
						end
					end
				end
			end
		end
	end
	RB.Debug("no more items")
	return nil
end

local function PutToTransmutor(idName, tSlot)
	local name, i = type(idName)=="string" and idName or TEXT("Sys"..idName.."_name")
	for i = 1, 180 do
		local bagID,_,item,_,_,_ = GetBagItemInfo(i)
		if item==name then
			PickupBagItem(bagID)
			PickupBagItem(tSlot)
			return true
		end
	end
	return false
end

local function Process()
	local chk,i,j
-- 	while true do
		-- check finish
		local _,item = GetGoodsItemInfo(51)
		if item==TEXT("Sys"..(ME.manaStoneT1+ME.maxGrade-1).."_name") then
			RB.Print(RB.Lang(ME.name, "FINISHED"))
			return true
		end
		-- empty AU
		RB.Debug(ME.name, "cleaning transmutor")
		for i = 51, 55 do
			local _,item = GetGoodsItemInfo(i)
			if item and item~="" then
				local freeSlot = GetNextFreeBagSlot()
				if freeSlot>0 then
					PickupBagItem(i)
					PickupBagItem(freeSlot)
					coroutine.yield()
				else
					RB.Error(RB.Lang(ME.name, "BAG_FULL"))
					return false
				end
			end
		end
		-- find 3x T-stone
		chk = false
		for i = ME.manaStoneT1 + ME.maxGrade - 1, ME.manaStoneT1 + ME.fuseDirty.minTier, -1 do
			if GetBagItemCount(i)>=3 then
				chk = true
				for j = 52, 54 do
					if not PutToTransmutor(i, j) then
						RB.Error(RB.Lang(ME.name, "SOMETHING_WRONG"))
						return false
					end
					coroutine.yield()
				end
				break
			end
		end
		-- or find fusi and item
		if chk==false then
			for _,i in pairs(ME.fusionStone) do
				if GetCountInBagByName(i)>0 then
					if not PutToTransmutor(i, 52) then
						RB.Error(RB.Lang(ME.name, "SOMETHING_WRONG"))
						return false
					end
					chk = true
					coroutine.yield()
					break
				end
			end
			if chk==false then
				RB.Error(RB.Lang(ME.name, "NO_MORE_STONES"))
				return false
			end
			chk = false
			RB.Print("check for item")
			chk = ME.GetNextItem()
			if not chk then
				RB.Error(RB.Lang(ME.name, "NO_MORE_ITEMS"))
				return false
			end
			PickupBagItem(chk)
			PickupBagItem(53)
			coroutine.yield()
		end
-- 		-- transmute
-- 		if GetMagicBoxEnergy()<=0 then
-- 			RB.Error(RB.Lang(ME.name, "NO_MORE_ENERGY"))
-- 			return false
-- 		end
-- 		if chk~=false then
-- 			RB.Print("transmute")
-- -- 			MagicBoxRequest()
-- 			coroutine.yield()
-- 		end
-- -- 	end
end

function ME.FuseDirty(maxGrade, itemFilter)
	if ME.fuseDirty and ME.fuseDirty.coroutine then
		coroutine.resume(ME.fuseDirty.coroutine)
		RB.Debug("FuseDirty", coroutine.status(ME.fuseDirty.coroutine))
		if coroutine.status(ME.fuseDirty.coroutine)=="dead" then
			ME.fuseDirty = nil
			RB.UnregisterEvent(ME.name, "ONUPDATE")
		end
	elseif GetMagicBoxEnergy()>0 then
		RB.Debug("FuseDirty", "start")
		ME.maxGrade							= maxGrade or 8
		ME.fuseDirty						= (itemFilter and type(itemFilter)=="table") and itemFilter or ME.defaultItemFilter
		ME.fuseDirty.coroutine	= coroutine.create(Process)
		RB.RegisterEvent(ME.name, "ONUPDATE", ME.FuseDirty)
	end
end

RB.RegisterModule("fusion", ME)
