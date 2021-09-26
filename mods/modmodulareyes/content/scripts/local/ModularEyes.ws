class CModularEyes
{
	var loaded: bool;
	var HeadArray : array<name>;
	var AltHeadArray : array<name>;
	var BlackHeadArray : array<name>;
	
	var AltStatusArray : array<bool>;
	var BlackStatusArray : array<bool>;
	
	var igconfig : CInGameConfigWrapper;
	var ActivationID : int;
	var BlackTox : bool;
	var AltTox : bool;
	var BlackDark : bool;
	var AltDark : bool;
	var BlackToxAndDark : bool;
	var AltToxAndDark : bool;
	var BlackCat : bool;
	var AltCat : bool;
	var BlackCombatDay : bool;
	var AltCombatDay : bool;
	var BlackCombatDark : bool;
	var AltCombatDark : bool;
	var BlackWitcherSenses : bool;
	var AltWitcherSenses : bool;
	var BlackButtonToggle : bool;
	var AltButtonToggle : bool;
	var BlackStatic : bool;
	var AltStatic : bool;
	
	var AltToxOn : bool;
	var AltDarkOn : bool;
	var AltToxDarkOn : bool;
	var AltCatOn : bool;
	var AltComDayOn : bool;
	var AltComDarkOn : bool;
	var AltWitcherOn : bool;
	var AltToggOn : bool;
	var AltStatOn : bool;

	var BlackToxOn : bool;
	var BlackDarkOn : bool;
	var BlackToxDarkOn : bool;
	var BlackCatOn : bool;
	var BlackComDayOn : bool;
	var BlackComDarkOn : bool;
	var BlackWitcherOn : bool;
	var BlackToggOn : bool;
	var BlackStatOn : bool;
	
	public var altEyesActive : bool;
	public var blackEyesActive : bool;
	public var toxicpercent : float;
	
	public var priority : bool;
	public var storedHead : name;
	
	default altEyesActive = false;
	default blackEyesActive = false;
	default loaded = false;
	default priority = false;
	
	public function Load()
	{
		if(!loaded)
		{
			HeadArray();
			AltHeadArray();
			BlackHeadArray();
			AltStatusArray();
			BlackStatusArray();
			Update();
			loaded = true;
		}
	}
	
	public function Update()
	{
		toxicpercent = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_toxicpercent_id'))*0.01f;	
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATtoxic_id') == "0"){
			BlackTox = true;                      
		}else{
			BlackTox = false;
			BlackStatusArray[0] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATtoxic_id') == "1") {
			AltTox = true;
		}else{
			AltTox = false;
			AltStatusArray[0] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATdark_id') == "0") {
			BlackDark = true;
		}else{
			BlackDark = false;
			BlackStatusArray[1] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATdark_id') == "1") {
			AltDark = true;
		}else{
			AltDark = false;
			AltStatusArray[1] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATtoxanddark_id') == "0") {
			BlackToxAndDark = true;
		}else{
			BlackToxAndDark = false;
			BlackStatusArray[2] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATtoxanddark_id') == "1") {
			AltToxAndDark = true;
		}else{
			AltToxAndDark = false;
			AltStatusArray[2] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcat_id') == "0") {
			BlackCat = true;
		}else{
			BlackCat = false;
			BlackStatusArray[3] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcat_id') == "1") {
			AltCat = true;
		}else{
			AltCat = false;
			AltStatusArray[3] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcombatday_id') == "0") {
			BlackCombatDay = true;
		}else{
			BlackCombatDay = false;
			BlackStatusArray[4] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcombatday_id') == "1") {
			AltCombatDay = true;
		}else{
			AltCombatDay = false;
			AltStatusArray[4] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcombatdark_id') == "0") {
			BlackCombatDark = true;
		}else{
			BlackCombatDark = false;
			BlackStatusArray[5] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATcombatdark_id') == "1") {
			AltCombatDark = true;
		}else{
			AltCombatDark = false;
			AltStatusArray[5] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATwitchersenses_id') == "0") {
			BlackWitcherSenses = true;
		}else{
			BlackWitcherSenses = false;
			BlackStatusArray[6] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATwitchersenses_id') == "1") {
			AltWitcherSenses = true;
		}else{
			AltWitcherSenses = false;
			AltStatusArray[6] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATbuttontriggerblack_id') == "false") {
			BlackButtonToggle = false;
			BlackStatusArray[7] = false;
		}else{
			BlackButtonToggle = true;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATbuttontriggeralt_id') == "false") {
			AltButtonToggle = false;
			AltStatusArray[7] = false;
		}else{
			AltButtonToggle = true;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_Priority_id') == "false") {
			priority = false;
		}else{
			priority = true;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATstatic_id') == "0") {
			BlackStatic = true;
			BlackStatusArray[8] = true;
		}else{
			BlackStatic = false;
			BlackStatusArray[8] = false;
		}
		if (theGame.GetInGameConfigWrapper().GetVarValue('modME', 'modME_ATstatic_id') == "1") {
			AltStatic = true;
			AltStatusArray[8] = true;
		}else{
			AltStatic = false;
			AltStatusArray[8] = false;
		}
		if(CheckAltStatusArray())
		{
			altEyesActive = true;
		}else{
			altEyesActive = false;
		}
		if(CheckBlackStatusArray())
		{
			blackEyesActive = true;
		}else{
			blackEyesActive = false;
		}
		Refresh();
			
	}
		
	function HeadArray()
	{
		HeadArray.PushBack('head_0');
		HeadArray.PushBack('head_0_tattoo');
		HeadArray.PushBack('head_1');
		HeadArray.PushBack('head_1_tattoo');
		HeadArray.PushBack('head_2');
		HeadArray.PushBack('head_2_tattoo');
		HeadArray.PushBack('head_3');
		HeadArray.PushBack('head_3_tattoo');
		HeadArray.PushBack('head_4');
		HeadArray.PushBack('head_4_tattoo');
		HeadArray.PushBack('head_5');
		HeadArray.PushBack('head_5_tattoo');
		HeadArray.PushBack('head_6');
		HeadArray.PushBack('head_6_tattoo');
		HeadArray.PushBack('head_7');
		HeadArray.PushBack('head_7_tattoo');
		HeadArray.PushBack('head_0_mark');
		HeadArray.PushBack('head_1_mark');
		HeadArray.PushBack('head_2_mark');
		HeadArray.PushBack('head_3_mark');
		HeadArray.PushBack('head_4_mark');
		HeadArray.PushBack('head_5_mark');
		HeadArray.PushBack('head_6_mark');
		HeadArray.PushBack('head_7_mark');
		HeadArray.PushBack('head_0_mark_tattoo');
		HeadArray.PushBack('head_1_mark_tattoo');
		HeadArray.PushBack('head_2_mark_tattoo');
		HeadArray.PushBack('head_3_mark_tattoo');
		HeadArray.PushBack('head_4_mark_tattoo');
		HeadArray.PushBack('head_5_mark_tattoo');
		HeadArray.PushBack('head_6_mark_tattoo');
		HeadArray.PushBack('head_7_mark_tattoo');
		HeadArray.PushBack('head_shaving1');
		HeadArray.PushBack('head_shaving2');
		HeadArray.PushBack('head_shaving3');
		HeadArray.PushBack('head_robbery');
		HeadArray.PushBack('head_robbery_tattoo');
		HeadArray.PushBack('head_robbery_mark');
		HeadArray.PushBack('head_robbery_mark_tattoo');
	}

function AltHeadArray()
	{
		AltHeadArray.PushBack('alt_head_0');
		AltHeadArray.PushBack('alt_head_0_tattoo');
		AltHeadArray.PushBack('alt_head_1');
		AltHeadArray.PushBack('alt_head_1_tattoo');
		AltHeadArray.PushBack('alt_head_2');
		AltHeadArray.PushBack('alt_head_2_tattoo');
		AltHeadArray.PushBack('alt_head_3');
		AltHeadArray.PushBack('alt_head_3_tattoo');
		AltHeadArray.PushBack('alt_head_4');
		AltHeadArray.PushBack('alt_head_4_tattoo');
		AltHeadArray.PushBack('alt_head_5');
		AltHeadArray.PushBack('alt_head_5_tattoo');
		AltHeadArray.PushBack('alt_head_6');
		AltHeadArray.PushBack('alt_head_6_tattoo');
		AltHeadArray.PushBack('alt_head_7');
		AltHeadArray.PushBack('alt_head_7_tattoo');
		AltHeadArray.PushBack('alt_head_0_mark');
		AltHeadArray.PushBack('alt_head_1_mark');
		AltHeadArray.PushBack('alt_head_2_mark');
		AltHeadArray.PushBack('alt_head_3_mark');
		AltHeadArray.PushBack('alt_head_4_mark');
		AltHeadArray.PushBack('alt_head_5_mark');
		AltHeadArray.PushBack('alt_head_6_mark');
		AltHeadArray.PushBack('alt_head_7_mark');
		AltHeadArray.PushBack('alt_head_0_mark_tattoo');
		AltHeadArray.PushBack('alt_head_1_mark_tattoo');
		AltHeadArray.PushBack('alt_head_2_mark_tattoo');
		AltHeadArray.PushBack('alt_head_3_mark_tattoo');
		AltHeadArray.PushBack('alt_head_4_mark_tattoo');
		AltHeadArray.PushBack('alt_head_5_mark_tattoo');
		AltHeadArray.PushBack('alt_head_6_mark_tattoo');
		AltHeadArray.PushBack('alt_head_7_mark_tattoo');
		AltHeadArray.PushBack('alt_head_shaving1');
		AltHeadArray.PushBack('alt_head_shaving2');
		AltHeadArray.PushBack('alt_head_shaving3');
		AltHeadArray.PushBack('alt_head_robbery');
		AltHeadArray.PushBack('alt_head_robbery_tattoo');
		AltHeadArray.PushBack('alt_head_robbery_mark');
		AltHeadArray.PushBack('alt_head_robbery_mark_tattoo');
	}

function BlackHeadArray()
	{
		BlackHeadArray.PushBack('black_head_0');
		BlackHeadArray.PushBack('black_head_0_tattoo');
		BlackHeadArray.PushBack('black_head_1');
		BlackHeadArray.PushBack('black_head_1_tattoo');
		BlackHeadArray.PushBack('black_head_2');
		BlackHeadArray.PushBack('black_head_2_tattoo');
		BlackHeadArray.PushBack('black_head_3');
		BlackHeadArray.PushBack('black_head_3_tattoo');
		BlackHeadArray.PushBack('black_head_4');
		BlackHeadArray.PushBack('black_head_4_tattoo');
		BlackHeadArray.PushBack('black_head_5');
		BlackHeadArray.PushBack('black_head_5_tattoo');
		BlackHeadArray.PushBack('black_head_6');
		BlackHeadArray.PushBack('black_head_6_tattoo');
		BlackHeadArray.PushBack('black_head_7');
		BlackHeadArray.PushBack('black_head_7_tattoo');
		BlackHeadArray.PushBack('black_head_0_mark');
		BlackHeadArray.PushBack('black_head_1_mark');
		BlackHeadArray.PushBack('black_head_2_mark');
		BlackHeadArray.PushBack('black_head_3_mark');
		BlackHeadArray.PushBack('black_head_4_mark');
		BlackHeadArray.PushBack('black_head_5_mark');
		BlackHeadArray.PushBack('black_head_6_mark');
		BlackHeadArray.PushBack('black_head_7_mark');
		BlackHeadArray.PushBack('black_head_0_mark_tattoo');
		BlackHeadArray.PushBack('black_head_1_mark_tattoo');
		BlackHeadArray.PushBack('black_head_2_mark_tattoo');
		BlackHeadArray.PushBack('black_head_3_mark_tattoo');
		BlackHeadArray.PushBack('black_head_4_mark_tattoo');
		BlackHeadArray.PushBack('black_head_5_mark_tattoo');
		BlackHeadArray.PushBack('black_head_6_mark_tattoo');
		BlackHeadArray.PushBack('black_head_7_mark_tattoo');
		BlackHeadArray.PushBack('black_head_shaving1');
		BlackHeadArray.PushBack('black_head_shaving2');
		BlackHeadArray.PushBack('black_head_shaving3');
		BlackHeadArray.PushBack('black_head_robbery');
		BlackHeadArray.PushBack('black_head_robbery_tattoo');
		BlackHeadArray.PushBack('black_head_robbery_mark');
		BlackHeadArray.PushBack('black_head_robbery_mark_tattoo');
	}
	
	
	function AltStatusArray(){
		AltStatusArray.PushBack(AltToxOn);
		AltStatusArray.PushBack(AltDarkOn);
		AltStatusArray.PushBack(AltToxDarkOn);
		AltStatusArray.PushBack(AltCatOn);
		AltStatusArray.PushBack(AltComDayOn);
		AltStatusArray.PushBack(AltComDarkOn);
		AltStatusArray.PushBack(AltWitcherOn);
		AltStatusArray.PushBack(AltToggOn);
		AltStatusArray.PushBack(AltStatOn);
	}
	
	function BlackStatusArray(){
		BlackStatusArray.PushBack(BlackToxOn);
		BlackStatusArray.PushBack(BlackDarkOn);
		BlackStatusArray.PushBack(BlackToxDarkOn);
		BlackStatusArray.PushBack(BlackCatOn);
		BlackStatusArray.PushBack(BlackComDayOn);
		BlackStatusArray.PushBack(BlackComDarkOn);
		BlackStatusArray.PushBack(BlackWitcherOn);
		BlackStatusArray.PushBack(BlackToggOn);
		BlackStatusArray.PushBack(BlackStatOn);
	}
	
	function CheckAltStatusArray() : bool
	{
		var i : int;
		for(i=0; i<AltStatusArray.Size(); i+=1)
		{
			if(AltStatusArray[i]==true)
			{
				return true;
			}
		}
		return false;
	}
	
	function CheckBlackStatusArray() : bool
	{
		var i : int;
		for(i=0; i<BlackStatusArray.Size(); i+=1)
		{
			if(BlackStatusArray[i])
			{
				return true;
			}
		}
		return false;
	}
	
	function FindInHeadArray ( nam : name) : int
	{
		var i : int;
		for(i=0; i<HeadArray.Size(); i+=1)
		{
			if(HeadArray[i] == nam)
			{
				return i;
			}
		}
		return -1;
	}

	function FindInAltHeadArray ( nam : name) : int
	{
		var i : int;
		for(i=0; i<AltHeadArray.Size(); i+=1)
		{
			if(AltHeadArray[i] == nam)
			{
				return i;
			}
		}
		return -1;
	}
	
	function FindInBlackHeadArray ( nam : name) : int
	{
		var i : int;
		for(i=0; i<BlackHeadArray.Size(); i+=1)
		{
			if(BlackHeadArray[i] == nam)
			{
				return i;
			}
		}
		return -1;
	}
	
	public function activateAlt()
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var i, j : int;
		var acs : array< CComponent >;
		
		inv = thePlayer.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				inv.RemoveItem(headIds[i]);
			}else{
				headId = headIds[i];
				storedHead = inv.GetItemName(headId);
			}
		}
		acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
		j = FindInHeadArray(storedHead);
		if(j!=-1){
			( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(AltHeadArray[j]);
			( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
		}
		else
		{
			j = FindInBlackHeadArray(storedHead);
			if(j!=-1){
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(AltHeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}
		}
	}
	
	public function activateBlack()
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var i, j : int;
		var acs : array< CComponent >;
		
		inv = thePlayer.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				inv.RemoveItem(headIds[i]);
			}else{
				headId = headIds[i];
				storedHead = inv.GetItemName(headId);
			}
		}
		acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
		j = FindInHeadArray(storedHead);
		if(j!=-1){
			( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(BlackHeadArray[j]);
			( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
		}
		else
		{
			j = FindInAltHeadArray(storedHead);
			if(j!=-1){
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(BlackHeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}
		}
	}

	public function deactivateAlt()
	{
		var inv : CInventoryComponent;
		var headIds, headitems : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i, j : int;
		var acs : array< CComponent >;
		inv = thePlayer.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				inv.RemoveItem(headIds[i]);
			}else{
				headId = headIds[i];
				storedHead = inv.GetItemName(headId);
			}
		}
		j = FindInAltHeadArray(storedHead);
		acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
		if(j!=-1){
			if(blackEyesActive)
			{
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(BlackHeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}else{
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(HeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}
		}	
	}
	
	public function deactivateBlack()
	{
		var inv : CInventoryComponent;
		var headIds, headitems : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i, j : int;
		var acs : array< CComponent >;
		inv = thePlayer.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				inv.RemoveItem(headIds[i]);
			}else{
				headId = headIds[i];
				storedHead = inv.GetItemName(headId);
			}
		}
		j = FindInBlackHeadArray(storedHead);
		acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
		if(j!=-1){
			if(altEyesActive)
			{
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(AltHeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}else{
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(HeadArray[j]);
				( ( CHeadManagerComponent ) acs[0] ).BlockGrowing(false);
			}
		}	
	}
	
	function Refresh()
	{
		var inv : CInventoryComponent;
		inv = thePlayer.GetInventory();
		if (!inv.HasMountedItemByTag('AltEyes') && altEyesActive)
		{
			if (!blackEyesActive || priority)
			{
				activateAlt();
			}
		}
		if (!inv.HasMountedItemByTag('BlackEyes') && blackEyesActive)
		{
			if(!altEyesActive || !priority)
			{
				activateBlack();
			}
		}
		if (!blackEyesActive && !altEyesActive)
		{
			deactivateAlt();
			deactivateBlack();
		}
	}	
}