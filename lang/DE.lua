local lang = {
	_lang					= "DE",
	WELCOME				= "geladen...",
	TOOLTIP_INFO	= "Bewege diesen Frame an die Stelle,\nan der die Tooltips erscheinen sollen,\nund wähle die Ausrichtung.",
	LCLICK				= "Links-Klick",
	RCLICK				= "Rechts-Klick",
	MCLICK				= "Mittel-Klick",
	
	CONFIG = {
		TITLE								= "RoMBar v<<1>>",
		LCLICK							= "Addon-Konfiguration",
		RCLICK							= "Systemeinstellungen",
		MCLICK							= "ReloadUI",
		INTERFACE						= "Interface-Optionen",
		AUTOMATIC						= "Automatik",
		CLICK2MOVE					= "Bewegen mit Mausklick",
		ONTOP								= "RoMBar oben anzeigen",
		ORIGINALUI					= "Original Interface anzeigen",
		LOCKAB							= "Aktionsleisten sperren",
		TOOLTIPPOS					= "Feste Tooltip-Position für Aktionsleisten",
		TOOLTIPSCALE				= "Toolip-Skalierung",
		GUILDBEEP						= "Sound bei neuer Gildennachricht abspielen",
		PARTYBEEP						= "Sound bei neuer Partynachricht abspielen",
		WISPERBEEP					= "Sound bei neuer privater Nachricht abspielen",
		WOWCOLORS						= "WoW-Farben verwenden",
		AUTOREPAIR					= "Beim Händler reparieren",
		AUTOREPAIRSLOTS			= "Ausgewählte Slots automatisch repariern wenn Dura auf 100 fällt",
		FRIENDPARTY					= "Gruppeneinladung von Freunden annehmen",
		GUILDPARTY					= "Gruppeneinladung von Gildenmitgliedern annehmen",
		FRIENDRIDE					= "Reiteinladung von Freunden annehmen",
		GUILDRIDE						= "Reiteinladung von Gildenmitgliedern annehmen",
		FRIENDTRADE					= "Handelsanfragen von Freunden annehmen",
		GUILDTRADE					= "Handelsanfragen von Gildenmitgliedern annehmen",
		AUTOTRADE						= "Geschenke (Handel ohne Gegenleistung) automatisch annehmen",
		DECLINEDUELL				= "Duellanfragen ablehnen",
		AUTOAMMO						= "Gleichen Munitionstyp nachladen",
		AUTOAMULET					= "Gefüllte Amulette austauschen",
		FRIENDSYNC					= "Freundesliste syncronisieren",
		SKIPDIALOGS					= "Popups und NPC-Dialoge überspringen",
		BOSSBELL						= "Weltboss-Sichtungen in der Gilde melden",
	},

	PLAYER = {
		TITLE								= "Erfahrung",
		LCLICK							= "Fertigkeiten",
		RCLICK							= "Runen-Extraktion",
		MCLICK							= "Set-Fertigkeiten",
		XP									= "Erfahrungspunkte",
		XP_SHORT						= "EP",
		TP									= "Talentpunkte",
		TP_SHORT						= "TP",
		DEPT								= "Schulden",
		BONUS								= "Hausbonus",
	},
	
	TITLEQUEST = {
		TITLE								= "Quests & Titel",
		LCLICK							= "Questbuch",
		RCLICK							= "Titel wechseln",
		MCLICK							= "Titel-Interface",
		DAILY								= "Tagesquests",
		DAILY_SHORT					= "TQ",
		NOTITLE							= "<kein Titel>",
		TITLES							= "Titel",
		CARDS								= "Monsterkarten",
		QUESTS							= "Quests",
		BOSS_BELL						= "<<name>> gesichtet! Zone: <<zone>> Koordinaten: <<x>>,<<y>> Kanal: <<channel>>",
	},

	CRAFT = {
		TITLE								= TEXT("LIFESKILL_CRAFT_SORT"),
		LCLICK							= TEXT("LIFESKILL"),
		LEVEL1							= "Lehrling",
		LEVEL2							= "Geselle",
		LEVEL3							= "Experte",
		LEVEL4							= "Meister",
		LEVEL5							= "Legende",
		NOCRAFT							= "Kein Handwerk erlernt",
	},

	BAG	= {
		TITLE								= "Inventar",
		BAG									= "Rucksack",
		BAG_SHORT						= "Bag",
		BAG1TO6							= "Tasche <<id>> <<time>>",
		BAG7								= "Itemshop-Tasche",
		BAG7_SHORT					= "Shop",
		BANK								= "Bank",
		BANK1TO5						= "Bankfach <<id>> <<time>>",
		BANK6								= "Itemshop-Bankfach",
		BANKMOBILE					= TEXT("TIMEFLAG_HANDY_BANK"),
		ARCANE							= TEXT("MAGICBOX_TITLE"),
		ARCANE_SHORT				= "AU",
	},

	EQUIP = {
		TITLE								= "Haltbarkeit",
		LCLICK							= TEXT("BACKPACK_EQUIP"),
		RCLICK							= TEXT("BACKPACK_EQUIP").." wechseln",
		SLOT0								= "Kopf",
		SLOT1								= "Hände",
		SLOT2								= "Füße",
		SLOT3								= "Brust",
		SLOT4								= "Beine",
		SLOT5								= "Umhang",
		SLOT6								= "Gürtel",
		SLOT7								= "Schultern",
		SLOT8								= "Kette",
		SLOT9								= "Munition",
		SLOT10							= "Pfeile",
		SLOT11							= "Ring",
		SLOT12							= "Ring",
		SLOT13							= "Ohrring",
		SLOT14							= "Ohrring",
		SLOT15							= "Haupthand",
		SLOT16							= "Nebenhand",
		SLOT17							= "Fernkampf",
		SLOT21							= "Rücken",
		NOHAMMER						= "<keine Reparaturhämmer>",
		REPDONE							= "<<1>> Items repariert",
		NOREPAIR						= "Keine Reparaturen nötig",
		REPAIRING						= "<<1>> repariert...",
		REPAIRDIALOG				= "Womit willst du deine Ausrüstung reparieren?",
    AMMO_SHORT					= "Ammo: <<1>>",
		NOAMMO							= "<keine Munition>",
		DURA_SHORT					= "Dura: <<1>>",
		REPAIRCOSTS					= "Reparaturkosten",
	},

	MONEY = {
		TITLE							= "Finanzen",
		LCLICK						= "Währungen",
		MCLICK						= "Item-Shop",
		GOLD							= TEXT("BILLBOARD_001"),
		DIAMOND						= TEXT("BILLBOARD_002"),
		RUBY							= TEXT("BILLBOARD_003"),
		PHIRIUS						= TEXT("Sys203038_name_plural"),
		ARCANE						= "Arkane Ladungen",
	},
	
	SOCIAL = {
		TITLE							= "Kommunikation",
		LCLICK						= "Gildenliste",
		MCLICK						= "Freundesliste",
		INVITE						= "einladen",
		WISPER						= "anflüstern",
		GUILD							= "Gilde",
		FRIEND						= "Freunde",
		FRIENDLIST				= "Friendlist",
		GUILDLIST					= "Gildenliste",
		NOGUILD						= "<keine Gilde>",
		NOLOCATION				= "<unbekannt>",
		FRIENDNOONLINE		= "<Keine Freunde online>",
		GUILDNOONLINE			= "<Keine Guildis online>",
	},
	
	TIMETRAVEL = {
		TITLE							= "Zeit & Transport",
		RCLICK						= "Teleport-Schnellzugriff",
		LCLICK						= "Transportbuch",
		MCLICK						= "Datum/Zeit korrigieren",
		TELEPORT					= "Teleport",
		NOTELEPORT				= "Teleport hier nicht möglich",
		FPS								= "FPS: <<1>>",
		PING							= "Ping: <<1>>",
		MEMORY						= "Mem: <<1>>MB",
		DATE_FORMAT				= "%d.%b.%Y",
		TIME_FORMAT				= "%H:%M:%S",
	},

	MAIL = {
		TITLE							= "Mail",
		LCLICK						= TEXT("TIMEFLAG_HANDY_MAIL"),
		RCLICK						= TEXT("TIMEFLAG_TITLE"),
		MCLICK						= TEXT("TIMEFLAG_HANDY_AUCTION"),
	},
	
	PET = {
		TITLE							= "Begleiter",
		RCLICK						= "Begleiter-Fenster",
		LCLICK						= "Begleiter rufen/wegschicken",
		SUMMON						= "Begleiter rufen",
		RECALL						= "Begleiter zurückrufen",
		NOPET							= "Kein Begleiter vorhanden",
		PROP1							= "<kein Element>",
		PROP2							= "Erde",
		PROP3							= "Wasser",
		PROP4							= "Feuer",
		PROP5							= "Wind",
		PROP6							= "Licht",
		PROP7							= "Dunkelheit",
		LOYAL							= "Loyalität",
		LOYAL_SHORT				= "L: <<1>>",
		HUNGER						= "Hunger",
		HUNGER_SHORT			= "H: <<1>>",
		CHATMSG_SUMMON		= "Dein Auftritt <<name>>...",
		CHATMSG_RECALL		= "Ab ins Körbchen <<name>>...",
	},

	MOUNT = {
		TITLE							= "Reittier",
		LCLICK						= "Aufsitzen/Absitzen",
		RCLICK						= "Zufälliges Reittier",
		NOMOUNT						= "Kein Reittier vorhanden",
		MOUNT							= "Aufsitzen",
		DISMOUNT					= "Absitzen",
		RENTAL						= "Ticket benutzen",
		NORIDE						= "<keine Reitzone>",
	},

	MACRO = {
		TITLE							= "Makros",
		LCLICK						= "Makro-Interface",
		MCLICK						= "Makro-Befehle",
	},

	LOOTIT = {
		TITLE							= "LootIt! v<<1>>",
		LCLICK						= "Mini-Menü",
		RCLICK						= "Itemfilter",
		MCLICK						= "Konfiguration",
	},
}

return lang
