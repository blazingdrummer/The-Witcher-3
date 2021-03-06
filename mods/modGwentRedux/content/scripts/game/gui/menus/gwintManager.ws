/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






import struct SCardDefinition
{
	import var index			: int;
	import var title			: string;
	import var description		: string;
	import var power			: int;
	import var picture			: string;
	import var faction			: eGwintFaction;
	import var typeFlags		: int;
	import var effectFlags		: array< eGwintEffect >;
	import var summonFlags		: array< int >;
	
	
	import var dlcPictureFlag	: name; 	
	import var dlcPicture		: string;
}


import struct SDeckDefinition
{
	import var cardIndices				: array< int >;
	import var leaderIndex 				: int;
	import var unlocked  				: bool;
	import var specialCard				: int;
	import var dynamicCardRequirements	: array< int >;
	import var dynamicCards 			: array< int >;
};

import struct CollectionCard
{
	import var cardID 		: int;
	import var numCopies 	: int;
}

import class CR4GwintManager extends IGameSystem
{
	public var testMatch:bool; default testMatch = false;
	
	import final function GetCardDefs() : array<SCardDefinition>;
	import final function GetLeaderDefs() : array<SCardDefinition>;
	
	import final function GetFactionDeck(faction:eGwintFaction, out deck:SDeckDefinition) : bool;
	import final function SetFactionDeck(faction:eGwintFaction, deck:SDeckDefinition) : void;
	
	import final function GetPlayerCollection() : array<CollectionCard>;
	import final function GetPlayerLeaderCollection() : array<CollectionCard>;
	
	import final function GetSelectedPlayerDeck() : eGwintFaction;
	import final function SetSelectedPlayerDeck(index : eGwintFaction) : void;
	
	import final function UnlockDeck(index : eGwintFaction) : void;
	import final function IsDeckUnlocked(index : eGwintFaction) : bool;
	
	import final function AddCardToCollection(cardIndex : int) : void;
	import final function RemoveCardFromCollection(cardIndex : int) : void;
	import final function HasCardInCollection(cardIndex : int) : bool;
	import final function HasCardsOfFactionInCollection(faction : eGwintFaction, optional includeLeaders : bool) : bool;
	
	import final function AddCardToDeck(faction:eGwintFaction, cardIndex : int) : void;
	import final function RemoveCardFromDeck(faction:eGwintFaction, cardIndex : int) : void;
	
	import final function GetHasDoneTutorial() : bool;
	import final function SetHasDoneTutorial(value : bool) : void;
	
	import final function GetHasDoneDeckTutorial() : bool;
	import final function SetHasDoneDeckTutorial(value : bool) : void;
	
	public function GetCardDefinitions(leader : bool) : array<SCardDefinition>
	{
		var cardNode, flagsNode	:	SCustomNode;
		var i, j, tmpInt		:	int;
		var tmpName				:	name;
		var tmpString			:	string;
		var tmpCard				:	SCardDefinition;
		var dm					:	CDefinitionsManagerAccessor;
		var cardDefinitions		:	array<SCardDefinition>;
		
		
		dm = theGame.GetDefinitionsManager();
		
		if( leader )
		{
			cardNode = dm.GetCustomDefinition('gwint_battle_king_card_definitions');	
		}
		else
		{
			cardNode = dm.GetCustomDefinition('gwint_card_definitions_final');	
		}
		
		for(i=0; i<cardNode.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt( cardNode.subNodes[i], 'index', tmpInt );
			tmpCard.index = tmpInt;
			
			dm.GetCustomNodeAttributeValueString( cardNode.subNodes[i], 'title', tmpString );
			tmpCard.title = tmpString;
			
			dm.GetCustomNodeAttributeValueString( cardNode.subNodes[i], 'description', tmpString );
			tmpCard.description = tmpString;
			
			dm.GetCustomNodeAttributeValueInt( cardNode.subNodes[i], 'power', tmpInt );
			tmpCard.power = tmpInt;
			
			dm.GetCustomNodeAttributeValueString( cardNode.subNodes[i], 'picture', tmpString );
			tmpCard.picture = tmpString;
			
			dm.GetCustomNodeAttributeValueString( cardNode.subNodes[i], 'faction_index', tmpString );
			switch(tmpString)
			{
				case "F_NEUTRAL"			:	tmpCard.faction = GwintFaction_Neutral;			break;
				case "F_NILFGAARD"			:	tmpCard.faction = GwintFaction_Nilfgaard;		break;
				case "F_NORTHERN_KINGDOM"	:	tmpCard.faction = GwintFaction_NothernKingdom;	break;
				case "F_NO_MANS_LAND"		:	tmpCard.faction = GwintFaction_NoMansLand;		break;
				case "F_SCOIATAEL"			:	tmpCard.faction = GwintFaction_Scoiatael;		break;
				case "F_SKELLIGE"			:	tmpCard.faction = GwintFaction_Skellige;		break;
			}
			
			flagsNode = dm.GetCustomDefinitionSubNode( cardNode.subNodes[i], 'type_flags' );
			for(j=0; j<flagsNode.subNodes.Size(); j+=1)
			{
				dm.GetCustomNodeAttributeValueString( flagsNode.subNodes[j], 'name', tmpString );
				switch(tmpString)
				{
					case "TYPE_NONE"				:	tmpCard.typeFlags += 0;		break;
					case "TYPE_MELEE"				:	tmpCard.typeFlags += 1;		break;
					case "TYPE_RANGED"				:	tmpCard.typeFlags += 2;		break;
					case "TYPE_SIEGE"				:	tmpCard.typeFlags += 4;		break;
					case "TYPE_CREATURE"			:	tmpCard.typeFlags += 8;		break;
					case "TYPE_WEATHER"				:	tmpCard.typeFlags += 16;	break;
					case "TYPE_SPELL"				:	tmpCard.typeFlags += 32;	break;
					case "TYPE_ROW_MODIFIER"		:	tmpCard.typeFlags += 64;	break;
					case "TYPE_HERO"				:	tmpCard.typeFlags += 128;	break;
					case "TYPE_SPY"					:	tmpCard.typeFlags += 256;	break;
					case "TYPE_FRIENDLY_EFFECT"		:	tmpCard.typeFlags += 512;	break;
					case "TYPE_OFFENSIVE_EFFECT"	:	tmpCard.typeFlags += 1024;	break;
					case "TYPE_GLOBAL_EFFECT"		:	tmpCard.typeFlags += 2048;	break;
				}
			}
			
			flagsNode = dm.GetCustomDefinitionSubNode( cardNode.subNodes[i], 'effect_flags' );
			for(j=0; j<flagsNode.subNodes.Size(); j+=1)
			{
				dm.GetCustomNodeAttributeValueString( flagsNode.subNodes[j], 'name', tmpString );
				switch(tmpString)
				{
					case "EFFECT_NONE"				:	tmpCard.effectFlags.PushBack( 0 );	break;
					case "EFFECT_BACK_STAB"			:	tmpCard.effectFlags.PushBack( 1 );	break;
					case "EFFECT_MORALE_BOOST"		:	tmpCard.effectFlags.PushBack( 2 );	break;
					case "EFFECT_AMBUSH"			:	tmpCard.effectFlags.PushBack( 3 );	break;
					case "EFFECT_TOUGH_SKIN"		:	tmpCard.effectFlags.PushBack( 4 );	break;
					case "EFFECT_BIN2"				:	tmpCard.effectFlags.PushBack( 5 );	break;
					case "EFFECT_BIN3"				:	tmpCard.effectFlags.PushBack( 6 );	break;
					case "CP_MELEE_SCORCH"			:	tmpCard.effectFlags.PushBack( 7 );	break;
					case "CP_11TH_CARD"				:	tmpCard.effectFlags.PushBack( 8 );	break;
					case "CP_CLEAR_WEATHER"			:	tmpCard.effectFlags.PushBack( 9 );	break;
					case "CP_PICK_WEATHER_CARD"		:	tmpCard.effectFlags.PushBack( 10 );	break;
					case "CP_PICK_RAIN_CARD"		:	tmpCard.effectFlags.PushBack( 11 );	break;
					case "CP_PICK_FOG_CARD"			:	tmpCard.effectFlags.PushBack( 12 );	break;
					case "CP_PICK_FROST_CARD"		:	tmpCard.effectFlags.PushBack( 13 );	break;
					case "CP_VIEW_3_ENEMY_CARDS"	:	tmpCard.effectFlags.PushBack( 14 );	break;
					case "CP_RESURECT_CARD"			:	tmpCard.effectFlags.PushBack( 15 );	break;
					case "CP_RESURECT_FROM_ENEMY"	:	tmpCard.effectFlags.PushBack( 16 );	break;
					case "CP_BIN2_PICK1"			:	tmpCard.effectFlags.PushBack( 17 );	break;
					case "CP_MELEE_HORN"			:	tmpCard.effectFlags.PushBack( 18 );	break;
					case "CP_RANGE_HORN"			:	tmpCard.effectFlags.PushBack( 19 );	break;
					case "CP_SIEGE_HORN"			:	tmpCard.effectFlags.PushBack( 20 );	break;
					case "CP_SIEGE_SCORCH"			:	tmpCard.effectFlags.PushBack( 21 );	break;
					case "CP_COUNTER_KING_ABLILITY" :	tmpCard.effectFlags.PushBack( 22 );	break;
					case "EFFECT_MELEE"				:	tmpCard.effectFlags.PushBack( 23 );	break;
					case "EFFECT_RANGED"			:	tmpCard.effectFlags.PushBack( 24 );	break;
					case "EFFECT_SIEGE"				:	tmpCard.effectFlags.PushBack( 25 );	break;
					case "EFFECT_UNSUMMON_DUMMY"	:	tmpCard.effectFlags.PushBack( 26 );	break;
					case "EFFECT_HORN"				:	tmpCard.effectFlags.PushBack( 27 );	break;
					case "EFFECT_DRAW"				:	tmpCard.effectFlags.PushBack( 28 );	break;
					case "EFFECT_SCORCH"			:	tmpCard.effectFlags.PushBack( 29 );	break;
					case "EFFECT_CLEAR_SKY"			:	tmpCard.effectFlags.PushBack( 30 );	break;
					case "EFFECT_SUMMON_CLONES"		:	tmpCard.effectFlags.PushBack( 31 );	break;
					case "EFFECT_IMPROVE_NEIGHBOURS":	tmpCard.effectFlags.PushBack( 32 );	break;
					case "EFFECT_NURSE"				:	tmpCard.effectFlags.PushBack( 33 );	break;
					case "EFFECT_DRAW_X2"			:	tmpCard.effectFlags.PushBack( 34 );	break;
					case "EFFECT_SAME_TYPE_MORALE"	:	tmpCard.effectFlags.PushBack( 35 );	break;
					case "EFFECT_AGILE_REPOSITION"	:	tmpCard.effectFlags.PushBack( 36 );	break;
					case "EFFECT_RANDOM_RESSURECT"	:	tmpCard.effectFlags.PushBack( 37 );	break;
					case "EFFECT_DOUBLE_SPY"		:	tmpCard.effectFlags.PushBack( 38 );	break;
					case "EFFECT_RANGED_SCORCH"		:	tmpCard.effectFlags.PushBack( 39 );	break;
					case "EFFECT_SUICIDE_SUMMON"	:	tmpCard.effectFlags.PushBack( 40 );	break;
					case "EFFECT_MUSHROOM"			:	tmpCard.effectFlags.PushBack( 41 );	break;
					case "EFFECT_MORPH"				:	tmpCard.effectFlags.PushBack( 42 );	break;
					case "EFFECT_WEATHER_RESISTANT"	:	tmpCard.effectFlags.PushBack( 43 );	break;
					case "EFFECT_GRAVEYARD_SHUFFLE"	:	tmpCard.effectFlags.PushBack( 44 );	break;
				}
			}
			
			flagsNode = dm.GetCustomDefinitionSubNode( cardNode.subNodes[i], 'summonFlags' );
			for(j=0; j<flagsNode.subNodes.Size(); j+=1)
			{
				dm.GetCustomNodeAttributeValueInt( flagsNode.subNodes[j], 'id', tmpInt );
				tmpCard.summonFlags.PushBack( tmpInt );
			}
			
			cardDefinitions.PushBack( tmpCard );
			
			tmpCard.typeFlags = 0;
			tmpCard.effectFlags.Clear();
			tmpCard.summonFlags.Clear();
		}
		
		return cardDefinitions;
	}
	
	public function HasLootedCard() : bool
	{
		return FactsDoesExist("Gwint_Card_Looted");
	}
	
	event  OnGwintSetupNewgame()
	{
		var northernPlayerDeck : SDeckDefinition;
		var nilfgardPlayerDeck : SDeckDefinition;
		var scotialPlayerDeck : SDeckDefinition;
		var nmlPlayerDeck : SDeckDefinition;
		var skePlayerDeck : SDeckDefinition;
	
		
		northernPlayerDeck.cardIndices.PushBack( 3 ); 	// FROST
		northernPlayerDeck.cardIndices.PushBack( 3 ); 	// FROST
		northernPlayerDeck.cardIndices.PushBack( 4 ); 	// FOG
		northernPlayerDeck.cardIndices.PushBack( 4 ); 	// FOG
		northernPlayerDeck.cardIndices.PushBack( 5 ); 	// RAIN
		northernPlayerDeck.cardIndices.PushBack( 5 ); 	// RAIN
		northernPlayerDeck.cardIndices.PushBack( 6 ); 	// CLEAR SKY
		northernPlayerDeck.cardIndices.PushBack( 6 ); 	// CLEAR SKY
		
		northernPlayerDeck.cardIndices.PushBack( 106 ); // VES
		northernPlayerDeck.cardIndices.PushBack( 107 ); // SHANI
		northernPlayerDeck.cardIndices.PushBack( 108 ); // YARPEN
		northernPlayerDeck.cardIndices.PushBack( 111 ); // KEIRA
		northernPlayerDeck.cardIndices.PushBack( 112 ); // SILE
		northernPlayerDeck.cardIndices.PushBack( 113 ); // SABRINA
		northernPlayerDeck.cardIndices.PushBack( 114 ); // SHELDON
		northernPlayerDeck.cardIndices.PushBack( 115 ); // DETHMOLD
		northernPlayerDeck.cardIndices.PushBack( 116 ); // STENNIS
		northernPlayerDeck.cardIndices.PushBack( 120 ); // TREBUCHET
		northernPlayerDeck.cardIndices.PushBack( 121 ); // POOR F. INFANTRY (1)
		northernPlayerDeck.cardIndices.PushBack( 125 ); // BALLISTA
		northernPlayerDeck.cardIndices.PushBack( 125 ); // BALLISTA
		northernPlayerDeck.cardIndices.PushBack( 135 ); // ESKEL
		northernPlayerDeck.cardIndices.PushBack( 136 ); // LAMBERT
		northernPlayerDeck.cardIndices.PushBack( 145 ); // KAEDWENI EXPERT
		northernPlayerDeck.cardIndices.PushBack( 146 ); // KAEDWENI SUPPORT
		northernPlayerDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		northernPlayerDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		northernPlayerDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		northernPlayerDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		northernPlayerDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		northernPlayerDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		northernPlayerDeck.cardIndices.PushBack( 175 ); // DUN BANNER MEDIC
		
		
		northernPlayerDeck.leaderIndex = 1001;
		northernPlayerDeck.specialCard = -1; 
		northernPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NothernKingdom, northernPlayerDeck);
		
		
		nilfgardPlayerDeck.leaderIndex = 2001;
		nilfgardPlayerDeck.specialCard = -1; 
		nilfgardPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Nilfgaard, nilfgardPlayerDeck);
		
		
		scotialPlayerDeck.leaderIndex = 3001;
		scotialPlayerDeck.specialCard = -1; 
		scotialPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Scoiatael, scotialPlayerDeck);
		
		
		nmlPlayerDeck.leaderIndex = 4001;
		nmlPlayerDeck.specialCard = -1; 
		nmlPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NoMansLand, nmlPlayerDeck);
		
		
		skePlayerDeck.leaderIndex = 5002;
		skePlayerDeck.specialCard = -1; 
		skePlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Skellige, skePlayerDeck);
		
		
		UnlockDeck(GwintFaction_NothernKingdom);
		UnlockDeck(GwintFaction_Nilfgaard);
		UnlockDeck(GwintFaction_Scoiatael);
		UnlockDeck(GwintFaction_NoMansLand);
		
		
		SetSelectedPlayerDeck(GwintFaction_NothernKingdom);
	}
	
	event  OnGwintSetupSkellige()
	{
		var skePlayerDeck : SDeckDefinition;
		
		
		skePlayerDeck.leaderIndex = 5002;
		skePlayerDeck.specialCard = -1; 
		skePlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Skellige, skePlayerDeck);
	}
	
	public function GetTutorialPlayerDeck() : SDeckDefinition
	{
		var tutorialDeck : SDeckDefinition;
		
		
		tutorialDeck.cardIndices.PushBack( 3 );   // FROST
		tutorialDeck.cardIndices.PushBack( 3 );   // FROST
		tutorialDeck.cardIndices.PushBack( 4 );   // FOG
		tutorialDeck.cardIndices.PushBack( 4 );   // FOG
		tutorialDeck.cardIndices.PushBack( 5 );   // RAIN
		tutorialDeck.cardIndices.PushBack( 5 );   // RAIN
		tutorialDeck.cardIndices.PushBack( 6 );   // CLEAR SKY
		tutorialDeck.cardIndices.PushBack( 6 );   // CLEAR SKY
		
		tutorialDeck.cardIndices.PushBack( 106 ); // VES
		tutorialDeck.cardIndices.PushBack( 107 ); // SHANI
		tutorialDeck.cardIndices.PushBack( 108 ); // YARPEN
		tutorialDeck.cardIndices.PushBack( 111 ); // KEIRA
		tutorialDeck.cardIndices.PushBack( 112 ); // SILE
		tutorialDeck.cardIndices.PushBack( 113 ); // SABRINA
		tutorialDeck.cardIndices.PushBack( 114 ); // SHELDON
		tutorialDeck.cardIndices.PushBack( 115 ); // DETHMOLD
		tutorialDeck.cardIndices.PushBack( 116 ); // STENNIS
		tutorialDeck.cardIndices.PushBack( 120 ); // TREBUCHET
		tutorialDeck.cardIndices.PushBack( 121 ); // POOR INFANTRY (1)
		tutorialDeck.cardIndices.PushBack( 125 ); // BALLISTA
		tutorialDeck.cardIndices.PushBack( 125 ); // BALLISTA
		tutorialDeck.cardIndices.PushBack( 135 ); // ESKEL
		tutorialDeck.cardIndices.PushBack( 136 ); // LAMBERT
		tutorialDeck.cardIndices.PushBack( 145 ); // KAEDWENI EXPERT
		tutorialDeck.cardIndices.PushBack( 146 ); // KAEDWENI SUPPORT
		tutorialDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		tutorialDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		tutorialDeck.cardIndices.PushBack( 150 ); // WITCH HUNTER
		tutorialDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		tutorialDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		tutorialDeck.cardIndices.PushBack( 160 ); // REDANIAN SOLDIER
		tutorialDeck.cardIndices.PushBack( 175 ); // DUN BANNER MEDIC
		
		tutorialDeck.leaderIndex = 1001;
		tutorialDeck.specialCard = -1; 
		
		return tutorialDeck;
	}
	
	protected function setupEnemyDecks() : void
	{
		if (!enemyDecksSet)
		{
			enemyDecksSet = true;
			
			SetupAIDeckDefinitions1();
			SetupAIDeckDefinitions2();
			SetupAIDeckDefinitions3();
			SetupAIDeckDefinitions4();
			SetupAIDeckDefinitions5();
			
			SetupAIDeckDefinitionsNK();
			SetupAIDeckDefinitionsNilf();
			SetupAIDeckDefinitionsScoia();
			SetupAIDeckDefinitionsNML();
			SetupAIDeckDefinitionsSkel();
			
			SetupAIDeckDefinitionsPrologue();
			SetupAIDeckDefinitionsTournament1();
			SetupAIDeckDefinitionsTournament2();
		}
	}
	
	
	private var enemyDecksSet : bool; default enemyDecksSet = false;
	private var enemyDecks : array< SDeckDefinition >;
	private var selectedEnemyDeck : int;
	private var forcePlayerFaction : eGwintFaction;
	
	private var difficulty : int;

	private var diff1 : int;
	private var diff2 : int;
	private var diff3 : int;
	private var diff4 : int;
	private var diff5 : int;
	private var diff6 : int;
	private var diff7 : int;
	private var diff8 : int;
	private var diff9 : int;
	private var diff10 : int;
	private var diff11 : int;
	private var diff12 : int;
	private var diff13 : int;
	private var diff14 : int;
	private var diff15 : int;
	
	private var doubleAIEnabled : bool;
	
	public var gameRequested : bool; default gameRequested = false;
	
	public function setDoubleAIEnabled(value:bool):void
	{
		doubleAIEnabled = value;
	}
	
	public function getDoubleAIEnabled():bool
	{
		return doubleAIEnabled;
	}
	
	public function GetForcedFaction():eGwintFaction
	{
		return forcePlayerFaction;
	}
	
	public function SetForcedFaction(faction : eGwintFaction):void
	{
		forcePlayerFaction = faction;
	}
	
	public function GetCurrentPlayerDeck() : SDeckDefinition
	{
		var selectedDeck : SDeckDefinition;
		
		if (forcePlayerFaction == GwintFaction_Neutral)
		{
			GetFactionDeck(GetSelectedPlayerDeck(), selectedDeck);
		}
		else
		{
			GetFactionDeck(forcePlayerFaction, selectedDeck);
		}
		
		return selectedDeck;
	}
	
	public function HasUnlockedDeck():bool
	{
		if (!IsDeckUnlocked(GwintFaction_NoMansLand) && !IsDeckUnlocked(GwintFaction_Nilfgaard) &&
			!IsDeckUnlocked(GwintFaction_NothernKingdom) && !IsDeckUnlocked(GwintFaction_Scoiatael))
		{
			return false;
		}
		
		return true;
	}
	
	public function SetEnemyDeckIndex(deckIndex:int):void
	{
		selectedEnemyDeck = deckIndex;
	}
	
	public function SetEnemyDeckByName(deckname:name):void
	{
		switch(deckname)
		{
		case 'CardProdigy':
			selectedEnemyDeck = 0;
			break;
		case 'Dijkstra':
			selectedEnemyDeck = 1;
			break;
		case 'Baron':
			selectedEnemyDeck = 2;
			break;
		case 'Roche':
			selectedEnemyDeck = 3;
			break;
		case 'Sjusta':
			selectedEnemyDeck = 4;
			break;
		case 'Stjepan':
			selectedEnemyDeck = 5;
			break;
		case 'MarkizaSerenity':
			selectedEnemyDeck = 6;
			break;
		case 'Gremista':
			selectedEnemyDeck = 7;
			break;
		case 'Zoltan':
			selectedEnemyDeck = 8;
			break;
		case 'Lambert':
			selectedEnemyDeck = 9;
			break;
		case 'Thaler':
			selectedEnemyDeck = 10;
			break;
		case 'VimmeVivaldi':
			selectedEnemyDeck = 11;
			break;
		case 'Crach':
			selectedEnemyDeck = 12;
			break;
		case 'LugosTheMad':
			selectedEnemyDeck = 13;
			break;
		case 'Hermit':
			selectedEnemyDeck = 14;
			break;
		case 'Olivier':
			selectedEnemyDeck = 15;
			break;
		case 'Mousesack':
			selectedEnemyDeck = 16;
			break;
		case 'Shani':
			selectedEnemyDeck = 17;
			break;
		case 'Olgierd':
			selectedEnemyDeck = 18;
			break;
		case 'Gambler':
			selectedEnemyDeck = 19;
			break;
		case 'CircusGwentAddict':
			selectedEnemyDeck = 20;
			break;
		case 'NKEasy':
		case 'NKNormal':
		case 'NKHard':
		case 'Halflings':
			selectedEnemyDeck = 21;
			break;
		case 'NilfEasy':
		case 'NilfNormal':
		case 'NilfHard':
			selectedEnemyDeck = 26;
			break;
		case 'ScoiaEasy':
		case 'ScoiaNormal':
		case 'ScoiaHard':
		case 'ScoiaTrader':
			selectedEnemyDeck = 31;
			break;
		case 'NMLEasy':
		case 'NMLNormal':
		case 'NMLHard':
		case 'CrossroadsInnkeeper':
			selectedEnemyDeck = 36;
			break;
		case 'SkelEasy':
		case 'SkelNormal':
		case 'SkelHard':
		case 'BoatBuilder':
			selectedEnemyDeck = 41;
			break;
		case 'NilfPrologue':
			selectedEnemyDeck = 46;
			break;
		case 'NKTournament':
			selectedEnemyDeck = 47;
			break;
		case 'NilfTournament':
			selectedEnemyDeck = 48;
			break;
		case 'ScoiaTournament':
			selectedEnemyDeck = 49;
			break;
		case 'NMLTournament':
			selectedEnemyDeck = 50;
			break;
		case 'NKTournament2':
			selectedEnemyDeck = 51;
			break;
		case 'NilfTournament2':
			selectedEnemyDeck = 52;
			break;
		case 'ScoiaTournament2':
			selectedEnemyDeck = 53;
			break;
		case 'NMLTournament2':
			selectedEnemyDeck = 54;
			break;		
		case 'SkelTournament2':
			selectedEnemyDeck = 55;		
			break;
		default:
			selectedEnemyDeck = 26;
		}
	}
	
	public function GetCardDefinition(cardIndex:int) : SCardDefinition
	{
		var cardDefinitions : array<SCardDefinition>;
		var errorDefinition : SCardDefinition;
		var currentDefinition : SCardDefinition;
		var i:int;
		
		if (cardIndex >= 1000)
		{
			cardDefinitions = GetCardDefinitions( true );
		}
		else
		{
			cardDefinitions = GetCardDefinitions( false );
		}
		
		for (i = 0; i < cardDefinitions.Size(); i += 1)
		{
			currentDefinition = cardDefinitions[i];
			if (currentDefinition.index == cardIndex)
			{
				return currentDefinition;
			}
		}
		
		errorDefinition.index = -1;
		
		return errorDefinition;
	}
	
	public function GetCurrentAIDeck() : SDeckDefinition
	{
		GenerateDifficultyData();

		setupEnemyDecks();
		
		randomizeEnemyDeck();
		
		return enemyDecks[selectedEnemyDeck];
	}
	
	private function randomizeEnemyDeck()
	{
		var randomize	:bool;
		var tmpInt		:int;
		
		randomize = false;
		tmpInt = RandRange( 5, 0 );
		
		switch (selectedEnemyDeck)
		{
		case 21:
		case 26:
		case 31:
		case 36:
		case 41:
			randomize = true;
			break;
		}
		
		if (randomize)
		{
			selectedEnemyDeck += tmpInt;
		}
	}
	
	private function GenerateDifficultyData()
	{
		var difficultyBalanceValue : int;
		difficultyBalanceValue = 0;
		
		difficulty = FactsQueryLatestValue("gwent_difficulty");
		
		if (difficulty)
		{
			if (difficulty == 1) 
			{ 
				difficultyBalanceValue += 80;
			}
			
			if (difficulty == 2) 
			{ 
				difficultyBalanceValue += 0;
			}
			
			if (difficulty == 3) 
			{ 
				difficultyBalanceValue -= 80;
			}
		}
		
		diff1 = 145 + difficultyBalanceValue;
		diff2 = 150 + difficultyBalanceValue;
		diff3 = 155 + difficultyBalanceValue;
		diff4 = 160 + difficultyBalanceValue;
		diff5 = 165 + difficultyBalanceValue;
		diff6 = 170 + difficultyBalanceValue;
		diff7 = 175 + difficultyBalanceValue;
		diff8 = 180 + difficultyBalanceValue;
		diff9 = 185 + difficultyBalanceValue;
		diff10 = 190 + difficultyBalanceValue;
		diff11 = 205 + difficultyBalanceValue;
		diff12 = 215 + difficultyBalanceValue;
		diff13 = 220 + difficultyBalanceValue;
		diff14 = 225 + difficultyBalanceValue;
		diff15 = 230 + difficultyBalanceValue;		
	}
		
	private function SetupAIDeckDefinitions1()
	{
		var CardProdigyDeck		:SDeckDefinition;
		var DijkstraDeck		:SDeckDefinition;
		var BaronDeck			:SDeckDefinition;
		var RocheDeck			:SDeckDefinition;
		var SjustaDeck			:SDeckDefinition;
			
			
			// HADDY - THE FELLOWSHIP OF THE WITCHER DECK
			
			CardProdigyDeck.cardIndices.PushBack(5);   // RAIN
			CardProdigyDeck.cardIndices.PushBack(6);   // CLEAR SKY
			CardProdigyDeck.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			CardProdigyDeck.cardIndices.PushBack(7);   // GERALT
			CardProdigyDeck.cardIndices.PushBack(8);   // VESEMIR
			CardProdigyDeck.cardIndices.PushBack(10);  // CIRI
			CardProdigyDeck.cardIndices.PushBack(11);  // TRISS
			CardProdigyDeck.cardIndices.PushBack(12);  // DANDELION
			CardProdigyDeck.cardIndices.PushBack(13);  // ZOLTAN
			CardProdigyDeck.cardIndices.PushBack(100); // VERNON
			CardProdigyDeck.cardIndices.PushBack(101); // NATALIS
			CardProdigyDeck.cardIndices.PushBack(106); // VES
			CardProdigyDeck.cardIndices.PushBack(107); // SHANI
			CardProdigyDeck.cardIndices.PushBack(108); // YARPEN
			CardProdigyDeck.cardIndices.PushBack(109); // DIJKSTRA
			CardProdigyDeck.cardIndices.PushBack(111); // KEIRA
			CardProdigyDeck.cardIndices.PushBack(112); // SILE
			CardProdigyDeck.cardIndices.PushBack(114); // SHELDON
			CardProdigyDeck.cardIndices.PushBack(117); // VINCENT MEIS
			CardProdigyDeck.cardIndices.PushBack(135); // ESKEL
			CardProdigyDeck.cardIndices.PushBack(136); // LAMBERT
			CardProdigyDeck.cardIndices.PushBack(161); // BLUE STRIPES (1)
			CardProdigyDeck.cardIndices.PushBack(162); // BLUE STRIPES (2)
			CardProdigyDeck.cardIndices.PushBack(163); // BLUE STRIPES (3)
			
			CardProdigyDeck.specialCard = 9;    // YENNEFER
			CardProdigyDeck.leaderIndex = 1002; // FOLTEST
			enemyDecks.PushBack(CardProdigyDeck);
			
			
			// DIJKSTRA - A GAME OF THRONES DECK
			
			DijkstraDeck.cardIndices.PushBack(0);   // DECOY
			DijkstraDeck.cardIndices.PushBack(4);   // FOG
			DijkstraDeck.cardIndices.PushBack(4);   // FOG
			
			DijkstraDeck.cardIndices.PushBack(109); // DIJKSTRA
			DijkstraDeck.cardIndices.PushBack(141); // CALEB MENGE
			DijkstraDeck.cardIndices.PushBack(142); // NATHANIEL
			DijkstraDeck.cardIndices.PushBack(147); // CUTUP LACKEY
			DijkstraDeck.cardIndices.PushBack(147); // CUTUP LACKEY
			DijkstraDeck.cardIndices.PushBack(150); // WITCH HUNTER
			DijkstraDeck.cardIndices.PushBack(150); // WITCH HUNTER
			DijkstraDeck.cardIndices.PushBack(150); // WITCH HUNTER
			DijkstraDeck.cardIndices.PushBack(151); // BEGGAR
			DijkstraDeck.cardIndices.PushBack(151); // BEGGAR
			DijkstraDeck.cardIndices.PushBack(151); // BEGGAR
			DijkstraDeck.cardIndices.PushBack(152); // PASSIFLORA PEACHES
			DijkstraDeck.cardIndices.PushBack(165); // KING OF BEGGARS
			DijkstraDeck.cardIndices.PushBack(166); // WHORESON JUNIOR
			DijkstraDeck.cardIndices.PushBack(167); // CARLO VARESE
			DijkstraDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			DijkstraDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			DijkstraDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			DijkstraDeck.cardIndices.PushBack(176); // IGOR
			DijkstraDeck.cardIndices.PushBack(447); // TATTERWING
			DijkstraDeck.cardIndices.PushBack(448); // BORIS
			
			DijkstraDeck.specialCard = 147;  // CUTUP LACKEY
			DijkstraDeck.leaderIndex = 1001; // DEMAVEND
			enemyDecks.PushBack(DijkstraDeck);
			
			
			// BLOODY BARON - THE WITCH HUNT DECK
			
			BaronDeck.cardIndices.PushBack(5);   // RAIN
			BaronDeck.cardIndices.PushBack(6);   // CLEAR SKY
			BaronDeck.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			BaronDeck.cardIndices.PushBack(7);   // GERALT
			BaronDeck.cardIndices.PushBack(9);   // YENNEFER
			BaronDeck.cardIndices.PushBack(10);  // CIRI
			BaronDeck.cardIndices.PushBack(11);  // TRISS
			BaronDeck.cardIndices.PushBack(104); // JACQUES
			BaronDeck.cardIndices.PushBack(111); // KEIRA
			BaronDeck.cardIndices.PushBack(112); // SILE
			BaronDeck.cardIndices.PushBack(113); // SABRINA
			BaronDeck.cardIndices.PushBack(115); // DETHMOLD
			BaronDeck.cardIndices.PushBack(141); // CALEB MENGE
			BaronDeck.cardIndices.PushBack(142); // NATHANIEL
			BaronDeck.cardIndices.PushBack(143); // LEBIODA
			BaronDeck.cardIndices.PushBack(150); // WITCH HUNTER
			BaronDeck.cardIndices.PushBack(150); // WITCH HUNTER
			BaronDeck.cardIndices.PushBack(150); // WITCH HUNTER
			BaronDeck.cardIndices.PushBack(155); // CLERIC FLAMING ROSE
			BaronDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			BaronDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			BaronDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			BaronDeck.cardIndices.PushBack(480); // AZAR JAVED
			BaronDeck.cardIndices.PushBack(481); // PROFESSOR
			
			BaronDeck.specialCard = 103;  // PHILIPPA
			BaronDeck.leaderIndex = 1005; // RADOVID
			enemyDecks.PushBack(BaronDeck);
			
			
			// VERNON - RESISTANCE DECK
			
			RocheDeck.cardIndices.PushBack(0);   // DECOY
			RocheDeck.cardIndices.PushBack(1);   // MARDROEME
			RocheDeck.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			RocheDeck.cardIndices.PushBack(101); // NATALIS
			RocheDeck.cardIndices.PushBack(102); // VISSEGERD
			RocheDeck.cardIndices.PushBack(106); // VES
			RocheDeck.cardIndices.PushBack(120); // TREBUCHET
			RocheDeck.cardIndices.PushBack(120); // TREBUCHET
			RocheDeck.cardIndices.PushBack(121); // POOR INFANTRY (1)
			RocheDeck.cardIndices.PushBack(125); // BALLISTA
			RocheDeck.cardIndices.PushBack(125); // BALLISTA
			RocheDeck.cardIndices.PushBack(126); // POOR INFANTRY (1)
			RocheDeck.cardIndices.PushBack(127); // POOR INFANTRY (1)
			RocheDeck.cardIndices.PushBack(140); // CATAPULT
			RocheDeck.cardIndices.PushBack(140); // CATAPULT
			RocheDeck.cardIndices.PushBack(145); // KAEDWENI EXPERT
			RocheDeck.cardIndices.PushBack(146); // KAEDWENI SUPPORT
			RocheDeck.cardIndices.PushBack(161); // BLUE STRIPES (1)
			RocheDeck.cardIndices.PushBack(162); // BLUE STRIPES (2)
			RocheDeck.cardIndices.PushBack(163); // BLUE STRIPES (3)
			RocheDeck.cardIndices.PushBack(170); // SIEGE TOWER
			RocheDeck.cardIndices.PushBack(175); // DUN BANNER MEDIC
			RocheDeck.cardIndices.PushBack(420); // BOTCHLING
			RocheDeck.cardIndices.PushBack(422); // BLOODY BARON
			
			RocheDeck.specialCard = 100;  // VERNON
			RocheDeck.leaderIndex = 1003; // CALANTHE
			enemyDecks.PushBack(RocheDeck);
			
			
			// SJUSTA - FAKE SKELLIGERS DECK
			
			SjustaDeck.cardIndices.PushBack(4);   // FOG
			SjustaDeck.cardIndices.PushBack(5);   // RAIN
			SjustaDeck.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			SjustaDeck.cardIndices.PushBack(7);   // GERALT
			SjustaDeck.cardIndices.PushBack(8);   // VESEMIR
			SjustaDeck.cardIndices.PushBack(12);  // DANDELION
			SjustaDeck.cardIndices.PushBack(13);  // ZOLTAN
			SjustaDeck.cardIndices.PushBack(102); // VISSEGERD
			SjustaDeck.cardIndices.PushBack(104); // JACQUES
			SjustaDeck.cardIndices.PushBack(108); // YARPEN
			SjustaDeck.cardIndices.PushBack(114); // SHELDON
			SjustaDeck.cardIndices.PushBack(130); // CRINFRID REAVERS (1)
			SjustaDeck.cardIndices.PushBack(131); // CRINFRID REAVERS (2)
			SjustaDeck.cardIndices.PushBack(132); // CRINFRID REAVERS (3)
			SjustaDeck.cardIndices.PushBack(143); // LEBIODA
			SjustaDeck.cardIndices.PushBack(155); // CLERIC FLAMING ROSE
			SjustaDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			SjustaDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			SjustaDeck.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			SjustaDeck.cardIndices.PushBack(167); // CARLO VARESE
			SjustaDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			SjustaDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			SjustaDeck.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			SjustaDeck.cardIndices.PushBack(422); // BLOODY BARON
			
			SjustaDeck.specialCard = 17;   // OLGIERD
			SjustaDeck.leaderIndex = 1004; // HENSELT
			enemyDecks.PushBack(SjustaDeck);
	}
	
	private function SetupAIDeckDefinitions2()
	{
		var StjepanDeck			:SDeckDefinition;
		var MarkizaDeck			:SDeckDefinition;
		var GremistaDeck		:SDeckDefinition;
			
			
			// STJEPAN - WITCHERS DECK
			
			StjepanDeck.cardIndices.PushBack(0);   // DECOY
			StjepanDeck.cardIndices.PushBack(1);   // MARDROEME
			StjepanDeck.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			StjepanDeck.cardIndices.PushBack(7);   // GERALT
			StjepanDeck.cardIndices.PushBack(8);   // VESEMIR
			StjepanDeck.cardIndices.PushBack(9);   // YENNEFER
			StjepanDeck.cardIndices.PushBack(10);  // CIRI
			StjepanDeck.cardIndices.PushBack(135); // ESKEL
			StjepanDeck.cardIndices.PushBack(136); // LAMBERT
			StjepanDeck.cardIndices.PushBack(200); // LETHO
			StjepanDeck.cardIndices.PushBack(214); // STEFAN
			StjepanDeck.cardIndices.PushBack(218); // VATTIER
			StjepanDeck.cardIndices.PushBack(220); // CAHIR
			StjepanDeck.cardIndices.PushBack(231); // RIENCE
			StjepanDeck.cardIndices.PushBack(236); // VILGEFORTZ
			StjepanDeck.cardIndices.PushBack(240); // HEAVY ZERRI SCORPION
			StjepanDeck.cardIndices.PushBack(241); // ZERRI SCORPION
			StjepanDeck.cardIndices.PushBack(241); // ZERRI SCORPION
			StjepanDeck.cardIndices.PushBack(247); // AUCKES
			StjepanDeck.cardIndices.PushBack(248); // LEO BONHART
			StjepanDeck.cardIndices.PushBack(255); // SIEGE ENGINEER
			StjepanDeck.cardIndices.PushBack(265); // ALCHEMIST
			StjepanDeck.cardIndices.PushBack(480); // AZAR JAVED
			StjepanDeck.cardIndices.PushBack(481); // PROFESSOR
			
			StjepanDeck.specialCard = 246;  // SERRIT
			StjepanDeck.leaderIndex = 2002; // EMHYR
			enemyDecks.PushBack(StjepanDeck);
			
			
			// MARQUISE SERENITY - LIES & WINE DECK
			
			MarkizaDeck.cardIndices.PushBack(5);   // RAIN
			MarkizaDeck.cardIndices.PushBack(6);   // CLEAR SKY
			MarkizaDeck.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			MarkizaDeck.cardIndices.PushBack(207); // CYNTHIA
			MarkizaDeck.cardIndices.PushBack(211); // CANTARELLA
			MarkizaDeck.cardIndices.PushBack(214); // STEFAN
			MarkizaDeck.cardIndices.PushBack(217); // VANHEMAR
			MarkizaDeck.cardIndices.PushBack(220); // CAHIR
			MarkizaDeck.cardIndices.PushBack(225); // HENRIETTA
			MarkizaDeck.cardIndices.PushBack(226); // SYANNA
			MarkizaDeck.cardIndices.PushBack(227); // ARTORIUS
			MarkizaDeck.cardIndices.PushBack(228); // VIVIENNE
			MarkizaDeck.cardIndices.PushBack(231); // RIENCE
			MarkizaDeck.cardIndices.PushBack(236); // VILGEFORTZ
			MarkizaDeck.cardIndices.PushBack(248); // LEO BONHART
			MarkizaDeck.cardIndices.PushBack(251); // DUCAL GUARD
			MarkizaDeck.cardIndices.PushBack(251); // DUCAL GUARD
			MarkizaDeck.cardIndices.PushBack(251); // DUCAL GUARD
			MarkizaDeck.cardIndices.PushBack(253); // MILTON
			MarkizaDeck.cardIndices.PushBack(254); // PALMERIN
			MarkizaDeck.cardIndices.PushBack(260); // YOUNG EMISSARY
			MarkizaDeck.cardIndices.PushBack(261); // GREGOIRE
			MarkizaDeck.cardIndices.PushBack(480); // AZAR JAVED
			MarkizaDeck.cardIndices.PushBack(481); // PROFESSOR
			
			MarkizaDeck.specialCard = 252;  // DAMIEN
			MarkizaDeck.leaderIndex = 2005; // FALSE CIRI
			enemyDecks.PushBack(MarkizaDeck);
			
			
			// GREMIST - DANGEROUS MAGIC DECK
			
			GremistaDeck.cardIndices.PushBack(1);   // MARDROEME
			GremistaDeck.cardIndices.PushBack(6);   // CLEAR SKY
			GremistaDeck.cardIndices.PushBack(26);  // CATRIONA PLAGUE

			GremistaDeck.cardIndices.PushBack(7);   // GERALT
			GremistaDeck.cardIndices.PushBack(9);   // YENNEFER
			GremistaDeck.cardIndices.PushBack(10);  // CIRI
			GremistaDeck.cardIndices.PushBack(202); // ARDAL
			GremistaDeck.cardIndices.PushBack(205); // ALBRICH
			GremistaDeck.cardIndices.PushBack(206); // ASSIRE
			GremistaDeck.cardIndices.PushBack(207); // CYNTHIA
			GremistaDeck.cardIndices.PushBack(208); // FRINGILLA
			GremistaDeck.cardIndices.PushBack(217); // VANHEMAR
			GremistaDeck.cardIndices.PushBack(226); // SYANNA
			GremistaDeck.cardIndices.PushBack(227); // ARTORIUS
			GremistaDeck.cardIndices.PushBack(228); // VIVIENNE
			GremistaDeck.cardIndices.PushBack(231); // RIENCE
			GremistaDeck.cardIndices.PushBack(236); // VILGEFORTZ
			GremistaDeck.cardIndices.PushBack(240); // HEAVY ZERRI SCORPION
			GremistaDeck.cardIndices.PushBack(241); // ZERRI SCORPION
			GremistaDeck.cardIndices.PushBack(241); // ZERRI SCORPION
			GremistaDeck.cardIndices.PushBack(241); // ZERRI SCORPION
			GremistaDeck.cardIndices.PushBack(249); // VICOVARO MEDIC
			GremistaDeck.cardIndices.PushBack(255); // SIEGE ENGINEER
			GremistaDeck.cardIndices.PushBack(480); // AZAR JAVED
			
			GremistaDeck.specialCard = 265;  // ALCHEMIST
			GremistaDeck.leaderIndex = 2003; // USURPER
			enemyDecks.PushBack(GremistaDeck);
	}
	
	private function SetupAIDeckDefinitions3()
	{
		var ZoltanDeck			:SDeckDefinition;
		var LambertDeck			:SDeckDefinition;
		var ThalerDeck			:SDeckDefinition;
		var VimmeDeck			:SDeckDefinition;
			
			
			// ZOLTAN - DWARVEN PRIDE DECK
			
			ZoltanDeck.cardIndices.PushBack(3);   // FROST
			ZoltanDeck.cardIndices.PushBack(3);   // FROST
			ZoltanDeck.cardIndices.PushBack(6);   // CLEAR SKY
			
			ZoltanDeck.cardIndices.PushBack(7);   // GERALT
			ZoltanDeck.cardIndices.PushBack(15);  // VILLEN
			ZoltanDeck.cardIndices.PushBack(301); // SASKIA
			ZoltanDeck.cardIndices.PushBack(305); // DENNIS
			ZoltanDeck.cardIndices.PushBack(326); // LADY OF THE LAKE
			ZoltanDeck.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ZoltanDeck.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ZoltanDeck.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ZoltanDeck.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ZoltanDeck.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ZoltanDeck.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ZoltanDeck.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ZoltanDeck.cardIndices.PushBack(341); // PERCIVAL
			ZoltanDeck.cardIndices.PushBack(342); // DWARF CHARIOT
			ZoltanDeck.cardIndices.PushBack(343); // DWARF MERCENARY
			ZoltanDeck.cardIndices.PushBack(343); // DWARF MERCENARY
			ZoltanDeck.cardIndices.PushBack(343); // DWARF MERCENARY
			ZoltanDeck.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ZoltanDeck.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ZoltanDeck.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ZoltanDeck.cardIndices.PushBack(366); // HATTORI

			ZoltanDeck.specialCard = 313;  // BARCLAY
			ZoltanDeck.leaderIndex = 3001; // BROUVER
			enemyDecks.PushBack(ZoltanDeck);
			
			
			// LAMBERT - WARBRINGERS DECK
			
			LambertDeck.cardIndices.PushBack(6);   // CLEAR SKY
			LambertDeck.cardIndices.PushBack(28);  // NATURE'S REBUKE
			LambertDeck.cardIndices.PushBack(29);  // WATER OF BROKILON
			
			LambertDeck.cardIndices.PushBack(7);   // GERALT
			LambertDeck.cardIndices.PushBack(9);   // YENNEFER
			LambertDeck.cardIndices.PushBack(10);  // CIRI
			LambertDeck.cardIndices.PushBack(15);  // VILLEN
			LambertDeck.cardIndices.PushBack(136); // LAMBERT
			LambertDeck.cardIndices.PushBack(300); // SIRSSA
			LambertDeck.cardIndices.PushBack(303); // IORVETH
			LambertDeck.cardIndices.PushBack(307); // IDA EMEAN
			LambertDeck.cardIndices.PushBack(316); // BRAENN
			LambertDeck.cardIndices.PushBack(318); // MORENN
			LambertDeck.cardIndices.PushBack(321); // VERNOSSIEL
			LambertDeck.cardIndices.PushBack(331); // DOL BLATHA BOMBER
			LambertDeck.cardIndices.PushBack(342); // DWARVEN CHARIOT
			LambertDeck.cardIndices.PushBack(343); // DWARVEN MERCENARY
			LambertDeck.cardIndices.PushBack(343); // DWARVEN MERCENARY
			LambertDeck.cardIndices.PushBack(343); // DWARVEN MERCENARY
			LambertDeck.cardIndices.PushBack(352); // ELE'YAS
			LambertDeck.cardIndices.PushBack(367); // AELIRENN
			LambertDeck.cardIndices.PushBack(368); // SCHIRRU
			LambertDeck.cardIndices.PushBack(480); // AZAR JAVED
			LambertDeck.cardIndices.PushBack(481); // PROFESSOR
			
			LambertDeck.specialCard = 301;  // SASKIA
			LambertDeck.leaderIndex = 3004; // FRANCESCA
			enemyDecks.PushBack(LambertDeck);
			
			
			// THALER - ROGUE SQUADRON DECK
			
			ThalerDeck.cardIndices.PushBack(0);   // DECOY
			ThalerDeck.cardIndices.PushBack(1);   // MARDROEME
			ThalerDeck.cardIndices.PushBack(2);   // FOREST OF DEATH
			
			ThalerDeck.cardIndices.PushBack(302); // ISENGRIM
			ThalerDeck.cardIndices.PushBack(303); // IORVETH
			ThalerDeck.cardIndices.PushBack(309); // YAEVINN
			ThalerDeck.cardIndices.PushBack(312); // CIARAN
			ThalerDeck.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ThalerDeck.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ThalerDeck.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ThalerDeck.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ThalerDeck.cardIndices.PushBack(321); // VERNOSSIEL
			ThalerDeck.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ThalerDeck.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ThalerDeck.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ThalerDeck.cardIndices.PushBack(331); // DOL BLATHA BOMBER
			ThalerDeck.cardIndices.PushBack(341); // PERCIVAL
			ThalerDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			ThalerDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			ThalerDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			ThalerDeck.cardIndices.PushBack(352); // ELE'YAS
			ThalerDeck.cardIndices.PushBack(360); // DOL BLATHA ARCHER
			ThalerDeck.cardIndices.PushBack(360); // DOL BLATHA ARCHER
			ThalerDeck.cardIndices.PushBack(366); // HATTORI
			
			ThalerDeck.specialCard = 322;  // MALENA
			ThalerDeck.leaderIndex = 3003; // ITHLINNE
			enemyDecks.PushBack(ThalerDeck);
			
			
			// VIVALDI - THE JUNGLE BOOK DECK
			
			VimmeDeck.cardIndices.PushBack(2);   // FOREST OF DEATH
			VimmeDeck.cardIndices.PushBack(28);  // NATURE'S REBUKE
			VimmeDeck.cardIndices.PushBack(29);  // WATER OF BROKILON
			
			VimmeDeck.cardIndices.PushBack(300); // SIRSSA
			VimmeDeck.cardIndices.PushBack(302); // ISENGRIM
			VimmeDeck.cardIndices.PushBack(303); // IORVETH
			VimmeDeck.cardIndices.PushBack(306); // MILVA
			VimmeDeck.cardIndices.PushBack(308); // FILAVANDREL
			VimmeDeck.cardIndices.PushBack(309); // YAEVINN
			VimmeDeck.cardIndices.PushBack(315); // AGLAIS
			VimmeDeck.cardIndices.PushBack(317); // FAUVE
			VimmeDeck.cardIndices.PushBack(318); // MORENN
			VimmeDeck.cardIndices.PushBack(321); // VERNOSSIEL
			VimmeDeck.cardIndices.PushBack(344); // BROKILON SENTINEL
			VimmeDeck.cardIndices.PushBack(344); // BROKILON SENTINEL
			VimmeDeck.cardIndices.PushBack(344); // BROKILON SENTINEL
			VimmeDeck.cardIndices.PushBack(345); // DRYAD GROVEKEEPER
			VimmeDeck.cardIndices.PushBack(346); // TREANT: BOAR
			VimmeDeck.cardIndices.PushBack(346); // TREANT: BOAR
			VimmeDeck.cardIndices.PushBack(347); // TREANT: MANTIS
			VimmeDeck.cardIndices.PushBack(347); // TREANT: MANTIS
			VimmeDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			VimmeDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			VimmeDeck.cardIndices.PushBack(350); // ELF SKIRMISHER
			
			VimmeDeck.specialCard = 316;  // BRAENN
			VimmeDeck.leaderIndex = 3002; // EITHNE
			enemyDecks.PushBack(VimmeDeck);
	}
	
	private function SetupAIDeckDefinitions4()
	{
		var CrachDeck			:SDeckDefinition;
		var LugosDeck			:SDeckDefinition;
		var HermitDeck			:SDeckDefinition;
		var OlivierDeck			:SDeckDefinition;
		var MousesackDeck		:SDeckDefinition;
			
			
			// CRACH - CLASH OF CLANS DECK
			
			CrachDeck.cardIndices.PushBack(5);   // RAIN
			CrachDeck.cardIndices.PushBack(23);  // SKELLIGE STORM
			CrachDeck.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			CrachDeck.cardIndices.PushBack(501); // HJALMAR
			CrachDeck.cardIndices.PushBack(506); // MADMAN
			CrachDeck.cardIndices.PushBack(510); // BLUEBOY
			CrachDeck.cardIndices.PushBack(511); // SVANRIGE
			CrachDeck.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			CrachDeck.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			CrachDeck.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			CrachDeck.cardIndices.PushBack(519); // HEYMAEY SKALD
			CrachDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			CrachDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			CrachDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			CrachDeck.cardIndices.PushBack(522); // BROKVAR ARCHER
			CrachDeck.cardIndices.PushBack(522); // BROKVAR ARCHER
			CrachDeck.cardIndices.PushBack(522); // BROKVAR ARCHER
			CrachDeck.cardIndices.PushBack(523); // DRUMMOND MAIDEN (1)
			CrachDeck.cardIndices.PushBack(524); // DIMUN CORSAIR
			CrachDeck.cardIndices.PushBack(526); // DRUMMOND MAIDEN (2)
			CrachDeck.cardIndices.PushBack(527); // DRUMMOND MAIDEN (3)
			CrachDeck.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			CrachDeck.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			CrachDeck.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			
			CrachDeck.specialCard = 509;  // BIRNA
			CrachDeck.leaderIndex = 5005; // CERYS
			enemyDecks.PushBack(CrachDeck);
			
			
			// LUGOS - BATMONSTERS DECK
			
			LugosDeck.cardIndices.PushBack(1);   // MARDROEME
			LugosDeck.cardIndices.PushBack(5);   // RAIN
			LugosDeck.cardIndices.PushBack(30);  // BLOOD MOON
			
			LugosDeck.cardIndices.PushBack(14);  // EMIEL REGIS
			LugosDeck.cardIndices.PushBack(335); // SIREN (1)
			LugosDeck.cardIndices.PushBack(336); // SIREN (2)
			LugosDeck.cardIndices.PushBack(337); // SIREN (3)
			LugosDeck.cardIndices.PushBack(415); // HUBERT REJK
			LugosDeck.cardIndices.PushBack(430); // HARPY
			LugosDeck.cardIndices.PushBack(430); // HARPY
			LugosDeck.cardIndices.PushBack(430); // HARPY
			LugosDeck.cardIndices.PushBack(435); // QUEEN OF THE NIGHT
			LugosDeck.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			LugosDeck.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			LugosDeck.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			LugosDeck.cardIndices.PushBack(460); // VAMPIRE: EKKIMA
			LugosDeck.cardIndices.PushBack(461); // VAMPIRE: FLEDER
			LugosDeck.cardIndices.PushBack(462); // VAMPIRE: GARKAIN
			LugosDeck.cardIndices.PushBack(464); // GAEL
			LugosDeck.cardIndices.PushBack(465); // VAMPIRE: ALP
			LugosDeck.cardIndices.PushBack(466); // DETTLAFF
			LugosDeck.cardIndices.PushBack(470); // GHOUL
			LugosDeck.cardIndices.PushBack(470); // GHOUL
			LugosDeck.cardIndices.PushBack(470); // GHOUL
			
			LugosDeck.specialCard = 463;  // ORIANNA
			LugosDeck.leaderIndex = 4004; // UNSEEN ELDER
			enemyDecks.PushBack(LugosDeck);
			
			
			// OLD SAGE - SVALBLOD OR DIE DECK
			
			HermitDeck.cardIndices.PushBack(0);   // DECOY
			HermitDeck.cardIndices.PushBack(23);  // SKELLIGE STORM
			HermitDeck.cardIndices.PushBack(27);  // RAGH NAR ROOG
			
			HermitDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			HermitDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			HermitDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			HermitDeck.cardIndices.PushBack(417); // MORKVARG
			HermitDeck.cardIndices.PushBack(501); // HJALMAR
			HermitDeck.cardIndices.PushBack(503); // ERMION
			HermitDeck.cardIndices.PushBack(506); // MADMAN
			HermitDeck.cardIndices.PushBack(508); // UDALRYK
			HermitDeck.cardIndices.PushBack(509); // BIRNA
			HermitDeck.cardIndices.PushBack(510); // BLUEBOY
			HermitDeck.cardIndices.PushBack(511); // SVANRIGE
			HermitDeck.cardIndices.PushBack(512); // OLAF
			HermitDeck.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			HermitDeck.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			HermitDeck.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			HermitDeck.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			HermitDeck.cardIndices.PushBack(561); // TYR
			HermitDeck.cardIndices.PushBack(562); // ARTIS
			HermitDeck.cardIndices.PushBack(563); // VABJORN
			HermitDeck.cardIndices.PushBack(564); // SVALBLOD
			HermitDeck.cardIndices.PushBack(565); // KNUT
			
			HermitDeck.specialCard = 513;  // VILDKAARL BUTCHER
			HermitDeck.leaderIndex = 5003; // HARALD
			enemyDecks.PushBack(HermitDeck);
			
			
			// OLIVIER - MOST WANTED DECK
			
			OlivierDeck.cardIndices.PushBack(3);   // FROST
			OlivierDeck.cardIndices.PushBack(4);   // FOG
			OlivierDeck.cardIndices.PushBack(5);   // RAIN
			
			OlivierDeck.cardIndices.PushBack(400); // DRAUG
			OlivierDeck.cardIndices.PushBack(401); // KAYRAN
			OlivierDeck.cardIndices.PushBack(404); // DAGON
			OlivierDeck.cardIndices.PushBack(410); // MORVUDD
			OlivierDeck.cardIndices.PushBack(413); // ANABELLE
			OlivierDeck.cardIndices.PushBack(425); // MYRHYFF
			OlivierDeck.cardIndices.PushBack(427); // DROWNER
			OlivierDeck.cardIndices.PushBack(427); // DROWNER
			OlivierDeck.cardIndices.PushBack(427); // DROWNER
			OlivierDeck.cardIndices.PushBack(440); // ABAYA
			OlivierDeck.cardIndices.PushBack(450); // ARACHAS BEHEMOTH
			OlivierDeck.cardIndices.PushBack(451); // ARACHAS
			OlivierDeck.cardIndices.PushBack(451); // ARACHAS
			OlivierDeck.cardIndices.PushBack(451); // ARACHAS
			OlivierDeck.cardIndices.PushBack(453); // WOLF
			OlivierDeck.cardIndices.PushBack(453); // WOLF
			OlivierDeck.cardIndices.PushBack(453); // WOLF
			OlivierDeck.cardIndices.PushBack(464); // GAEL
			OlivierDeck.cardIndices.PushBack(466); // DETTLAFF
			OlivierDeck.cardIndices.PushBack(478); // TOAD PRINCE
			OlivierDeck.cardIndices.PushBack(496); // ADDA
			
			OlivierDeck.specialCard = 403;  // WOODLAND SPIRIT
			OlivierDeck.leaderIndex = 4002; // GHOST IN THE TREE
			enemyDecks.PushBack(OlivierDeck);
			
			
			// ERMION - PURE EVIL DECK
			
			MousesackDeck.cardIndices.PushBack(5);   // RAIN
			MousesackDeck.cardIndices.PushBack(6);   // CLEAR SKY
			MousesackDeck.cardIndices.PushBack(24);  // WHITE FROST
			
			MousesackDeck.cardIndices.PushBack(7);   // GERALT
			MousesackDeck.cardIndices.PushBack(10);  // CIRI
			MousesackDeck.cardIndices.PushBack(16);  // AVALLAC'H
			MousesackDeck.cardIndices.PushBack(402); // IMLERITH
			MousesackDeck.cardIndices.PushBack(408); // CARANTHIR
			MousesackDeck.cardIndices.PushBack(409); // NITHRAL
			MousesackDeck.cardIndices.PushBack(423); // FRIGHTENER
			MousesackDeck.cardIndices.PushBack(480); // AZAR JAVED
			MousesackDeck.cardIndices.PushBack(481); // PROFESSOR
			MousesackDeck.cardIndices.PushBack(482); // SAVOLLA
			MousesackDeck.cardIndices.PushBack(490); // NAGLFAR
			MousesackDeck.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			MousesackDeck.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			MousesackDeck.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			MousesackDeck.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			MousesackDeck.cardIndices.PushBack(492); // WILD HUNT RIDER (1)
			MousesackDeck.cardIndices.PushBack(493); // WILD HUNT RIDER (2)
			MousesackDeck.cardIndices.PushBack(494); // WILD HUNT RIDER (3)
			MousesackDeck.cardIndices.PushBack(495); // WILD HUNT HOUND
			MousesackDeck.cardIndices.PushBack(495); // WILD HUNT HOUND
			MousesackDeck.cardIndices.PushBack(495); // WILD HUNT HOUND
			
			MousesackDeck.specialCard = 498;  // WILD HUNT NAVIGATOR
			MousesackDeck.leaderIndex = 4001; // EREDIN
			enemyDecks.PushBack(MousesackDeck);
	}
	
	private function SetupAIDeckDefinitions5()
	{
		var ShaniDeck				:SDeckDefinition;
		var OlgierdDeck		    	:SDeckDefinition;
		var GamblerDeck				:SDeckDefinition;
		var CircusGwentAddictDeck   :SDeckDefinition;
			
			
			// SHANI - PIRATES OF THE CARIBEAN DECK
			
			ShaniDeck.cardIndices.PushBack(0);   // DECOY
			ShaniDeck.cardIndices.PushBack(3);   // FROST
			ShaniDeck.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			ShaniDeck.cardIndices.PushBack(501); // HJALMAR
			ShaniDeck.cardIndices.PushBack(504); // DRAIG
			ShaniDeck.cardIndices.PushBack(505); // BLACKHAND
			ShaniDeck.cardIndices.PushBack(507); // DONAR
			ShaniDeck.cardIndices.PushBack(519); // HEYMAEY SKALD
			ShaniDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			ShaniDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			ShaniDeck.cardIndices.PushBack(520); // LIGHT LONGSHIP
			ShaniDeck.cardIndices.PushBack(521); // WAR LONGSHIP
			ShaniDeck.cardIndices.PushBack(521); // WAR LONGSHIP
			ShaniDeck.cardIndices.PushBack(521); // WAR LONGSHIP
			ShaniDeck.cardIndices.PushBack(531); // CORAL
			ShaniDeck.cardIndices.PushBack(533); // DJENGE FRETT
			ShaniDeck.cardIndices.PushBack(534); // AN CRAITE WHALER
			ShaniDeck.cardIndices.PushBack(534); // AN CRAITE WHALER
			ShaniDeck.cardIndices.PushBack(535); // BOATBUILDERS
			ShaniDeck.cardIndices.PushBack(536); // SUKRUS
			ShaniDeck.cardIndices.PushBack(539); // DIMUN SMUGGLER
			ShaniDeck.cardIndices.PushBack(539); // DIMUN SMUGGLER
			ShaniDeck.cardIndices.PushBack(539); // DIMUN SMUGGLER
			ShaniDeck.cardIndices.PushBack(540); // DIMUN CAPTAIN
			
			ShaniDeck.specialCard = 524;  // DIMUN CORSAIR
			ShaniDeck.leaderIndex = 5002; // CRACH
			enemyDecks.PushBack(ShaniDeck);
			
			
			// OLGIERD - THE LAST WISH DECK
			
			OlgierdDeck.cardIndices.PushBack(0);   // DECOY
			OlgierdDeck.cardIndices.PushBack(6);   // CLEAR SKY
			OlgierdDeck.cardIndices.PushBack(24);  // WHITE FROST
			
			OlgierdDeck.cardIndices.PushBack(7);   // GERALT
			OlgierdDeck.cardIndices.PushBack(9);   // YENNEFER
			OlgierdDeck.cardIndices.PushBack(18);  // OPERATOR
			OlgierdDeck.cardIndices.PushBack(403); // WOODLAND SPIRIT
			OlgierdDeck.cardIndices.PushBack(404); // DAGON
			OlgierdDeck.cardIndices.PushBack(405); // GOLYAT
			OlgierdDeck.cardIndices.PushBack(425); // MYRHYFF
			OlgierdDeck.cardIndices.PushBack(435); // QUEEN OF THE NIGHT
			OlgierdDeck.cardIndices.PushBack(436); // IRIS
			OlgierdDeck.cardIndices.PushBack(437); // IRIS' COMPANIONS
			OlgierdDeck.cardIndices.PushBack(453); // WOLF
			OlgierdDeck.cardIndices.PushBack(453); // WOLF
			OlgierdDeck.cardIndices.PushBack(453); // WOLF
			OlgierdDeck.cardIndices.PushBack(464); // GAEL
			OlgierdDeck.cardIndices.PushBack(471); // KIYAN
			OlgierdDeck.cardIndices.PushBack(475); // CRONE: WHISPESS
			OlgierdDeck.cardIndices.PushBack(476); // CRONE: BREWESS
			OlgierdDeck.cardIndices.PushBack(477); // CRONE: WEAVESS
			OlgierdDeck.cardIndices.PushBack(478); // TOAD PRINCE
			OlgierdDeck.cardIndices.PushBack(480); // AZAR JAVED
			OlgierdDeck.cardIndices.PushBack(481); // PROFESSOR
			
			OlgierdDeck.specialCard = 472;  // CARETAKER
			OlgierdDeck.leaderIndex = 4003; // GAUNTER
			enemyDecks.PushBack(OlgierdDeck);
			
			
			// HILBERT - EMPIRE DECK
			
			GamblerDeck.cardIndices.PushBack(5);   // RAIN
			GamblerDeck.cardIndices.PushBack(5);   // RAIN
			GamblerDeck.cardIndices.PushBack(6);   // CLEAR SKY
			
			GamblerDeck.cardIndices.PushBack(201); // MENNO
			GamblerDeck.cardIndices.PushBack(203); // TIBOR
			GamblerDeck.cardIndices.PushBack(210); // RAINFARN
			GamblerDeck.cardIndices.PushBack(215); // SWEERS
			GamblerDeck.cardIndices.PushBack(216); // JOACHIM
			GamblerDeck.cardIndices.PushBack(219); // VREEMDE
			GamblerDeck.cardIndices.PushBack(220); // CAHIR
			GamblerDeck.cardIndices.PushBack(221); // PUTTKAMMER
			GamblerDeck.cardIndices.PushBack(245); // ALBA DIVISION
			GamblerDeck.cardIndices.PushBack(245); // ALBA DIVISION
			GamblerDeck.cardIndices.PushBack(245); // ALBA DIVISION
			GamblerDeck.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			GamblerDeck.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			GamblerDeck.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			GamblerDeck.cardIndices.PushBack(251); // DUCAL GUARD
			GamblerDeck.cardIndices.PushBack(251); // DUCAL GUARD
			GamblerDeck.cardIndices.PushBack(251); // DUCAL GUARD
			GamblerDeck.cardIndices.PushBack(252); // DAMIEN
			GamblerDeck.cardIndices.PushBack(253); // MILTON
			GamblerDeck.cardIndices.PushBack(254); // PALMERIN
			GamblerDeck.cardIndices.PushBack(261); // GREGOIRE
			
			GamblerDeck.specialCard = 209;  // PETER SAAR
			GamblerDeck.leaderIndex = 2001; // MORVRAN
			enemyDecks.PushBack(GamblerDeck);
			
			
			// CIRCUS' MERCHANT - GODS AMONG US DECK
			
			CircusGwentAddictDeck.cardIndices.PushBack(23);  // SKELLIGE STORM
			CircusGwentAddictDeck.cardIndices.PushBack(27);  // RAGH NAR ROOG
			CircusGwentAddictDeck.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			CircusGwentAddictDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			CircusGwentAddictDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			CircusGwentAddictDeck.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			CircusGwentAddictDeck.cardIndices.PushBack(417); // MORKVARG
			CircusGwentAddictDeck.cardIndices.PushBack(503); // ERMION
			CircusGwentAddictDeck.cardIndices.PushBack(506); // MADMAN
			CircusGwentAddictDeck.cardIndices.PushBack(508); // UDALRYK
			CircusGwentAddictDeck.cardIndices.PushBack(510); // BLUEBOY
			CircusGwentAddictDeck.cardIndices.PushBack(512); // OLAF
			CircusGwentAddictDeck.cardIndices.PushBack(523); // DRUMMOND MAIDEN (1)
			CircusGwentAddictDeck.cardIndices.PushBack(526); // DRUMMOND MAIDEN (2)
			CircusGwentAddictDeck.cardIndices.PushBack(527); // DRUMMOND MAIDEN (3)
			CircusGwentAddictDeck.cardIndices.PushBack(528); // JUTTA
			CircusGwentAddictDeck.cardIndices.PushBack(529); // SKJALL
			CircusGwentAddictDeck.cardIndices.PushBack(531); // CORAL
			CircusGwentAddictDeck.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			CircusGwentAddictDeck.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			CircusGwentAddictDeck.cardIndices.PushBack(561); // TYR
			CircusGwentAddictDeck.cardIndices.PushBack(562); // ARTIS
			CircusGwentAddictDeck.cardIndices.PushBack(564); // SVALBLOD
			CircusGwentAddictDeck.cardIndices.PushBack(565); // KNUT
			
			CircusGwentAddictDeck.specialCard = 525;  // KAMBI
			CircusGwentAddictDeck.leaderIndex = 5004; // EIST
			enemyDecks.PushBack(CircusGwentAddictDeck);
	}
	
	private function SetupAIDeckDefinitionsNK()
	{
		var NKRandomA		:SDeckDefinition;
		var NKRandomB		:SDeckDefinition;
		var NKRandomC		:SDeckDefinition;
		var NKRandomD		:SDeckDefinition;
		var NKRandomE		:SDeckDefinition;
			
			
			NKRandomA.cardIndices.PushBack(0);   // DECOY
			NKRandomA.cardIndices.PushBack(4);   // FOG
			NKRandomA.cardIndices.PushBack(4);   // FOG
			
			NKRandomA.cardIndices.PushBack(109); // DIJKSTRA
			NKRandomA.cardIndices.PushBack(141); // CALEB MENGE
			NKRandomA.cardIndices.PushBack(142); // NATHANIEL
			NKRandomA.cardIndices.PushBack(147); // CUTUP LACKEY
			NKRandomA.cardIndices.PushBack(147); // CUTUP LACKEY
			NKRandomA.cardIndices.PushBack(147); // CUTUP LACKEY
			NKRandomA.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomA.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomA.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomA.cardIndices.PushBack(151); // BEGGAR
			NKRandomA.cardIndices.PushBack(151); // BEGGAR
			NKRandomA.cardIndices.PushBack(151); // BEGGAR
			NKRandomA.cardIndices.PushBack(152); // PASSIFLORA PEACHES
			NKRandomA.cardIndices.PushBack(165); // KING OF BEGGARS
			NKRandomA.cardIndices.PushBack(166); // WHORESON JUNIOR
			NKRandomA.cardIndices.PushBack(167); // CARLO VARESE
			NKRandomA.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomA.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomA.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomA.cardIndices.PushBack(176); // IGOR
			NKRandomA.cardIndices.PushBack(447); // TATTERWING
			NKRandomA.cardIndices.PushBack(448); // BORIS
			
			NKRandomA.specialCard = -1;
			NKRandomA.leaderIndex = 1001; // DEMAVEND
			enemyDecks.PushBack(NKRandomA);
			
			
			NKRandomB.cardIndices.PushBack(5);   // RAIN
			NKRandomB.cardIndices.PushBack(6);   // CLEAR SKY
			NKRandomB.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKRandomB.cardIndices.PushBack(7);   // GERALT
			NKRandomB.cardIndices.PushBack(8);   // VESEMIR
			NKRandomB.cardIndices.PushBack(9);   // YENNEFER
			NKRandomB.cardIndices.PushBack(10);  // CIRI
			NKRandomB.cardIndices.PushBack(11);  // TRISS
			NKRandomB.cardIndices.PushBack(12);  // DANDELION
			NKRandomB.cardIndices.PushBack(13);  // ZOLTAN
			NKRandomB.cardIndices.PushBack(100); // VERNON
			NKRandomB.cardIndices.PushBack(101); // NATALIS
			NKRandomB.cardIndices.PushBack(106); // VES
			NKRandomB.cardIndices.PushBack(107); // SHANI
			NKRandomB.cardIndices.PushBack(108); // YARPEN
			NKRandomB.cardIndices.PushBack(109); // DIJKSTRA
			NKRandomB.cardIndices.PushBack(111); // KEIRA
			NKRandomB.cardIndices.PushBack(112); // SILE
			NKRandomB.cardIndices.PushBack(114); // SHELDON
			NKRandomB.cardIndices.PushBack(117); // VINCENT MEIS
			NKRandomB.cardIndices.PushBack(135); // ESKEL
			NKRandomB.cardIndices.PushBack(136); // LAMBERT
			NKRandomB.cardIndices.PushBack(161); // BLUE STRIPES (1)
			NKRandomB.cardIndices.PushBack(162); // BLUE STRIPES (2)
			NKRandomB.cardIndices.PushBack(163); // BLUE STRIPES (3)
			
			NKRandomB.specialCard = -1;
			NKRandomB.leaderIndex = 1002; // FOLTEST
			enemyDecks.PushBack(NKRandomB);
			
			
			NKRandomC.cardIndices.PushBack(0);   // DECOY
			NKRandomC.cardIndices.PushBack(1);   // MARDROEME
			NKRandomC.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKRandomC.cardIndices.PushBack(100); // VERNON
			NKRandomC.cardIndices.PushBack(101); // NATALIS
			NKRandomC.cardIndices.PushBack(102); // VISSEGERD
			NKRandomC.cardIndices.PushBack(106); // VES
			NKRandomC.cardIndices.PushBack(120); // TREBUCHET
			NKRandomC.cardIndices.PushBack(120); // TREBUCHET
			NKRandomC.cardIndices.PushBack(121); // POOR INFANTRY (1)
			NKRandomC.cardIndices.PushBack(125); // BALLISTA
			NKRandomC.cardIndices.PushBack(125); // BALLISTA
			NKRandomC.cardIndices.PushBack(126); // POOR INFANTRY (1)
			NKRandomC.cardIndices.PushBack(127); // POOR INFANTRY (1)
			NKRandomC.cardIndices.PushBack(140); // CATAPULT
			NKRandomC.cardIndices.PushBack(140); // CATAPULT
			NKRandomC.cardIndices.PushBack(145); // KAEDWENI EXPERT
			NKRandomC.cardIndices.PushBack(146); // KAEDWENI SUPPORT
			NKRandomC.cardIndices.PushBack(161); // BLUE STRIPES (1)
			NKRandomC.cardIndices.PushBack(162); // BLUE STRIPES (2)
			NKRandomC.cardIndices.PushBack(163); // BLUE STRIPES (3)
			NKRandomC.cardIndices.PushBack(170); // SIEGE TOWER
			NKRandomC.cardIndices.PushBack(175); // DUN BANNER MEDIC
			NKRandomC.cardIndices.PushBack(420); // BOTCHLING
			NKRandomC.cardIndices.PushBack(422); // BLOODY BARON
			
			NKRandomC.specialCard = -1;
			NKRandomC.leaderIndex = 1003; // CALANTHE
			enemyDecks.PushBack(NKRandomC);
			
			
			NKRandomD.cardIndices.PushBack(4);   // FOG
			NKRandomD.cardIndices.PushBack(5);   // RAIN
			NKRandomD.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKRandomD.cardIndices.PushBack(7);   // GERALT
			NKRandomD.cardIndices.PushBack(8);   // VESEMIR
			NKRandomD.cardIndices.PushBack(12);  // DANDELION
			NKRandomD.cardIndices.PushBack(13);  // ZOLTAN
			NKRandomD.cardIndices.PushBack(17);  // OLGIERD
			NKRandomD.cardIndices.PushBack(102); // VISSEGERD
			NKRandomD.cardIndices.PushBack(104); // JACQUES
			NKRandomD.cardIndices.PushBack(108); // YARPEN
			NKRandomD.cardIndices.PushBack(114); // SHELDON
			NKRandomD.cardIndices.PushBack(130); // CRINFRID REAVERS (1)
			NKRandomD.cardIndices.PushBack(131); // CRINFRID REAVERS (2)
			NKRandomD.cardIndices.PushBack(132); // CRINFRID REAVERS (3)
			NKRandomD.cardIndices.PushBack(143); // LEBIODA
			NKRandomD.cardIndices.PushBack(155); // CLERIC FLAMING ROSE
			NKRandomD.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomD.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomD.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomD.cardIndices.PushBack(167); // CARLO VARESE
			NKRandomD.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomD.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomD.cardIndices.PushBack(171); // CROWNSPLITTER THUG
			NKRandomD.cardIndices.PushBack(422); // BLOODY BARON
			
			NKRandomD.specialCard = -1;
			NKRandomD.leaderIndex = 1004; // HENSELT
			enemyDecks.PushBack(NKRandomD);
			
			
			NKRandomE.cardIndices.PushBack(5);   // RAIN
			NKRandomE.cardIndices.PushBack(6);   // CLEAR SKY
			NKRandomE.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKRandomE.cardIndices.PushBack(7);   // GERALT
			NKRandomE.cardIndices.PushBack(9);   // YENNEFER
			NKRandomE.cardIndices.PushBack(10);  // CIRI
			NKRandomE.cardIndices.PushBack(11);  // TRISS
			NKRandomE.cardIndices.PushBack(103); // PHILIPPA
			NKRandomE.cardIndices.PushBack(104); // JACQUES
			NKRandomE.cardIndices.PushBack(111); // KEIRA
			NKRandomE.cardIndices.PushBack(112); // SILE
			NKRandomE.cardIndices.PushBack(113); // SABRINA
			NKRandomE.cardIndices.PushBack(115); // DETHMOLD
			NKRandomE.cardIndices.PushBack(141); // CALEB MENGE
			NKRandomE.cardIndices.PushBack(142); // NATHANIEL
			NKRandomE.cardIndices.PushBack(143); // LEBIODA
			NKRandomE.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomE.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomE.cardIndices.PushBack(150); // WITCH HUNTER
			NKRandomE.cardIndices.PushBack(155); // CLERIC FLAMING ROSE
			NKRandomE.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomE.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomE.cardIndices.PushBack(156); // KNIGHT FLAMING ROSE
			NKRandomE.cardIndices.PushBack(480); // AZAR JAVED
			NKRandomE.cardIndices.PushBack(481); // PROFESSOR
			
			NKRandomE.specialCard = -1;
			NKRandomE.leaderIndex = 1005; // RADOVID
			enemyDecks.PushBack(NKRandomE);
	}
	
	private function SetupAIDeckDefinitionsNilf()
	{
		var NilfRandomA		:SDeckDefinition;
		var NilfRandomB		:SDeckDefinition;
		var NilfRandomC		:SDeckDefinition;
		var NilfRandomD		:SDeckDefinition;
		var NilfRandomE		:SDeckDefinition;
			
			
			NilfRandomA.cardIndices.PushBack(5);   // RAIN
			NilfRandomA.cardIndices.PushBack(5);   // RAIN
			NilfRandomA.cardIndices.PushBack(6);   // CLEAR SKY
			
			NilfRandomA.cardIndices.PushBack(201); // MENNO
			NilfRandomA.cardIndices.PushBack(203); // TIBOR
			NilfRandomA.cardIndices.PushBack(209); // PETER SAAR
			NilfRandomA.cardIndices.PushBack(210); // RAINFARN
			NilfRandomA.cardIndices.PushBack(215); // SWEERS
			NilfRandomA.cardIndices.PushBack(216); // JOACHIM
			NilfRandomA.cardIndices.PushBack(219); // VREEMDE
			NilfRandomA.cardIndices.PushBack(220); // CAHIR
			NilfRandomA.cardIndices.PushBack(221); // PUTTKAMMER
			NilfRandomA.cardIndices.PushBack(245); // ALBA DIVISION
			NilfRandomA.cardIndices.PushBack(245); // ALBA DIVISION
			NilfRandomA.cardIndices.PushBack(245); // ALBA DIVISION
			NilfRandomA.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfRandomA.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfRandomA.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfRandomA.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomA.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomA.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomA.cardIndices.PushBack(252); // DAMIEN
			NilfRandomA.cardIndices.PushBack(253); // MILTON
			NilfRandomA.cardIndices.PushBack(254); // PALMERIN
			NilfRandomA.cardIndices.PushBack(261); // GREGOIRE
			
			NilfRandomA.specialCard = -1;
			NilfRandomA.leaderIndex = 2001; // MORVRAN
			enemyDecks.PushBack(NilfRandomA);
			
			
			NilfRandomB.cardIndices.PushBack(0);   // DECOY
			NilfRandomB.cardIndices.PushBack(1);   // MARDROEME
			NilfRandomB.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			NilfRandomB.cardIndices.PushBack(7);   // GERALT
			NilfRandomB.cardIndices.PushBack(8);   // VESEMIR
			NilfRandomB.cardIndices.PushBack(9);   // YENNEFER
			NilfRandomB.cardIndices.PushBack(10);  // CIRI
			NilfRandomB.cardIndices.PushBack(135); // ESKEL
			NilfRandomB.cardIndices.PushBack(136); // LAMBERT
			NilfRandomB.cardIndices.PushBack(200); // LETHO
			NilfRandomB.cardIndices.PushBack(214); // STEFAN
			NilfRandomB.cardIndices.PushBack(218); // VATTIER
			NilfRandomB.cardIndices.PushBack(220); // CAHIR
			NilfRandomB.cardIndices.PushBack(231); // RIENCE
			NilfRandomB.cardIndices.PushBack(236); // VILGEFORTZ
			NilfRandomB.cardIndices.PushBack(240); // HEAVY ZERRI SCORPION
			NilfRandomB.cardIndices.PushBack(241); // ZERRI SCORPION
			NilfRandomB.cardIndices.PushBack(241); // ZERRI SCORPION
			NilfRandomB.cardIndices.PushBack(246); // SERRIT
			NilfRandomB.cardIndices.PushBack(247); // AUCKES
			NilfRandomB.cardIndices.PushBack(248); // LEO BONHART
			NilfRandomB.cardIndices.PushBack(255); // SIEGE ENGINEER
			NilfRandomB.cardIndices.PushBack(265); // ALCHEMIST
			NilfRandomB.cardIndices.PushBack(480); // AZAR JAVED
			NilfRandomB.cardIndices.PushBack(481); // PROFESSOR
			
			NilfRandomB.specialCard = -1;
			NilfRandomB.leaderIndex = 2002; // EMHYR
			enemyDecks.PushBack(NilfRandomB);
			
			
			NilfRandomC.cardIndices.PushBack(1);   // MARDROEME
			NilfRandomC.cardIndices.PushBack(6);   // CLEAR SKY
			NilfRandomC.cardIndices.PushBack(26);  // CATRIONA PLAGUE

			NilfRandomC.cardIndices.PushBack(7);   // GERALT
			NilfRandomC.cardIndices.PushBack(9);   // YENNEFER
			NilfRandomC.cardIndices.PushBack(10);  // CIRI
			NilfRandomC.cardIndices.PushBack(202); // ARDAL
			NilfRandomC.cardIndices.PushBack(205); // ALBRICH
			NilfRandomC.cardIndices.PushBack(206); // ASSIRE
			NilfRandomC.cardIndices.PushBack(207); // CYNTHIA
			NilfRandomC.cardIndices.PushBack(208); // FRINGILLA
			NilfRandomC.cardIndices.PushBack(217); // VANHEMAR
			NilfRandomC.cardIndices.PushBack(226); // SYANNA
			NilfRandomC.cardIndices.PushBack(227); // ARTORIUS
			NilfRandomC.cardIndices.PushBack(228); // VIVIENNE
			NilfRandomC.cardIndices.PushBack(231); // RIENCE
			NilfRandomC.cardIndices.PushBack(236); // VILGEFORTZ
			NilfRandomC.cardIndices.PushBack(240); // HEAVY ZERRI SCORPION
			NilfRandomC.cardIndices.PushBack(241); // ZERRI SCORPION
			NilfRandomC.cardIndices.PushBack(241); // ZERRI SCORPION
			NilfRandomC.cardIndices.PushBack(241); // ZERRI SCORPION
			NilfRandomC.cardIndices.PushBack(249); // VICOVARO MEDIC
			NilfRandomC.cardIndices.PushBack(255); // SIEGE ENGINEER
			NilfRandomC.cardIndices.PushBack(265); // ALCHEMIST
			NilfRandomC.cardIndices.PushBack(480); // AZAR JAVED
			
			NilfRandomC.specialCard = -1;
			NilfRandomC.leaderIndex = 2003; // USURPER
			enemyDecks.PushBack(NilfRandomC);
			
			
			NilfRandomD.cardIndices.PushBack(0);   // DECOY
			NilfRandomD.cardIndices.PushBack(5);   // RAIN
			NilfRandomD.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			NilfRandomD.cardIndices.PushBack(200); // LETHO
			NilfRandomD.cardIndices.PushBack(206); // ASSIRE
			NilfRandomD.cardIndices.PushBack(207); // CYNTHIA
			NilfRandomD.cardIndices.PushBack(208); // FRINGILLA
			NilfRandomD.cardIndices.PushBack(213); // SHILARD
			NilfRandomD.cardIndices.PushBack(214); // STEFAN
			NilfRandomD.cardIndices.PushBack(217); // VANHEMAR
			NilfRandomD.cardIndices.PushBack(218); // VATTIER
			NilfRandomD.cardIndices.PushBack(220); // CAHIR
			NilfRandomD.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfRandomD.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfRandomD.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfRandomD.cardIndices.PushBack(231); // RIENCE
			NilfRandomD.cardIndices.PushBack(235); // BLACK ARCHER
			NilfRandomD.cardIndices.PushBack(235); // BLACK ARCHER
			NilfRandomD.cardIndices.PushBack(235); // BLACK ARCHER
			NilfRandomD.cardIndices.PushBack(236); // VILGEFORTZ
			NilfRandomD.cardIndices.PushBack(246); // SERRIT
			NilfRandomD.cardIndices.PushBack(247); // AUCKES
			NilfRandomD.cardIndices.PushBack(248); // LEO BONHART
			NilfRandomD.cardIndices.PushBack(249); // VICOVARO MEDIC
			NilfRandomD.cardIndices.PushBack(480); // AZAR JAVED
			
			NilfRandomD.specialCard = -1;
			NilfRandomD.leaderIndex = 2004; // CALVEIT
			enemyDecks.PushBack(NilfRandomD);
			
			
			NilfRandomE.cardIndices.PushBack(5);   // RAIN
			NilfRandomE.cardIndices.PushBack(6);   // CLEAR SKY
			NilfRandomE.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			NilfRandomE.cardIndices.PushBack(207); // CYNTHIA
			NilfRandomE.cardIndices.PushBack(211); // CANTARELLA
			NilfRandomE.cardIndices.PushBack(214); // STEFAN
			NilfRandomE.cardIndices.PushBack(217); // VANHEMAR
			NilfRandomE.cardIndices.PushBack(220); // CAHIR
			NilfRandomE.cardIndices.PushBack(225); // HENRIETTA
			NilfRandomE.cardIndices.PushBack(226); // SYANNA
			NilfRandomE.cardIndices.PushBack(227); // ARTORIUS
			NilfRandomE.cardIndices.PushBack(228); // VIVIENNE
			NilfRandomE.cardIndices.PushBack(231); // RIENCE
			NilfRandomE.cardIndices.PushBack(236); // VILGEFORTZ
			NilfRandomE.cardIndices.PushBack(248); // LEO BONHART
			NilfRandomE.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomE.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomE.cardIndices.PushBack(251); // DUCAL GUARD
			NilfRandomE.cardIndices.PushBack(252); // DAMIEN
			NilfRandomE.cardIndices.PushBack(253); // MILTON
			NilfRandomE.cardIndices.PushBack(254); // PALMERIN
			NilfRandomE.cardIndices.PushBack(260); // YOUNG EMISSARY
			NilfRandomE.cardIndices.PushBack(261); // GREGOIRE
			NilfRandomE.cardIndices.PushBack(480); // AZAR JAVED
			NilfRandomE.cardIndices.PushBack(481); // PROFESSOR
			
			NilfRandomE.specialCard = -1;
			NilfRandomE.leaderIndex = 2005; // FALSE CIRI
			enemyDecks.PushBack(NilfRandomE);
	}
	
	private function SetupAIDeckDefinitionsScoia()
	{
		var ScoiaRandomA		:SDeckDefinition;
		var ScoiaRandomB		:SDeckDefinition;
		var ScoiaRandomC		:SDeckDefinition;
		var ScoiaRandomD		:SDeckDefinition;
		var ScoiaRandomE		:SDeckDefinition;
			
			
			ScoiaRandomA.cardIndices.PushBack(3);   // FROST
			ScoiaRandomA.cardIndices.PushBack(3);   // FROST
			ScoiaRandomA.cardIndices.PushBack(6);   // CLEAR SKY
			
			ScoiaRandomA.cardIndices.PushBack(7);   // GERALT
			ScoiaRandomA.cardIndices.PushBack(15);  // VILLEN
			ScoiaRandomA.cardIndices.PushBack(301); // SASKIA
			ScoiaRandomA.cardIndices.PushBack(305); // DENNIS
			ScoiaRandomA.cardIndices.PushBack(313); // BARCLAY
			ScoiaRandomA.cardIndices.PushBack(326); // LADY OF THE LAKE
			ScoiaRandomA.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaRandomA.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaRandomA.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaRandomA.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaRandomA.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaRandomA.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaRandomA.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaRandomA.cardIndices.PushBack(341); // PERCIVAL
			ScoiaRandomA.cardIndices.PushBack(342); // DWARF CHARIOT
			ScoiaRandomA.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaRandomA.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaRandomA.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaRandomA.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaRandomA.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaRandomA.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaRandomA.cardIndices.PushBack(366); // HATTORI

			ScoiaRandomA.specialCard = -1;
			ScoiaRandomA.leaderIndex = 3001; // BROUVER
			enemyDecks.PushBack(ScoiaRandomA);
			
			
			ScoiaRandomB.cardIndices.PushBack(2);   // FOREST OF DEATH
			ScoiaRandomB.cardIndices.PushBack(28);  // NATURE'S REBUKE
			ScoiaRandomB.cardIndices.PushBack(29);  // WATER OF BROKILON
			
			ScoiaRandomB.cardIndices.PushBack(300); // SIRSSA
			ScoiaRandomB.cardIndices.PushBack(302); // ISENGRIM
			ScoiaRandomB.cardIndices.PushBack(303); // IORVETH
			ScoiaRandomB.cardIndices.PushBack(306); // MILVA
			ScoiaRandomB.cardIndices.PushBack(308); // FILAVANDREL
			ScoiaRandomB.cardIndices.PushBack(309); // YAEVINN
			ScoiaRandomB.cardIndices.PushBack(315); // AGLAIS
			ScoiaRandomB.cardIndices.PushBack(316); // BRAENN
			ScoiaRandomB.cardIndices.PushBack(317); // FAUVE
			ScoiaRandomB.cardIndices.PushBack(318); // MORENN
			ScoiaRandomB.cardIndices.PushBack(321); // VERNOSSIEL
			ScoiaRandomB.cardIndices.PushBack(344); // BROKILON SENTINEL
			ScoiaRandomB.cardIndices.PushBack(344); // BROKILON SENTINEL
			ScoiaRandomB.cardIndices.PushBack(344); // BROKILON SENTINEL
			ScoiaRandomB.cardIndices.PushBack(345); // DRYAD GROVEKEEPER
			ScoiaRandomB.cardIndices.PushBack(346); // TREANT: BOAR
			ScoiaRandomB.cardIndices.PushBack(346); // TREANT: BOAR
			ScoiaRandomB.cardIndices.PushBack(347); // TREANT: MANTIS
			ScoiaRandomB.cardIndices.PushBack(347); // TREANT: MANTIS
			ScoiaRandomB.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomB.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomB.cardIndices.PushBack(350); // ELF SKIRMISHER
			
			ScoiaRandomB.specialCard = -1;
			ScoiaRandomB.leaderIndex = 3002; // EITHNE
			enemyDecks.PushBack(ScoiaRandomB);
			
			
			ScoiaRandomC.cardIndices.PushBack(0);   // DECOY
			ScoiaRandomC.cardIndices.PushBack(1);   // MARDROEME
			ScoiaRandomC.cardIndices.PushBack(2);   // FOREST OF DEATH
			
			ScoiaRandomC.cardIndices.PushBack(302); // ISENGRIM
			ScoiaRandomC.cardIndices.PushBack(303); // IORVETH
			ScoiaRandomC.cardIndices.PushBack(309); // YAEVINN
			ScoiaRandomC.cardIndices.PushBack(312); // CIARAN
			ScoiaRandomC.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ScoiaRandomC.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ScoiaRandomC.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ScoiaRandomC.cardIndices.PushBack(320); // HAVEKAR SMUGGLER
			ScoiaRandomC.cardIndices.PushBack(321); // VERNOSSIEL
			ScoiaRandomC.cardIndices.PushBack(322); // MALENA
			ScoiaRandomC.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ScoiaRandomC.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ScoiaRandomC.cardIndices.PushBack(330); // DOL BLATHA SCOUT
			ScoiaRandomC.cardIndices.PushBack(331); // DOL BLATHA BOMBER
			ScoiaRandomC.cardIndices.PushBack(341); // PERCIVAL
			ScoiaRandomC.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomC.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomC.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomC.cardIndices.PushBack(352); // ELE'YAS
			ScoiaRandomC.cardIndices.PushBack(360); // DOL BLATHA ARCHER
			ScoiaRandomC.cardIndices.PushBack(360); // DOL BLATHA ARCHER
			ScoiaRandomC.cardIndices.PushBack(366); // HATTORI
			
			ScoiaRandomC.specialCard = -1;
			ScoiaRandomC.leaderIndex = 3003; // ITHLINNE
			enemyDecks.PushBack(ScoiaRandomC);
			
			
			ScoiaRandomD.cardIndices.PushBack(6);   // CLEAR SKY
			ScoiaRandomD.cardIndices.PushBack(28);  // NATURE'S REBUKE
			ScoiaRandomD.cardIndices.PushBack(29);  // WATER OF BROKILON
			
			ScoiaRandomD.cardIndices.PushBack(7);   // GERALT
			ScoiaRandomD.cardIndices.PushBack(9);   // YENNEFER
			ScoiaRandomD.cardIndices.PushBack(10);  // CIRI
			ScoiaRandomD.cardIndices.PushBack(15);  // VILLEN
			ScoiaRandomD.cardIndices.PushBack(136); // LAMBERT
			ScoiaRandomD.cardIndices.PushBack(300); // SIRSSA
			ScoiaRandomD.cardIndices.PushBack(301); // SASKIA
			ScoiaRandomD.cardIndices.PushBack(303); // IORVETH
			ScoiaRandomD.cardIndices.PushBack(307); // IDA EMEAN
			ScoiaRandomD.cardIndices.PushBack(316); // BRAENN
			ScoiaRandomD.cardIndices.PushBack(318); // MORENN
			ScoiaRandomD.cardIndices.PushBack(321); // VERNOSSIEL
			ScoiaRandomD.cardIndices.PushBack(331); // DOL BLATHA BOMBER
			ScoiaRandomD.cardIndices.PushBack(342); // DWARVEN CHARIOT
			ScoiaRandomD.cardIndices.PushBack(343); // DWARVEN MERCENARY
			ScoiaRandomD.cardIndices.PushBack(343); // DWARVEN MERCENARY
			ScoiaRandomD.cardIndices.PushBack(343); // DWARVEN MERCENARY
			ScoiaRandomD.cardIndices.PushBack(352); // ELE'YAS
			ScoiaRandomD.cardIndices.PushBack(367); // AELIRENN
			ScoiaRandomD.cardIndices.PushBack(368); // SCHIRRU
			ScoiaRandomD.cardIndices.PushBack(480); // AZAR JAVED
			ScoiaRandomD.cardIndices.PushBack(481); // PROFESSOR
			
			ScoiaRandomD.specialCard = -1;
			ScoiaRandomD.leaderIndex = 3004; // FRANCESCA
			enemyDecks.PushBack(ScoiaRandomD);
			
			
			ScoiaRandomE.cardIndices.PushBack(0);   // DECOY
			ScoiaRandomE.cardIndices.PushBack(1);   // MARDROEME
			ScoiaRandomE.cardIndices.PushBack(2);   // FOREST OF DEATH
			
			ScoiaRandomE.cardIndices.PushBack(301); // SASKIA
			ScoiaRandomE.cardIndices.PushBack(302); // ISENGRIM
			ScoiaRandomE.cardIndices.PushBack(303); // IORVETH
			ScoiaRandomE.cardIndices.PushBack(306); // MILVA
			ScoiaRandomE.cardIndices.PushBack(308); // FILAVANDREL
			ScoiaRandomE.cardIndices.PushBack(309); // YAEVINN
			ScoiaRandomE.cardIndices.PushBack(310); // TORUVIEL
			ScoiaRandomE.cardIndices.PushBack(311); // RIORDAIN
			ScoiaRandomE.cardIndices.PushBack(312); // CIARAN
			ScoiaRandomE.cardIndices.PushBack(321); // VERNOSSIEL
			ScoiaRandomE.cardIndices.PushBack(322); // MALENA
			ScoiaRandomE.cardIndices.PushBack(325); // VRIHEDD VETERAN
			ScoiaRandomE.cardIndices.PushBack(325); // VRIHEDD VETERAN
			ScoiaRandomE.cardIndices.PushBack(326); // LADY OF THE LAKE
			ScoiaRandomE.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomE.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomE.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaRandomE.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaRandomE.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaRandomE.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaRandomE.cardIndices.PushBack(365); // HAVEKAR HEALER
			ScoiaRandomE.cardIndices.PushBack(367); // AELIRENN
			
			ScoiaRandomE.specialCard = -1;
			ScoiaRandomE.leaderIndex = 3005; // DANA
			enemyDecks.PushBack(ScoiaRandomE);
	}
	
	private function SetupAIDeckDefinitionsNML()
	{
		var NMLRandomA		:SDeckDefinition;
		var NMLRandomB		:SDeckDefinition;
		var NMLRandomC		:SDeckDefinition;
		var NMLRandomD		:SDeckDefinition;
		var NMLRandomE		:SDeckDefinition;
			
			
			NMLRandomA.cardIndices.PushBack(5);   // RAIN
			NMLRandomA.cardIndices.PushBack(6);   // CLEAR SKY
			NMLRandomA.cardIndices.PushBack(24);  // WHITE FROST
			
			NMLRandomA.cardIndices.PushBack(7);   // GERALT
			NMLRandomA.cardIndices.PushBack(10);  // CIRI
			NMLRandomA.cardIndices.PushBack(16);  // AVALLAC'H
			NMLRandomA.cardIndices.PushBack(402); // IMLERITH
			NMLRandomA.cardIndices.PushBack(408); // CARANTHIR
			NMLRandomA.cardIndices.PushBack(409); // NITHRAL
			NMLRandomA.cardIndices.PushBack(423); // FRIGHTENER
			NMLRandomA.cardIndices.PushBack(480); // AZAR JAVED
			NMLRandomA.cardIndices.PushBack(481); // PROFESSOR
			NMLRandomA.cardIndices.PushBack(482); // SAVOLLA
			NMLRandomA.cardIndices.PushBack(490); // NAGLFAR
			NMLRandomA.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			NMLRandomA.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			NMLRandomA.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			NMLRandomA.cardIndices.PushBack(491); // WILD HUNT WARRIOR
			NMLRandomA.cardIndices.PushBack(492); // WILD HUNT RIDER (1)
			NMLRandomA.cardIndices.PushBack(493); // WILD HUNT RIDER (2)
			NMLRandomA.cardIndices.PushBack(494); // WILD HUNT RIDER (3)
			NMLRandomA.cardIndices.PushBack(495); // WILD HUNT HOUND
			NMLRandomA.cardIndices.PushBack(495); // WILD HUNT HOUND
			NMLRandomA.cardIndices.PushBack(495); // WILD HUNT HOUND
			NMLRandomA.cardIndices.PushBack(498); // WILD HUNT NAVIGATOR
			
			NMLRandomA.specialCard = -1;
			NMLRandomA.leaderIndex = 4001; // EREDIN
			enemyDecks.PushBack(NMLRandomA);
			
			
			NMLRandomB.cardIndices.PushBack(3);   // FROST
			NMLRandomB.cardIndices.PushBack(4);   // FOG
			NMLRandomB.cardIndices.PushBack(5);   // RAIN
			
			NMLRandomB.cardIndices.PushBack(400); // DRAUG
			NMLRandomB.cardIndices.PushBack(401); // KAYRAN
			NMLRandomB.cardIndices.PushBack(403); // WOODLAND SPIRIT
			NMLRandomB.cardIndices.PushBack(404); // DAGON
			NMLRandomB.cardIndices.PushBack(410); // MORVUDD
			NMLRandomB.cardIndices.PushBack(413); // ANABELLE
			NMLRandomB.cardIndices.PushBack(425); // MYRHYFF
			NMLRandomB.cardIndices.PushBack(427); // DROWNER
			NMLRandomB.cardIndices.PushBack(427); // DROWNER
			NMLRandomB.cardIndices.PushBack(427); // DROWNER
			NMLRandomB.cardIndices.PushBack(440); // ABAYA
			NMLRandomB.cardIndices.PushBack(450); // ARACHAS BEHEMOTH
			NMLRandomB.cardIndices.PushBack(451); // ARACHAS
			NMLRandomB.cardIndices.PushBack(451); // ARACHAS
			NMLRandomB.cardIndices.PushBack(451); // ARACHAS
			NMLRandomB.cardIndices.PushBack(453); // WOLF
			NMLRandomB.cardIndices.PushBack(453); // WOLF
			NMLRandomB.cardIndices.PushBack(453); // WOLF
			NMLRandomB.cardIndices.PushBack(464); // GAEL
			NMLRandomB.cardIndices.PushBack(466); // DETTLAFF
			NMLRandomB.cardIndices.PushBack(478); // TOAD PRINCE
			NMLRandomB.cardIndices.PushBack(496); // ADDA
			
			NMLRandomB.specialCard = -1;
			NMLRandomB.leaderIndex = 4002; // GHOST IN THE TREE
			enemyDecks.PushBack(NMLRandomB);
			
			
			NMLRandomC.cardIndices.PushBack(0);   // DECOY
			NMLRandomC.cardIndices.PushBack(6);   // CLEAR SKY
			NMLRandomC.cardIndices.PushBack(24);  // WHITE FROST
			
			NMLRandomC.cardIndices.PushBack(7);   // GERALT
			NMLRandomC.cardIndices.PushBack(9);   // YENNEFER
			NMLRandomC.cardIndices.PushBack(18);  // OPERATOR
			NMLRandomC.cardIndices.PushBack(403); // WOODLAND SPIRIT
			NMLRandomC.cardIndices.PushBack(404); // DAGON
			NMLRandomC.cardIndices.PushBack(405); // GOLYAT
			NMLRandomC.cardIndices.PushBack(425); // MYRHYFF
			NMLRandomC.cardIndices.PushBack(435); // QUEEN OF THE NIGHT
			NMLRandomC.cardIndices.PushBack(436); // IRIS
			NMLRandomC.cardIndices.PushBack(437); // IRIS' COMPANIONS
			NMLRandomC.cardIndices.PushBack(453); // WOLF
			NMLRandomC.cardIndices.PushBack(453); // WOLF
			NMLRandomC.cardIndices.PushBack(453); // WOLF
			NMLRandomC.cardIndices.PushBack(464); // GAEL
			NMLRandomC.cardIndices.PushBack(471); // KIYAN
			NMLRandomC.cardIndices.PushBack(472); // CARETAKER
			NMLRandomC.cardIndices.PushBack(475); // CRONE: WHISPESS
			NMLRandomC.cardIndices.PushBack(476); // CRONE: BREWESS
			NMLRandomC.cardIndices.PushBack(477); // CRONE: WEAVESS
			NMLRandomC.cardIndices.PushBack(478); // TOAD PRINCE
			NMLRandomC.cardIndices.PushBack(480); // AZAR JAVED
			NMLRandomC.cardIndices.PushBack(481); // PROFESSOR
			
			NMLRandomC.specialCard = -1;
			NMLRandomC.leaderIndex = 4003; // GAUNTER
			enemyDecks.PushBack(NMLRandomC);
			
			
			NMLRandomD.cardIndices.PushBack(1);   // MARDROEME
			NMLRandomD.cardIndices.PushBack(5);   // RAIN
			NMLRandomD.cardIndices.PushBack(30);  // BLOOD MOON
			
			NMLRandomD.cardIndices.PushBack(14);  // EMIEL REGIS
			NMLRandomD.cardIndices.PushBack(335); // SIREN (1)
			NMLRandomD.cardIndices.PushBack(336); // SIREN (2)
			NMLRandomD.cardIndices.PushBack(337); // SIREN (3)
			NMLRandomD.cardIndices.PushBack(415); // HUBERT REJK
			NMLRandomD.cardIndices.PushBack(430); // HARPY
			NMLRandomD.cardIndices.PushBack(430); // HARPY
			NMLRandomD.cardIndices.PushBack(430); // HARPY
			NMLRandomD.cardIndices.PushBack(435); // QUEEN OF THE NIGHT
			NMLRandomD.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			NMLRandomD.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			NMLRandomD.cardIndices.PushBack(452); // VAMPIRE: PLUMARD
			NMLRandomD.cardIndices.PushBack(460); // VAMPIRE: EKKIMA
			NMLRandomD.cardIndices.PushBack(461); // VAMPIRE: FLEDER
			NMLRandomD.cardIndices.PushBack(462); // VAMPIRE: GARKAIN
			NMLRandomD.cardIndices.PushBack(463); // ORIANNA
			NMLRandomD.cardIndices.PushBack(464); // GAEL
			NMLRandomD.cardIndices.PushBack(465); // VAMPIRE: ALP
			NMLRandomD.cardIndices.PushBack(466); // DETTLAFF
			NMLRandomD.cardIndices.PushBack(470); // GHOUL
			NMLRandomD.cardIndices.PushBack(470); // GHOUL
			NMLRandomD.cardIndices.PushBack(470); // GHOUL
			
			NMLRandomD.specialCard = -1;
			NMLRandomD.leaderIndex = 4004; // UNSEEN ELDER
			enemyDecks.PushBack(NMLRandomD);
			
			
			NMLRandomE.cardIndices.PushBack(0); // DECOY
			NMLRandomE.cardIndices.PushBack(0); // DECOY
			NMLRandomE.cardIndices.PushBack(5); // RAIN
			
			NMLRandomE.cardIndices.PushBack(16);  // AVALLAC'H
			NMLRandomE.cardIndices.PushBack(18);  // OPERATOR
			NMLRandomE.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLRandomE.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLRandomE.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLRandomE.cardIndices.PushBack(20);  // COW
			NMLRandomE.cardIndices.PushBack(335); // SIREN (1)
			NMLRandomE.cardIndices.PushBack(336); // SIREN (2)
			NMLRandomE.cardIndices.PushBack(337); // SIREN (3)
			NMLRandomE.cardIndices.PushBack(400); // DRAUG
			NMLRandomE.cardIndices.PushBack(413); // ANABELLE
			NMLRandomE.cardIndices.PushBack(415); // HUBERT REJK
			NMLRandomE.cardIndices.PushBack(445); // FOGLING
			NMLRandomE.cardIndices.PushBack(445); // FOGLING
			NMLRandomE.cardIndices.PushBack(455); // NEKKER (1)
			NMLRandomE.cardIndices.PushBack(456); // NEKKER (2)
			NMLRandomE.cardIndices.PushBack(457); // NEKKER (3)
			NMLRandomE.cardIndices.PushBack(464); // GAEL
			NMLRandomE.cardIndices.PushBack(465); // VAMPIRE: ALP
			NMLRandomE.cardIndices.PushBack(478); // TOAD PRINCE
			NMLRandomE.cardIndices.PushBack(480); // AZAR JAVED
			NMLRandomE.cardIndices.PushBack(481); // PROFESSOR
			
			NMLRandomE.specialCard = -1;
			NMLRandomE.leaderIndex = 4005; // GE'ELS
			enemyDecks.PushBack(NMLRandomE);
	}
	
	private function SetupAIDeckDefinitionsSkel()
	{
		var SkelRandomA		:SDeckDefinition;
		var SkelRandomB		:SDeckDefinition;
		var SkelRandomC		:SDeckDefinition;
		var SkelRandomD		:SDeckDefinition;
		var SkelRandomE		:SDeckDefinition;
			
			
			SkelRandomA.cardIndices.PushBack(3);   // FROST
			SkelRandomA.cardIndices.PushBack(4);   // FOG
			SkelRandomA.cardIndices.PushBack(6);   // CLEAR SKY
			
			SkelRandomA.cardIndices.PushBack(501); // HJALMAR
			SkelRandomA.cardIndices.PushBack(504); // DRAIG
			SkelRandomA.cardIndices.PushBack(505); // BLACKHAND
			SkelRandomA.cardIndices.PushBack(506); // MADMAN
			SkelRandomA.cardIndices.PushBack(507); // DONAR
			SkelRandomA.cardIndices.PushBack(510); // BLUEBOY
			SkelRandomA.cardIndices.PushBack(519); // HEYMAEY SKALD
			SkelRandomA.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomA.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomA.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomA.cardIndices.PushBack(524); // DIMUN CORSAIR
			SkelRandomA.cardIndices.PushBack(533); // DJENGE FRETT
			SkelRandomA.cardIndices.PushBack(535); // BOATBUILDERS
			SkelRandomA.cardIndices.PushBack(536); // SUKRUS
			SkelRandomA.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomA.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomA.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomA.cardIndices.PushBack(540); // DIMUN CAPTAIN
			SkelRandomA.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelRandomA.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelRandomA.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelRandomA.cardIndices.PushBack(565); // KNUT
			
			SkelRandomA.specialCard = -1;
			SkelRandomA.leaderIndex = 5001; // BRAN
			enemyDecks.PushBack(SkelRandomA);
			
			
			SkelRandomB.cardIndices.PushBack(0);   // DECOY
			SkelRandomB.cardIndices.PushBack(3);   // FROST
			SkelRandomB.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			SkelRandomB.cardIndices.PushBack(501); // HJALMAR
			SkelRandomB.cardIndices.PushBack(504); // DRAIG
			SkelRandomB.cardIndices.PushBack(505); // BLACKHAND
			SkelRandomB.cardIndices.PushBack(507); // DONAR
			SkelRandomB.cardIndices.PushBack(519); // HEYMAEY SKALD
			SkelRandomB.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomB.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomB.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomB.cardIndices.PushBack(521); // WAR LONGSHIP
			SkelRandomB.cardIndices.PushBack(521); // WAR LONGSHIP
			SkelRandomB.cardIndices.PushBack(521); // WAR LONGSHIP
			SkelRandomB.cardIndices.PushBack(524); // DIMUN CORSAIR
			SkelRandomB.cardIndices.PushBack(531); // CORAL
			SkelRandomB.cardIndices.PushBack(533); // DJENGE FRETT
			SkelRandomB.cardIndices.PushBack(534); // AN CRAITE WHALER
			SkelRandomB.cardIndices.PushBack(534); // AN CRAITE WHALER
			SkelRandomB.cardIndices.PushBack(535); // BOATBUILDERS
			SkelRandomB.cardIndices.PushBack(536); // SUKRUS
			SkelRandomB.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomB.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomB.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelRandomB.cardIndices.PushBack(540); // DIMUN CAPTAIN
			
			SkelRandomB.specialCard = -1;
			SkelRandomB.leaderIndex = 5002; // CRACH
			enemyDecks.PushBack(SkelRandomB);
			
			
			SkelRandomC.cardIndices.PushBack(0);   // DECOY
			SkelRandomC.cardIndices.PushBack(23);  // SKELLIGE STORM
			SkelRandomC.cardIndices.PushBack(27);  // RAGH NAR ROOG
			
			SkelRandomC.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomC.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomC.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomC.cardIndices.PushBack(417); // MORKVARG
			SkelRandomC.cardIndices.PushBack(501); // HJALMAR
			SkelRandomC.cardIndices.PushBack(503); // ERMION
			SkelRandomC.cardIndices.PushBack(506); // MADMAN
			SkelRandomC.cardIndices.PushBack(508); // UDALRYK
			SkelRandomC.cardIndices.PushBack(509); // BIRNA
			SkelRandomC.cardIndices.PushBack(510); // BLUEBOY
			SkelRandomC.cardIndices.PushBack(511); // SVANRIGE
			SkelRandomC.cardIndices.PushBack(512); // OLAF
			SkelRandomC.cardIndices.PushBack(513); // VILDKAARL BUTCHER
			SkelRandomC.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			SkelRandomC.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			SkelRandomC.cardIndices.PushBack(515); // VILDKAARL RAVAGER
			SkelRandomC.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			SkelRandomC.cardIndices.PushBack(561); // TYR
			SkelRandomC.cardIndices.PushBack(562); // ARTIS
			SkelRandomC.cardIndices.PushBack(563); // VABJORN
			SkelRandomC.cardIndices.PushBack(564); // SVALBLOD
			SkelRandomC.cardIndices.PushBack(565); // KNUT
			
			SkelRandomC.specialCard = -1;
			SkelRandomC.leaderIndex = 5003; // HARALD
			enemyDecks.PushBack(SkelRandomC);
			
			
			SkelRandomD.cardIndices.PushBack(23);  // SKELLIGE STORM
			SkelRandomD.cardIndices.PushBack(27);  // RAGH NAR ROOG
			SkelRandomD.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			SkelRandomD.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomD.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomD.cardIndices.PushBack(22);  // HEYMAEY FLAMINICA
			SkelRandomD.cardIndices.PushBack(417); // MORKVARG
			SkelRandomD.cardIndices.PushBack(503); // ERMION
			SkelRandomD.cardIndices.PushBack(506); // MADMAN
			SkelRandomD.cardIndices.PushBack(508); // UDALRYK
			SkelRandomD.cardIndices.PushBack(510); // BLUEBOY
			SkelRandomD.cardIndices.PushBack(512); // OLAF
			SkelRandomD.cardIndices.PushBack(523); // DRUMMOND MAIDEN (1)
			SkelRandomD.cardIndices.PushBack(525); // KAMBI
			SkelRandomD.cardIndices.PushBack(526); // DRUMMOND MAIDEN (2)
			SkelRandomD.cardIndices.PushBack(527); // DRUMMOND MAIDEN (3)
			SkelRandomD.cardIndices.PushBack(528); // JUTTA
			SkelRandomD.cardIndices.PushBack(529); // SKJALL
			SkelRandomD.cardIndices.PushBack(531); // CORAL
			SkelRandomD.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			SkelRandomD.cardIndices.PushBack(560); // PRIESTESS OF FREYA
			SkelRandomD.cardIndices.PushBack(561); // TYR
			SkelRandomD.cardIndices.PushBack(562); // ARTIS
			SkelRandomD.cardIndices.PushBack(564); // SVALBLOD
			SkelRandomD.cardIndices.PushBack(565); // KNUT
			
			SkelRandomD.specialCard = -1;
			SkelRandomD.leaderIndex = 5004; // EIST
			enemyDecks.PushBack(SkelRandomD);
			
			
			SkelRandomE.cardIndices.PushBack(5);   // RAIN
			SkelRandomE.cardIndices.PushBack(23);  // SKELLIGE STORM
			SkelRandomE.cardIndices.PushBack(31);  // CAVE OF DREAMS
			
			SkelRandomE.cardIndices.PushBack(501); // HJALMAR
			SkelRandomE.cardIndices.PushBack(506); // MADMAN
			SkelRandomE.cardIndices.PushBack(509); // BIRNA
			SkelRandomE.cardIndices.PushBack(510); // BLUEBOY
			SkelRandomE.cardIndices.PushBack(511); // SVANRIGE
			SkelRandomE.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			SkelRandomE.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			SkelRandomE.cardIndices.PushBack(517); // AN CRAITE WARRIOR
			SkelRandomE.cardIndices.PushBack(519); // HEYMAEY SKALD
			SkelRandomE.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomE.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomE.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelRandomE.cardIndices.PushBack(522); // BROKVAR ARCHER
			SkelRandomE.cardIndices.PushBack(522); // BROKVAR ARCHER
			SkelRandomE.cardIndices.PushBack(522); // BROKVAR ARCHER
			SkelRandomE.cardIndices.PushBack(523); // DRUMMOND MAIDEN (1)
			SkelRandomE.cardIndices.PushBack(524); // DIMUN CORSAIR
			SkelRandomE.cardIndices.PushBack(526); // DRUMMOND MAIDEN (2)
			SkelRandomE.cardIndices.PushBack(527); // DRUMMOND MAIDEN (3)
			SkelRandomE.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			SkelRandomE.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			SkelRandomE.cardIndices.PushBack(538); // TUIRSEACH SKIRMISHER
			
			SkelRandomE.specialCard = -1;
			SkelRandomE.leaderIndex = 5005; // CERYS
			enemyDecks.PushBack(SkelRandomE);
	}
	
	private function SetupAIDeckDefinitionsPrologue()
	{
		var NilfPrologue		:SDeckDefinition;
			
			// ALDER - PROLOGUE DECK
			
			NilfPrologue.cardIndices.PushBack(5); // RAIN
			NilfPrologue.cardIndices.PushBack(5); // RAIN
			NilfPrologue.cardIndices.PushBack(6); // CLEAR SKY
			
			NilfPrologue.cardIndices.PushBack(203); // TIBOR
			NilfPrologue.cardIndices.PushBack(205); // ALBRICH
			NilfPrologue.cardIndices.PushBack(207); // CYNTHIA
			NilfPrologue.cardIndices.PushBack(209); // PETER SAAR
			NilfPrologue.cardIndices.PushBack(210); // RAINFARN
			NilfPrologue.cardIndices.PushBack(211); // CANTARELLA
			NilfPrologue.cardIndices.PushBack(212); // ROTTEN MANGONEL
			NilfPrologue.cardIndices.PushBack(212); // ROTTEN MANGONEL
			NilfPrologue.cardIndices.PushBack(215); // SWEERS
			NilfPrologue.cardIndices.PushBack(216); // JOACHIM
			NilfPrologue.cardIndices.PushBack(217); // VANHEMAR
			NilfPrologue.cardIndices.PushBack(221); // PUTTKAMMER
			NilfPrologue.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfPrologue.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfPrologue.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfPrologue.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfPrologue.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfPrologue.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfPrologue.cardIndices.PushBack(251); // DUCAL GUARD
			NilfPrologue.cardIndices.PushBack(251); // DUCAL GUARD
			NilfPrologue.cardIndices.PushBack(251); // DUCAL GUARD
			
			NilfPrologue.specialCard = 219;  // VREEMDE
			NilfPrologue.leaderIndex = 2001; // MORVRAN
			enemyDecks.PushBack(NilfPrologue);
	}
	
	private function SetupAIDeckDefinitionsTournament1()
	{
		var NKTournament		:SDeckDefinition;
		var NilfTournament		:SDeckDefinition;
		var ScoiaTournament		:SDeckDefinition;
		var NMLTournament		:SDeckDefinition;
			
			
			// BERNARD - THE FELLOWSHIP OF THE WITCHER DECK
			
			NKTournament.cardIndices.PushBack(5);   // RAIN
			NKTournament.cardIndices.PushBack(6);   // CLEAR SKY
			NKTournament.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKTournament.cardIndices.PushBack(7);   // GERALT
			NKTournament.cardIndices.PushBack(8);   // VESEMIR
			NKTournament.cardIndices.PushBack(9);   // YENNEFER
			NKTournament.cardIndices.PushBack(10);  // CIRI
			NKTournament.cardIndices.PushBack(11);  // TRISS
			NKTournament.cardIndices.PushBack(12);  // DANDELION
			NKTournament.cardIndices.PushBack(13);  // ZOLTAN
			NKTournament.cardIndices.PushBack(100); // VERNON
			NKTournament.cardIndices.PushBack(101); // NATALIS
			NKTournament.cardIndices.PushBack(106); // VES
			NKTournament.cardIndices.PushBack(107); // SHANI
			NKTournament.cardIndices.PushBack(108); // YARPEN
			NKTournament.cardIndices.PushBack(109); // DIJKSTRA
			NKTournament.cardIndices.PushBack(111); // KEIRA
			NKTournament.cardIndices.PushBack(112); // SILE
			NKTournament.cardIndices.PushBack(114); // SHELDON
			NKTournament.cardIndices.PushBack(117); // VINCENT MEIS
			NKTournament.cardIndices.PushBack(135); // ESKEL
			NKTournament.cardIndices.PushBack(136); // LAMBERT
			NKTournament.cardIndices.PushBack(161); // BLUE STRIPES (1)
			NKTournament.cardIndices.PushBack(162); // BLUE STRIPES (2)
			NKTournament.cardIndices.PushBack(163); // BLUE STRIPES (3)
			
			NKTournament.specialCard = 8;    // VESEMIR
			NKTournament.leaderIndex = 1002; // FOLTEST
			enemyDecks.PushBack(NKTournament);
			
			
			// SASHA - ASSASSINS' CREED DECK
			
			NilfTournament.cardIndices.PushBack(0);   // DECOY
			NilfTournament.cardIndices.PushBack(5);   // RAIN
			NilfTournament.cardIndices.PushBack(26);  // CATRIONA PLAGUE
			
			NilfTournament.cardIndices.PushBack(200); // LETHO
			NilfTournament.cardIndices.PushBack(206); // ASSIRE
			NilfTournament.cardIndices.PushBack(207); // CYNTHIA
			NilfTournament.cardIndices.PushBack(208); // FRINGILLA
			NilfTournament.cardIndices.PushBack(214); // STEFAN
			NilfTournament.cardIndices.PushBack(217); // VANHEMAR
			NilfTournament.cardIndices.PushBack(218); // VATTIER
			NilfTournament.cardIndices.PushBack(220); // CAHIR
			NilfTournament.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfTournament.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfTournament.cardIndices.PushBack(230); // ETOLIAN AUXILIARY
			NilfTournament.cardIndices.PushBack(231); // RIENCE
			NilfTournament.cardIndices.PushBack(235); // BLACK ARCHER
			NilfTournament.cardIndices.PushBack(235); // BLACK ARCHER
			NilfTournament.cardIndices.PushBack(235); // BLACK ARCHER
			NilfTournament.cardIndices.PushBack(236); // VILGEFORTZ
			NilfTournament.cardIndices.PushBack(246); // SERRIT
			NilfTournament.cardIndices.PushBack(247); // AUCKES
			NilfTournament.cardIndices.PushBack(248); // LEO BONHART
			NilfTournament.cardIndices.PushBack(249); // VICOVARO MEDIC
			NilfTournament.cardIndices.PushBack(480); // AZAR JAVED
			
			NilfTournament.specialCard = 213;  // SHILARD
			NilfTournament.leaderIndex = 2004; // CALVEIT
			enemyDecks.PushBack(NilfTournament);
			
			
			// FINNEAS - REBEL ALLIANCE DECK
			
			ScoiaTournament.cardIndices.PushBack(0);   // DECOY
			ScoiaTournament.cardIndices.PushBack(1);   // MARDROEME
			ScoiaTournament.cardIndices.PushBack(2);   // FOREST OF DEATH
			
			ScoiaTournament.cardIndices.PushBack(301); // SASKIA
			ScoiaTournament.cardIndices.PushBack(302); // ISENGRIM
			ScoiaTournament.cardIndices.PushBack(303); // IORVETH
			ScoiaTournament.cardIndices.PushBack(306); // MILVA
			ScoiaTournament.cardIndices.PushBack(308); // FILAVANDREL
			ScoiaTournament.cardIndices.PushBack(309); // YAEVINN
			ScoiaTournament.cardIndices.PushBack(310); // TORUVIEL
			ScoiaTournament.cardIndices.PushBack(311); // RIORDAIN
			ScoiaTournament.cardIndices.PushBack(312); // CIARAN
			ScoiaTournament.cardIndices.PushBack(322); // MALENA
			ScoiaTournament.cardIndices.PushBack(325); // VRIHEDD VETERAN
			ScoiaTournament.cardIndices.PushBack(325); // VRIHEDD VETERAN
			ScoiaTournament.cardIndices.PushBack(326); // LADY OF THE LAKE
			ScoiaTournament.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaTournament.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaTournament.cardIndices.PushBack(350); // ELF SKIRMISHER
			ScoiaTournament.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaTournament.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaTournament.cardIndices.PushBack(355); // VRIHEDD RECRUIT
			ScoiaTournament.cardIndices.PushBack(365); // HAVEKAR HEALER
			ScoiaTournament.cardIndices.PushBack(367); // AELIRENN
			
			ScoiaTournament.specialCard = 321;  // VERNOSSIEL
			ScoiaTournament.leaderIndex = 3005; // DANA
			enemyDecks.PushBack(ScoiaTournament);
			
			
			// TYBALT - HIDDEN INTENTIONS DECK
			
			NMLTournament.cardIndices.PushBack(0); // DECOY
			NMLTournament.cardIndices.PushBack(0); // DECOY
			NMLTournament.cardIndices.PushBack(5); // RAIN
			
			NMLTournament.cardIndices.PushBack(18);  // OPERATOR
			NMLTournament.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLTournament.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLTournament.cardIndices.PushBack(19);  // VRAN WARRIOR
			NMLTournament.cardIndices.PushBack(20);  // COW
			NMLTournament.cardIndices.PushBack(335); // SIREN (1)
			NMLTournament.cardIndices.PushBack(336); // SIREN (2)
			NMLTournament.cardIndices.PushBack(337); // SIREN (3)
			NMLTournament.cardIndices.PushBack(400); // DRAUG
			NMLTournament.cardIndices.PushBack(413); // ANABELLE
			NMLTournament.cardIndices.PushBack(415); // HUBERT REJK
			NMLTournament.cardIndices.PushBack(445); // FOGLING
			NMLTournament.cardIndices.PushBack(445); // FOGLING
			NMLTournament.cardIndices.PushBack(455); // NEKKER (1)
			NMLTournament.cardIndices.PushBack(456); // NEKKER (2)
			NMLTournament.cardIndices.PushBack(457); // NEKKER (3)
			NMLTournament.cardIndices.PushBack(464); // GAEL
			NMLTournament.cardIndices.PushBack(465); // VAMPIRE: ALP
			NMLTournament.cardIndices.PushBack(478); // TOAD PRINCE
			NMLTournament.cardIndices.PushBack(480); // AZAR JAVED
			NMLTournament.cardIndices.PushBack(481); // PROFESSOR
			
			NMLTournament.specialCard = 16;   // AVALLAC'H
			NMLTournament.leaderIndex = 4005; // GE'ELS
			enemyDecks.PushBack(NMLTournament);
	}
	
	private function SetupAIDeckDefinitionsTournament2()
	{
		var NKTournament2		:SDeckDefinition;
		var NilfTournament2		:SDeckDefinition;
		var ScoiaTournament2	:SDeckDefinition;
		var NMLTournament2		:SDeckDefinition;
		var SkelTournament2		:SDeckDefinition;
			
			
			// ??? - RESISTANCE DECK
			
			NKTournament2.cardIndices.PushBack(0);   // DECOY
			NKTournament2.cardIndices.PushBack(1);   // MARDROEME
			NKTournament2.cardIndices.PushBack(25);  // MERIGOLD'S HAILSTORM
			
			NKTournament2.cardIndices.PushBack(100); // VERNON
			NKTournament2.cardIndices.PushBack(101); // NATALIS
			NKTournament2.cardIndices.PushBack(102); // VISSEGERD
			NKTournament2.cardIndices.PushBack(106); // VES
			NKTournament2.cardIndices.PushBack(120); // TREBUCHET
			NKTournament2.cardIndices.PushBack(120); // TREBUCHET
			NKTournament2.cardIndices.PushBack(121); // POOR INFANTRY (1)
			NKTournament2.cardIndices.PushBack(125); // BALLISTA
			NKTournament2.cardIndices.PushBack(125); // BALLISTA
			NKTournament2.cardIndices.PushBack(126); // POOR INFANTRY (1)
			NKTournament2.cardIndices.PushBack(127); // POOR INFANTRY (1)
			NKTournament2.cardIndices.PushBack(140); // CATAPULT
			NKTournament2.cardIndices.PushBack(140); // CATAPULT
			NKTournament2.cardIndices.PushBack(145); // KAEDWENI EXPERT
			NKTournament2.cardIndices.PushBack(161); // BLUE STRIPES (1)
			NKTournament2.cardIndices.PushBack(162); // BLUE STRIPES (2)
			NKTournament2.cardIndices.PushBack(163); // BLUE STRIPES (3)
			NKTournament2.cardIndices.PushBack(170); // SIEGE TOWER
			NKTournament2.cardIndices.PushBack(175); // DUN BANNER MEDIC
			NKTournament2.cardIndices.PushBack(420); // BOTCHLING
			NKTournament2.cardIndices.PushBack(422); // BLOODY BARON
			
			NKTournament2.specialCard = 146;  // KAEDWENI SUPPORT
			NKTournament2.leaderIndex = 1003; // CALANTHE
			enemyDecks.PushBack(NKTournament2);
			
			
			// AMBASSADOR - EMPIRE DECK
			
			NilfTournament2.cardIndices.PushBack(5);   // RAIN
			NilfTournament2.cardIndices.PushBack(5);   // RAIN
			NilfTournament2.cardIndices.PushBack(6);   // CLEAR SKY
			
			NilfTournament2.cardIndices.PushBack(201); // MENNO
			NilfTournament2.cardIndices.PushBack(203); // TIBOR
			NilfTournament2.cardIndices.PushBack(209); // PETER SAAR
			NilfTournament2.cardIndices.PushBack(210); // RAINFARN
			NilfTournament2.cardIndices.PushBack(215); // SWEERS
			NilfTournament2.cardIndices.PushBack(216); // JOACHIM
			NilfTournament2.cardIndices.PushBack(219); // VREEMDE
			NilfTournament2.cardIndices.PushBack(220); // CAHIR
			NilfTournament2.cardIndices.PushBack(221); // PUTTKAMMER
			NilfTournament2.cardIndices.PushBack(245); // ALBA DIVISION
			NilfTournament2.cardIndices.PushBack(245); // ALBA DIVISION
			NilfTournament2.cardIndices.PushBack(245); // ALBA DIVISION
			NilfTournament2.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfTournament2.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfTournament2.cardIndices.PushBack(250); // NAUSICAA CAVALRY
			NilfTournament2.cardIndices.PushBack(251); // DUCAL GUARD
			NilfTournament2.cardIndices.PushBack(251); // DUCAL GUARD
			NilfTournament2.cardIndices.PushBack(251); // DUCAL GUARD
			NilfTournament2.cardIndices.PushBack(252); // DAMIEN
			NilfTournament2.cardIndices.PushBack(253); // MILTON
			NilfTournament2.cardIndices.PushBack(254); // PALMERIN
			
			NilfTournament2.specialCard = 261;  // GREGOIRE
			NilfTournament2.leaderIndex = 2001; // MORVRAN
			enemyDecks.PushBack(NilfTournament2);
			
			
			// YAKI - DWARVEN PRIDE DECK
			
			ScoiaTournament2.cardIndices.PushBack(3);   // FROST
			ScoiaTournament2.cardIndices.PushBack(3);   // FROST
			ScoiaTournament2.cardIndices.PushBack(6);   // CLEAR SKY
			
			ScoiaTournament2.cardIndices.PushBack(7);   // GERALT
			ScoiaTournament2.cardIndices.PushBack(15);  // VILLEN
			ScoiaTournament2.cardIndices.PushBack(301); // SASKIA
			ScoiaTournament2.cardIndices.PushBack(305); // DENNIS
			ScoiaTournament2.cardIndices.PushBack(313); // BARCLAY
			ScoiaTournament2.cardIndices.PushBack(326); // LADY OF THE LAKE
			ScoiaTournament2.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaTournament2.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaTournament2.cardIndices.PushBack(332); // HALF-ELF HUNTER
			ScoiaTournament2.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaTournament2.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaTournament2.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaTournament2.cardIndices.PushBack(340); // MAHAKAM DEFENDER
			ScoiaTournament2.cardIndices.PushBack(341); // PERCIVAL
			ScoiaTournament2.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaTournament2.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaTournament2.cardIndices.PushBack(343); // DWARF MERCENARY
			ScoiaTournament2.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaTournament2.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaTournament2.cardIndices.PushBack(351); // DWARF SKIRMISHER
			ScoiaTournament2.cardIndices.PushBack(366); // HATTORI

			ScoiaTournament2.specialCard = 342;  // DWARF CHARIOT
			ScoiaTournament2.leaderIndex = 3001; // BROUVER
			enemyDecks.PushBack(ScoiaTournament2);
			
			
			// HAMAL - MOST WANTED DECK
			
			NMLTournament2.cardIndices.PushBack(3);   // FROST
			NMLTournament2.cardIndices.PushBack(4);   // FOG
			NMLTournament2.cardIndices.PushBack(5);   // RAIN
			
			NMLTournament2.cardIndices.PushBack(400); // DRAUG
			NMLTournament2.cardIndices.PushBack(401); // KAYRAN
			NMLTournament2.cardIndices.PushBack(403); // WOODLAND SPIRIT
			NMLTournament2.cardIndices.PushBack(404); // DAGON
			NMLTournament2.cardIndices.PushBack(410); // MORVUDD
			NMLTournament2.cardIndices.PushBack(413); // ANABELLE
			NMLTournament2.cardIndices.PushBack(425); // MYRHYFF
			NMLTournament2.cardIndices.PushBack(427); // DROWNER
			NMLTournament2.cardIndices.PushBack(427); // DROWNER
			NMLTournament2.cardIndices.PushBack(427); // DROWNER
			NMLTournament2.cardIndices.PushBack(440); // ABAYA
			NMLTournament2.cardIndices.PushBack(451); // ARACHAS
			NMLTournament2.cardIndices.PushBack(451); // ARACHAS
			NMLTournament2.cardIndices.PushBack(451); // ARACHAS
			NMLTournament2.cardIndices.PushBack(453); // WOLF
			NMLTournament2.cardIndices.PushBack(453); // WOLF
			NMLTournament2.cardIndices.PushBack(453); // WOLF
			NMLTournament2.cardIndices.PushBack(464); // GAEL
			NMLTournament2.cardIndices.PushBack(466); // DETTLAFF
			NMLTournament2.cardIndices.PushBack(478); // TOAD PRINCE
			NMLTournament2.cardIndices.PushBack(496); // ADDA
			
			NMLTournament2.specialCard = 450;  // ARACHAS BEHEMOTH
			NMLTournament2.leaderIndex = 4002; // GHOST IN THE TREE
			enemyDecks.PushBack(NMLTournament2);
			
			
			// MARTIN - VIKINGS DECK
			
			SkelTournament2.cardIndices.PushBack(3);   // FROST
			SkelTournament2.cardIndices.PushBack(4);   // FOG
			SkelTournament2.cardIndices.PushBack(6);   // CLEAR SKY
			
			SkelTournament2.cardIndices.PushBack(501); // HJALMAR
			SkelTournament2.cardIndices.PushBack(504); // DRAIG
			SkelTournament2.cardIndices.PushBack(505); // BLACKHAND
			SkelTournament2.cardIndices.PushBack(506); // MADMAN
			SkelTournament2.cardIndices.PushBack(507); // DONAR
			SkelTournament2.cardIndices.PushBack(510); // BLUEBOY
			SkelTournament2.cardIndices.PushBack(519); // HEYMAEY SKALD
			SkelTournament2.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelTournament2.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelTournament2.cardIndices.PushBack(520); // LIGHT LONGSHIP
			SkelTournament2.cardIndices.PushBack(524); // DIMUN CORSAIR
			SkelTournament2.cardIndices.PushBack(533); // DJENGE FRETT
			SkelTournament2.cardIndices.PushBack(535); // BOATBUILDERS
			SkelTournament2.cardIndices.PushBack(536); // SUKRUS
			SkelTournament2.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelTournament2.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelTournament2.cardIndices.PushBack(539); // DIMUN SMUGGLER
			SkelTournament2.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelTournament2.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelTournament2.cardIndices.PushBack(541); // AN CRAITE MARAUDER
			SkelTournament2.cardIndices.PushBack(565); // KNUT
			
			SkelTournament2.specialCard = 540;  // DIMUN CAPTAIN
			SkelTournament2.leaderIndex = 5001; // BRAN
			enemyDecks.PushBack(SkelTournament2);
	}
	
	
	public function GwentLeadersNametoInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_foltest_copper':		return 1001; // DEMAVEND III
			case 'gwint_card_foltest_bronze':		return 1002; 
			case 'gwint_card_foltest_silver':		return 1003; // CALANTHE
			case 'gwint_card_foltest_gold':			return 1004; // HENSELT
			case 'gwint_card_foltest_platinium':	return 1005; // RADOVID V
			
			case 'gwint_card_emhyr_copper':			return 2001; // MORVRAN VOORHIS
			case 'gwint_card_emhyr_bronze':			return 2002; 
			case 'gwint_card_emhyr_silver':			return 2003; // USURPER
			case 'gwint_card_emhyr_gold':			return 2004; // JAN CALVEIT
			case 'gwint_card_emhyr_platinium':		return 2005; // FALSE CIRI
			
			case 'gwint_card_francesca_copper':		return 3001; // BROUVER HOOG
			case 'gwint_card_francesca_bronze':		return 3002; // EITHNE
			case 'gwint_card_francesca_silver':		return 3003; // ITHLINNE AEGLI AEP AEVENIEN
			case 'gwint_card_francesca_gold':		return 3004; 
			case 'gwint_card_francesca_platinium':	return 3005; // DANA MEADBH
			
			case 'gwint_card_eredin_copper':		return 4001; 
			case 'gwint_card_eredin_bronze':		return 4002; // GHOST IN THE TREE
			case 'gwint_card_eredin_silver':		return 4003; // GAUNTER O'DIMM
			case 'gwint_card_eredin_gold':			return 4004; // UNSEEN ELDER
			case 'gwint_card_eredin_platinium':		return 4005; // GE'ELS
			
			case 'gwint_card_king_bran_bronze':		return 5001; 
			case 'gwint_card_king_bran_copper':		return 5002; // CRACH AN CRAITE
			case 'gwint_card_king_bran_silver':		return 5003; // HARALD THE CRIPPLE
			case 'gwint_card_king_bran_gold':		return 5004; // EIST TUIRSEACH
			case 'gwint_card_king_bran_platinium':	return 5005; // CERYS AN CRAITE
			default: return	1;
		}
	}
	
	public function GwentNrkdNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_triss':				return 11 ; 
			case 'gwint_card_dandelion':			return 12 ; 
			case 'gwint_card_zoltan':				return 13 ; 
			case 'gwint_card_olgierd':				return 17 ; 
			case 'gwint_card_vernon':				return 100; 
			case 'gwint_card_natalis':				return 101; 
			case 'gwint_card_esterad':				return 102; // VISSEGERD
			case 'gwint_card_philippa':				return 103; 
			case 'gwint_card_jacques':				return 104; 
			case 'gwint_card_thaler':				return 105; 
			case 'gwint_card_ves':					return 106;	
			case 'gwint_card_siegfried':			return 107; // SHANI
			case 'gwint_card_yarpen':				return 108; 
			case 'gwint_card_dijkstra':				return 109; 
			case 'gwint_card_keira':				return 111; 
			case 'gwint_card_sile':					return 112; 
			case 'gwint_card_sabrina':				return 113; 
			case 'gwint_card_sheldon':				return 114; 
			case 'gwint_card_dethmold':				return 115; 
			case 'gwint_card_stennis':				return 116; 
			case 'gwint_card_vincent':				return 117; 
			case 'gwint_card_anseis':				return 118; 
			case 'gwint_card_trebuchet':			return 120; 
			case 'gwint_card_poor_infantry':		return 121; 
			case 'gwint_card_ballista':				return 125; 
			case 'gwint_card_poor_infantry2':		return 126; 
			case 'gwint_card_poor_infantry3':		return 127; 
			case 'gwint_card_crinfrid':				return 130; 
			case 'gwint_card_crinfrid2':			return 131; 
			case 'gwint_card_crinfrid3':			return 132; 
			case 'gwint_card_catapult':				return 140; 
			case 'gwint_card_catapult2':			return 141; // CALEB MENGE
			case 'gwint_card_nathaniel':			return 142; 
			case 'gwint_card_lebioda':				return 143; 
			case 'gwint_card_kaedwen_siege':		return 145; 
			case 'gwint_card_kaedwen_support':		return 146; 
			case 'gwint_card_cutup':				return 147; 
			case 'gwint_card_witch_hunter':			return 150; 
			case 'gwint_card_beggar':				return 151; 
			case 'gwint_card_peach':				return 152; 
			case 'gwint_card_cleric_rose':			return 155; 
			case 'gwint_card_knight_rose':			return 156; 
			case 'gwint_card_redanian':				return 160; 
			case 'gwint_card_blue_stripes2':		return 161; 
			case 'gwint_card_blue_stripes3':		return 162; 
			case 'gwint_card_blue_stripes1':		return 163; 
			case 'gwint_card_francis':				return 165; 
			case 'gwint_card_whoreson':				return 166; 
			case 'gwint_card_carlo':				return 167; 
			case 'gwint_card_siege_tower':			return 170; 
			case 'gwint_card_crownsplitter':		return 171; 
			case 'gwint_card_dun_banner_medic':		return 175; 
			case 'gwint_card_igor':					return 176; 
			case 'gwint_card_botchling':			return 420; 
			case 'gwint_card_bloody_baron':			return 422; 
			case 'gwint_card_wyvern':				return 447; // TATTERWING
			case 'gwint_card_boris':				return 448; 
			default: return 1;
		}
	}
	
	public function GwentNlfgNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_letho':				return 200; 
			case 'gwint_card_menno':				return 201; 
			case 'gwint_card_moorvran':				return 202; // ARDAL AEP DAHY
			case 'gwint_card_tibor':				return 203; 
			case 'gwint_card_albrich':				return 205; 
			case 'gwint_card_assire':				return 206; 
			case 'gwint_card_cynthia':				return 207; 
			case 'gwint_card_fringilla':			return 208;	
			case 'gwint_card_morteisen':			return 209; // PETER SAAR
			case 'gwint_card_rainfarn':				return 210; 
			case 'gwint_card_renuald':				return 211; // CANTARELLA
			case 'gwint_card_rotten':				return 212; 
			case 'gwint_card_shilard':				return 213; 
			case 'gwint_card_stefan':				return 214; 
			case 'gwint_card_sweers':				return 215; 
			case 'gwint_card_joachim':				return 216; 
			case 'gwint_card_vanhemar':				return 217; 
			case 'gwint_card_vattier':				return 218; 
			case 'gwint_card_vreemde':				return 219; 
			case 'gwint_card_cahir':				return 220; 
			case 'gwint_card_puttkammer':			return 221; 
			case 'gwint_card_henrietta':			return 225; 
			case 'gwint_card_syanna':				return 226; 
			case 'gwint_card_artorius':				return 227; 
			case 'gwint_card_vivienne':				return 228; 
			case 'gwint_card_archer_support':		return 230;	
			case 'gwint_card_archer_support2':		return 231;	// RIENCE
			case 'gwint_card_black_archer':			return 235; 
			case 'gwint_card_black_archer2':		return 236; // VILGEFORTZ
			case 'gwint_card_heavy_zerri':			return 240; 
			case 'gwint_card_zerri':				return 241; 
			case 'gwint_card_impera_brigade1':		return 245;	
			case 'gwint_card_impera_brigade2':		return 246;	// SERRIT
			case 'gwint_card_impera_brigade3':		return 247;	// AUCKES
			case 'gwint_card_impera_brigade4':		return 248;	// LEO BONHART
			case 'gwint_card_vicovaro':				return 249; 
			case 'gwint_card_nausicaa':             return 250;	
			case 'gwint_card_nausicaa2':            return 251;	// DUCAL GUARD
			case 'gwint_card_nausicaa3':            return 252;	// DAMIEN DE LA TOUR
			case 'gwint_card_milton':				return 253; 
			case 'gwint_card_palmerin':				return 254; 
			case 'gwint_card_combat_engineer':		return 255;	
			case 'gwint_card_young_emissary':		return 260; 
			case 'gwint_card_young_emissary2':		return 261; // GREGOIRE DE GORGON
			case 'gwint_card_siege_support':		return 265;	// ALCHEMIST
			default: return 1;
		}
	}
	
	public function GwentSctlNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_villen':				return 15 ; 
			case 'gwint_card_eithne':				return 300;	// SIRSSA
			case 'gwint_card_saskia':				return 301;	
			case 'gwint_card_isengrim':				return 302; 
			case 'gwint_card_iorveth':				return 303;	
			case 'gwint_card_dennis':				return 305;	
			case 'gwint_card_milva':				return 306;	
			case 'gwint_card_ida':					return 307;	
			case 'gwint_card_filavandrel':			return 308;	
			case 'gwint_card_yaevinn':				return 309;	
			case 'gwint_card_toruviel':				return 310;	
			case 'gwint_card_riordain':				return 311;	
			case 'gwint_card_ciaran':				return 312;	
			case 'gwint_card_barclay':				return 313;	
			case 'gwint_card_aglais':				return 315;	
			case 'gwint_card_braenn':				return 316;	
			case 'gwint_card_fauve':				return 317;	
			case 'gwint_card_morenn':				return 318;	
			case 'gwint_card_havekar_support':		return 320;	
			case 'gwint_card_havekar_support2':		return 321;	// VERNOSSIEL
			case 'gwint_card_havekar_support3':		return 322;	// MALENA
			case 'gwint_card_vrihedd_brigade':		return 325;	
			case 'gwint_card_vrihedd_brigade2':		return 326; // LADY OF THE LAKE
			case 'gwint_card_dol_infantry':			return 330;	
			case 'gwint_card_dol_infantry2':		return 331;	// DOL BLATHANNA BOMBER
			case 'gwint_card_dol_infantry3':		return 332;	// HALF-ELF HUNTER
			case 'gwint_card_mahakam':				return 340;	
			case 'gwint_card_mahakam2':				return 341;	// PERCIVAL SCHUTTENBACH
			case 'gwint_card_mahakam3':				return 342;	// DWARVEN CHARIOT
			case 'gwint_card_mahakam4':				return 343;	// DWARVEN MERCENARY
			case 'gwint_card_mahakam5':				return 344;	// BROKILON SENTINEL
			case 'gwint_card_grovekeeper':			return 345;	
			case 'gwint_card_treant_boar':			return 346;	
			case 'gwint_card_treant_mantis':		return 347;	
			case 'gwint_card_elf_skirmisher':		return 350;	
			case 'gwint_card_elf_skirmisher2':		return 351;	// DWARVEN SKIRMISHER
			case 'gwint_card_elf_skirmisher3':		return 352;	// ELE'YAS
			case 'gwint_card_vrihedd_cadet':		return 355;	
			case 'gwint_card_dol_archer':			return 360;	
			case 'gwint_card_havekar_nurse':		return 365;	
			case 'gwint_card_havekar_nurse2':		return 366;	// EIBHEAR HATTORI
			case 'gwint_card_havekar_nurse3':		return 367; // AELIRENN
			case 'gwint_card_schirru':				return 368;	
			default: return 1;
		}
	}
	
	public function GwentMstrNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_emiel':				return 14 ; 
			case 'gwint_card_avallach':				return 16 ; 
			case 'gwint_card_mrmirror':				return 18 ; // OPERATOR
			case 'gwint_card_mrmirror_foglet':		return 19 ; // VRAN WARRIOR
			case 'gwint_card_cow':					return 20 ; 
			case 'gwint_card_dol_dwarf':			return 335;	// SIREN (1)
			case 'gwint_card_dol_dwarf2':			return 336;	// SIREN (2)
			case 'gwint_card_dol_dwarf3':			return 337;	// SIREN (3)
			case 'gwint_card_draug':				return 400; 
			case 'gwint_card_kayran':				return 401; 
			case 'gwint_card_imlerith':				return 402; 
			case 'gwint_card_leshen':				return 403; // WOODLAND SPIRIT
			case 'gwint_card_dagon':				return 404; 
			case 'gwint_card_forktail':				return 405; // GOLYAT
			case 'gwint_card_earth_elemental':		return 407; 
			case 'gwint_card_caranthir':			return 408; 
			case 'gwint_card_nithral':				return 409; 
			case 'gwint_card_fiend':				return 410; // MORVUDD
			case 'gwint_card_plague_maiden':		return 413; // ANABELLE
			case 'gwint_card_griffin':				return 415; // HUBERT REJK
			case 'gwint_card_frightener':			return 423; 
			case 'gwint_card_ice_giant':			return 425; // MYRHYFF
			case 'gwint_card_endrega':				return 427; // DROWNER
			case 'gwint_card_harpy':				return 430; 
			case 'gwint_card_cockatrice':			return 433; // SLEEPING GIANT
			case 'gwint_card_gargoyle':				return 435; // QUEEN OF THE NIGHT
			case 'gwint_card_iris':					return 436;	
			case 'gwint_card_celaeno_harpy':		return 437; // IRIS' COMPANIONS
			case 'gwint_card_grave_hag':			return 440;	// ABAYA
			case 'gwint_card_fire_elemental':		return 443;	
			case 'gwint_card_fogling':				return 445; 
			case 'gwint_card_arachas_behemoth':		return 450; 
			case 'gwint_card_arachas':				return 451; 
			case 'gwint_card_arachas2':				return 452; // VAMPIRE: PLUMARD
			case 'gwint_card_arachas3':				return 453; // WOLF
			case 'gwint_card_nekker':				return 455; 
			case 'gwint_card_nekker2':				return 456; 
			case 'gwint_card_nekker3':				return 457; 
			case 'gwint_card_ekkima':				return 460; 
			case 'gwint_card_fleder':				return 461; 
			case 'gwint_card_garkain':				return 462; 
			case 'gwint_card_bruxa':				return 463; // ORIANNA
			case 'gwint_card_katakan':				return 464; // GAEL
			case 'gwint_card_alp':					return 465; 
			case 'gwint_card_dettlaff':				return 466; 
			case 'gwint_card_ghoul':				return 470; 
			case 'gwint_card_ghoul2':				return 471; // KIYAN
			case 'gwint_card_ghoul3':				return 472; // CARETAKER
			case 'gwint_card_crone_brewess':		return 475;	
			case 'gwint_card_crone_weavess':		return 476;	
			case 'gwint_card_crone_whispess':		return 477;	
			case 'gwint_card_toad':					return 478;	// TOAD PRINCE
			case 'gwint_card_savolla':				return 482;	
			case 'gwint_card_centipede':			return 485;	
			case 'gwint_card_wildhunt_drakkar':		return 490; 
			case 'gwint_card_wildhunt_warrior':		return 491; 
			case 'gwint_card_wildhunt_rider':		return 492; 
			case 'gwint_card_wildhunt_rider2':		return 493; 
			case 'gwint_card_wildhunt_rider3':		return 494; 
			case 'gwint_card_wildhunt_hound':		return 495; 
			case 'gwint_card_striga':				return 496;	
			case 'gwint_card_wildhunt_navigator':	return 498; 
			default: return 1;
		}
	}

	public function GwentSkeNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_mushroom':						return 22 ; // CLAN HEYMAEY FLAMINICA
			case 'gwint_card_werewolf':						return 417; // MORKVARG
			case 'gwint_card_hjalmar':						return 501;
			case 'gwint_card_cerys':						return 502; // HARALD HOUNDSNOUT
			case 'gwint_card_ermion':						return 503;
			case 'gwint_card_draig':						return 504;
			case 'gwint_card_holger_blackhand':				return 505;
			case 'gwint_card_madman_lugos':					return 506;
			case 'gwint_card_donar_an_hindar':				return 507;
			case 'gwint_card_udalryk':						return 508;
			case 'gwint_card_birna_bran':					return 509;
			case 'gwint_card_blueboy_lugos':				return 510;
			case 'gwint_card_svanrige':						return 511;
			case 'gwint_card_olaf':							return 512;
			case 'gwint_card_berserker':					return 513;
			case 'gwint_card_young_berserker':				return 515;
			case 'gwint_card_clan_an_craite_warrior':		return 517;
			case 'gwint_card_clan_tordarroch_armorsmith':	return 518;
			case 'gwint_card_clan_heymaey_skald':			return 519;
			case 'gwint_card_light_drakkar':				return 520;
			case 'gwint_card_war_drakkar':					return 521;
			case 'gwint_card_clan_brokvar_archer':			return 522;
			case 'gwint_card_clan_drummond_shieldmaiden':	return 523;
			case 'gwint_card_clan_dimun_pirate':			return 524;
			case 'gwint_card_cock':							return 525;
			case 'gwint_card_clan_drummond_shieldmaiden2':	return 526;
			case 'gwint_card_clan_drummond_shieldmaiden3':	return 527;
			case 'gwint_card_jutta':						return 528;
			case 'gwint_card_skjall':						return 529;
			case 'gwint_card_coral':						return 531;
			case 'gwint_card_yoana':						return 532;
			case 'gwint_card_djenge_frett':					return 533;
			case 'gwint_card_clan_an_craite_whaler':		return 534;
			case 'gwint_card_boatbuilders':					return 535;
			case 'gwint_card_sukrus':						return 536;
			case 'gwint_card_athak':						return 537;
			case 'gwint_card_clan_tuirseach_skirmisher':	return 538;
			case 'gwint_card_clan_dimun_smuggler':			return 539;
			case 'gwint_card_clan_dimun_captain':			return 540;
			case 'gwint_card_clan_an_craite_marauder':		return 541;
			case 'gwint_card_freya':						return 560;
			case 'gwint_card_tyr':							return 561;
			case 'gwint_card_artis':						return 562;
			case 'gwint_card_vabjorn':						return 563;
			case 'gwint_card_svalblod':						return 564;
			case 'gwint_card_knut':							return 565;
			default: return 1;
		}
	}
	
	public function GwentNeutralNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_geralt':				return 7  ; 
			case 'gwint_card_vesemir':				return 8  ; 
			case 'gwint_card_yennefer':				return 9  ; 
			case 'gwint_card_ciri':					return 10 ; 
			case 'gwint_card_eskel':				return 135; 
			case 'gwint_card_lambert':				return 136; 
			case 'gwint_card_azar_javed':			return 480;	
			case 'gwint_card_professor':			return 481;	
			default: return 1;
		}
	}
	
	public function GwentSpecialNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_dummy':				return 0  ; 
			case 'gwint_card_horn':					return 1  ; // MARDROEME
			case 'gwint_card_scorch':				return 2  ; // FOREST OF DEATH
			case 'gwint_card_frost':				return 3  ; 
			case 'gwint_card_fog':					return 4  ; 
			case 'gwint_card_rain':					return 5  ; 
			case 'gwint_card_clear_sky':			return 6  ; 
			case 'gwint_card_skellige_storm':		return 23 ; 
			case 'gwint_card_white':				return 24 ; 
			case 'gwint_card_hailstorm':			return 25 ; 
			case 'gwint_card_catriona':				return 26 ; 
			case 'gwint_card_ragh_nar_roog':		return 27 ; 
			case 'gwint_card_nature':				return 28 ; 
			case 'gwint_card_water':				return 29 ; 
			case 'gwint_card_moon':					return 30 ; 
			case 'gwint_card_dreams':				return 31 ; 
			default: return 1;
		}
	}
}
