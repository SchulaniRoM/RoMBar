
local defaultsPerChar = {
	debug							= false,
	top								= false,
	originalUI				= false,
	tooltipScale			= 85,
	useWoWColors			= false,
	tweekAB						= true,
	actionbarTooltip 	= {
		enabled						= true,
		posX							= 200,
		posY 							= 200,
		anchor						= "BOTTOMLEFT",
	},
	mail 							= 0,			-- button.mail
	autoRepair 				= true,		-- button.equip
-- 	autoRepairSlots		= {				-- button.equip
-- 		enabled						= false,
-- 		[15]							= true,
-- 		[16]							= true,
-- 	},
	autoUseItems			= {				-- button.bag
		enabled						= true,
		[206686]					= { enabled = true },							-- Abzeichen der Prüfung
		[206770]					= { enabled = true, space = 5 },	-- Paket des glorrreichen Sieges
		[206772]					= { enabled = true, space = 1 },	-- besonderes Ausrüstungspaket
		[206774]					= { enabled = true, space = 3 },	-- Gildenbeitragspaket
		[203487]					= { enabled = true },							-- Ladung für den arkanen umwandler
		[202928]					= { enabled = true },							-- 10 Ladung für den arkanen umwandler
	},
	autoEquipAmmo			= true,		-- button.equip
	autoSwapAmulets		= true,		-- button.equip
	beepGuild 				= true,		-- button.social
	beepParty 				= true,		-- button.social
	beepWisper 				= true,		-- button.social
	acceptPartyFriend = true,		-- button.social
	acceptPartyGuild 	= true,		-- button.social
	acceptRideFriend 	= true,		-- button.social
	acceptRideGuild 	= true,		-- button.social
	acceptTradeFriend	= true,		-- button.social
	acceptTradeGuild	= true,		-- button.social
	acceptTradeParty	= true,		-- button.social
	autoTrade					= true,		-- button.social
	declineDuel 			= true,		-- button.social
	friendSync				= false,	-- button.social
	autoHouseFriend		= true,		-- button.social
	titleList					= {},			-- button.player
	lastMount					= "",			-- button.mount
	lastPetSlot				= 1,			-- button.pet
	skipDialogs				= true,		-- module.dialogs
	autoQuestComplete	= true,		-- module.dialogs
	recallLocation		= "",			-- button.timetravel
	bossBell					= true,		-- button.titlequest
}

local buttons		= {{"macro", "player", "craft"}, {"mount", "pet", "titlequest", "equip", "social", "money", "bag", "lootit", "mail", "timetravel", "config"}}
local modules		= {"locale", "dropdown", "dialogs", "events", "macro", "fusion", "hooks"}

return defaultsPerChar, buttons, modules
