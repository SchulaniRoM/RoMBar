
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
	autoEquipAmmo			= true,		-- button.equip
	beepGuild 				= true,		-- button.social
	beepParty 				= true,		-- button.social
	beepWisper 				= true,		-- button.social
	acceptPartyFriend = true,		-- button.social
	acceptPartyGuild 	= true,		-- button.social
	acceptRideFriend 	= true,		-- button.social
	acceptRideGuild 	= true,		-- button.social
	declineDuel 			= true,		-- button.social
	friendSync				= true,		-- button.social
	titleList					= {},			-- button.player
	lastMount					= "",			-- button.mount
	skipDialogs				= true,		-- module.dialogs
	autoQuestComplete	= true,		-- module.dialogs
}

local buttons		= {{"macro", "player", "craft"}, {"mount", "pet", "titlequest", "equip", "social", "money", "bag", "lootit", "mail", "timetravel", "config"}}
local modules		= {"dropdown", "dialogs", "events"}

return defaultsPerChar, buttons, modules
