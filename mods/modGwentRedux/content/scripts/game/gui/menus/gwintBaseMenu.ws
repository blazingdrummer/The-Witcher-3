/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3GwintQuitConfPopup extends ConfirmationPopupData
{
	public var gwintMenuRef : CR4GwintBaseMenu;
	
	protected function OnUserAccept() : void
	{
		gwintMenuRef.OnQuitGameConfirmed();
	}
}

class CR4GwintBaseMenu extends CR4MenuBase
{	
	protected var quitConfPopup : W3GwintQuitConfPopup;
	
	protected var gwintManager : CR4GwintManager;
	protected var flashConstructor : CScriptedFlashObject;

	event  OnConfigUI()
	{
		m_hideTutorial = true;
		m_forceHideTutorial = true;
		super.OnConfigUI();
		flashConstructor = m_flashValueStorage.CreateTempFlashObject();
		gwintManager = theGame.GetGwintManager();
		SendCardTemplates();
		theInput.StoreContext( 'EMPTY_CONTEXT' );

		theGame.ResetFadeLock( "GwintStart" );
		theGame.FadeInAsync( 0.2 );
	}
	
	event  OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		super.OnClosingMenu();
		
		if (quitConfPopup)
		{
			delete quitConfPopup;
		}
	}
	
	public function OnQuitGameConfirmed()
	{
		CloseMenu();
	}
	
	protected function SendCardTemplates()
	{
		var l_flashArray : CScriptedFlashArray;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		AddCardsToFlashArray(l_flashArray, gwintManager.GetCardDefinitions( false ));
		AddCardsToFlashArray(l_flashArray, gwintManager.GetCardDefinitions( true ));
		
		m_flashValueStorage.SetFlashArray( "gwint.card.templates", l_flashArray );
	}
	
	private function GetAlternativeCard(currentCard : SCardDefinition) : SCardDefinition
	{
		var configWrapper : CInGameConfigWrapper;
		var tmpInt : int;
		var tmpBool : bool;
		var altCard : SCardDefinition;
		
		configWrapper = theGame.GetInGameConfigWrapper();
		tmpInt = 0;
		tmpBool = false;
		
		switch (currentCard.picture)
		{
		case "neu_geralt":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardGeralt' ));
			break;
		case "neu_yennefer":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardYennefer' ));
			break;
		case "neu_ciri":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardCiri' ));
			break;
		case "nor_triss":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardTriss' ));
			break;
		case "nor_dandelion":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardDandelion' ));
			tmpBool = true;
			break;
		case "nor_zoltan":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardZoltan' ));
			break;
		case "nml_emiel":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardEmiel' ));
			break;
		case "nml_avallach":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardAvallach' ));
			break;
		case "nor_olgierd":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardOlgierd' ));
			break;
		case "nml_vran":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardVran' ));
			tmpBool = true;
			break;
		case "spc_nature":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardNature' ));
			tmpBool = true;
			break;
		case "nor_philippa":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardPhilippa' ));
			break;
		case "nor_dethmold":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardDethmold' ));
			tmpBool = true;
			break;
		case "nor_vincent":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardVincent' ));
			tmpBool = true;
			break;
		case "nor_whoreson":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardWhoreson' ));
			break;
		case "nor_siege_tower":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardTower' ));
			tmpBool = true;
			break;
		case "nil_tibor":
		case "nil_alba_division":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardAlba' ));
			tmpBool = true;
			break;
		case "sco_saesen":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardSaesen' ));
			break;
		case "nml_imlerith":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardImlerith' ));
			break;
		case "nml_drowner":
		case "nml_abaya":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardAbaya' ));
			tmpBool = true;
			break;
		case "ske_coral":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardCoral' ));
			break;
		case "nor_calanthe":
			tmpInt = StringToInt( configWrapper.GetVarValue( 'GwentReduxOptions', 'CardCalanthe' ));
			tmpBool = true;
			break;
		}
		
		altCard.picture = currentCard.picture;
		altCard.title = currentCard.title;
		altCard.description = currentCard.description;
		
		switch (tmpInt)
		{
		case 1:
			altCard.picture += "_alt1";
			if (tmpBool)
			{
				altCard.title += "_alt1";
				altCard.description += "_alt1";
			}
			break;
		case 2:
			altCard.picture += "_alt2";
			break;
		case 3:
			altCard.picture += "_alt3";
			break;
		case 4:
			altCard.picture += "_alt4";
			break;
		case 5:
			altCard.picture += "_alt5";
			break;
		}
		
		return altCard;
	}
	
	private function AddCardsToFlashArray(l_flashArray : CScriptedFlashArray, cards : array< SCardDefinition >)
	{
		var l_flashObject : CScriptedFlashObject;
		var currentCard, altCard : SCardDefinition;
		var combinedType : int;
		var i : int;
		
		for (i = 0; i < cards.Size(); i += 1)
		{
			currentCard = cards[i];
			altCard = GetAlternativeCard(currentCard);
			
			l_flashObject = flashConstructor.CreateFlashObject("red.game.witcher3.menus.gwint.CardTemplate");
			
			l_flashObject.SetMemberFlashInt("index", currentCard.index);
			l_flashObject.SetMemberFlashString("title", GetLocStringByKeyExt(altCard.title));
			l_flashObject.SetMemberFlashString("description", GetLocStringByKeyExt(altCard.description));
			l_flashObject.SetMemberFlashInt("power", currentCard.power);
			l_flashObject.SetMemberFlashString("imageLoc", altCard.picture);
			l_flashObject.SetMemberFlashInt("factionIdx", currentCard.faction);
			l_flashObject.SetMemberFlashInt("typeArray", currentCard.typeFlags);
			AddCardEffectsToFlashObject(l_flashObject, currentCard);
			AddSummonFlagsToObject(l_flashObject, currentCard);
			
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
	}
	
	private function AddCardEffectsToFlashObject(flashObject:CScriptedFlashObject, card : SCardDefinition)
	{
		var flashEffectArray : CScriptedFlashArray;
		var i : int;
		
		flashEffectArray = m_flashValueStorage.CreateTempFlashArray();
		
		for (i = 0; i < card.effectFlags.Size(); i += 1)
		{
			flashEffectArray.PushBackFlashInt(card.effectFlags[i]);
		}
		
		flashObject.SetMemberFlashArray("effectFlags", flashEffectArray);
	}
	
	private function AddSummonFlagsToObject(flashObject:CScriptedFlashObject, card : SCardDefinition)
	{
		var flashSummonArray : CScriptedFlashArray;
		var i : int;
		
		flashSummonArray = m_flashValueStorage.CreateTempFlashArray();
		
		for (i = 0; i < card.summonFlags.Size(); i += 1)
		{
			flashSummonArray.PushBackFlashInt(card.summonFlags[i]);
		}
		
		flashObject.SetMemberFlashArray("summonFlags", flashSummonArray);
	}
	
	public function CreateDeckDefinitionFlash(deckInfo : SDeckDefinition) : CScriptedFlashObject
	{
		var deckFlashObject : CScriptedFlashObject;
		var indicesFlashArray : CScriptedFlashArray;
		var dynCardRequirements : CScriptedFlashArray;
		var dynCards : CScriptedFlashArray;
		var i : int;
		
		deckFlashObject = flashConstructor.CreateFlashObject("red.game.witcher3.menus.gwint.GwintDeck");
		indicesFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		deckFlashObject.SetMemberFlashString("deckName", "");
		
		for (i = 0; i < deckInfo.cardIndices.Size(); i += 1)
		{
			indicesFlashArray.PushBackFlashInt(deckInfo.cardIndices[i]);
		}
		deckFlashObject.SetMemberFlashArray("cardIndices", indicesFlashArray);
		deckFlashObject.SetMemberFlashBool("isUnlocked", deckInfo.unlocked);
		
		deckFlashObject.SetMemberFlashInt("selectedKingIndex", deckInfo.leaderIndex);
		deckFlashObject.SetMemberFlashInt("specialCard", deckInfo.specialCard);
		
		dynCardRequirements = m_flashValueStorage.CreateTempFlashArray();
		for (i = 0; i < deckInfo.dynamicCardRequirements.Size(); i += 1)
		{
			dynCardRequirements.PushBackFlashInt(deckInfo.dynamicCardRequirements[i]);
		}
		deckFlashObject.SetMemberFlashArray("dynamicCardRequirements", dynCardRequirements);
		
		dynCards = m_flashValueStorage.CreateTempFlashArray();
		for (i = 0; i < deckInfo.dynamicCards.Size(); i += 1)
		{
			dynCards.PushBackFlashInt(deckInfo.dynamicCards[i]);
		}
		deckFlashObject.SetMemberFlashArray("dynamicCards", dynCards);
		
		return deckFlashObject;
	}
	
	public function FillArrayWithCardList(cardList:array< CollectionCard >, targetArray:CScriptedFlashArray):void
	{
		var cardInfo : CScriptedFlashObject;
		var i : int;
		
		for (i = 0; i < cardList.Size(); i += 1)
		{
			cardInfo = m_flashValueStorage.CreateTempFlashObject();
			cardInfo.SetMemberFlashInt("cardID", cardList[i].cardID);
			cardInfo.SetMemberFlashInt("numCopies", cardList[i].numCopies);
			targetArray.PushBackFlashObject(cardInfo);
		}
	}
	
	event  OnConfirmSurrender():void
	{
		quitConfPopup = new W3GwintQuitConfPopup in this;
		
		quitConfPopup.SetMessageTitle(GetLocStringByKeyExt("gwint_pass_game"));
		quitConfPopup.SetMessageText(GetLocStringByKeyExt("gwint_surrender_message_desc"));
		quitConfPopup.gwintMenuRef = this;
		quitConfPopup.BlurBackground = true;
		
		RequestSubMenu('PopupMenu', quitConfPopup);
	}
}