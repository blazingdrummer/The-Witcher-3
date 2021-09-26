function for_possible_additions()
{

	if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_disable_mod')
		|| theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_disable_stuff')
		) { return; }
	
	if ( ( thePlayer.GetCurrentStateName()== 'Meditation' || thePlayer.GetCurrentStateName()== 'MeditationWaiting' 
		|| thePlayer.GetCurrentStateName()== 'W3EEMeditation' || thePlayer.GetCurrentStateName()== 'AlchemyBrewing' )
		&& !((W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' )).GetWasUsed() )
	{ 
		if ( FactsQuerySum("stuff_left_campfire") <= 0 && FactsQuerySum("campfire_ready") > 0 )
		{
			prepare_stuff_for_picnic(true);
			placestuffcampfire();
		}
	}
	
	if ( thePlayer.GetCurrentStateName()!= 'Meditation' &&  thePlayer.GetCurrentStateName()!= 'MeditationWaiting' 
	  && thePlayer.GetCurrentStateName()!= 'W3EEMeditation' && thePlayer.GetCurrentStateName()!= 'AlchemyBrewing'
		&& FactsQuerySum("geralt_meditates")>0 && FactsQuerySum("stuff_left_campfire") <= 0)
	{
		prepare_stuff_for_picnic(false);
	}

}

function prepare_stuff_for_picnic( meditation : bool )
{
	var dummy, base, book, herb, herb1, herb2, bolt,bottle1 										: CEntity;
	var bomb11, bomb22, bomb33, bomb44																: CEntity;
	var steelcomp, silvercomp,scabbardscomp, scabbardscompsteel,scabbardscompsilver					: CDrawableComponent;
	var exclude_herb,exclude_herb1,exclude_herb2,exclude_book										: Bool;
	var dummies 																					: array<CEntity>;
	var i 																							: Int;
	var quantity,row1,row2,row3 																	: Int;
	var boltid,bomb1id,bomb2id,bomb3id,bomb4id,potid												: SItemUniqueId;
	var deployedEnt																					: W3BoltProjectile;
	var bomb1, bomb2, bomb3, bomb4																	: W3Petard;
	var vial1, vial2, vial3, vial4																	: CEntity;
	
	if ( meditation )
	{
		
		if ( FactsQuerySum ("campfire_check_stuff_1") > 0 ) { return; }
		FactsAdd("campfire_check_stuff_1",,1);
	
		////////// BASE
		//////////
		if ( !theGame.GetEntityByTag('base_campfire') )
		{
			base = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("items\work\folded_sail_01\folded_sail_01.w2ent",true ),
						thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
			base.AddTag('base_campfire');
			base.AddTag('stuff_campfire');
		}
		//////////
		
		
		////////// BOOK
		//////////
		if ( theGame.GetEntityByTag('closed_book_campfire') && ( GetRainStrength()+GetSnowStrength() ) <= 0 )
		{
			theGame.GetEntityByTag('book_campfire').Destroy();
			FactsRemove("book_placed_campfire");	
		}
		if ( theGame.GetEntityByTag('open_book_campfire') && ( GetRainStrength()+GetSnowStrength() ) > 0 )
		{
			theGame.GetEntityByTag('book_campfire').Destroy();
			FactsRemove("book_placed_campfire");	
		}
		
		if ( !theGame.GetEntityByTag('book_campfire') && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_book', 'campfire_exclude_book') )
		{
		
			if ( ( GetRainStrength()+GetSnowStrength() ) > 0 )
			{
				book = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\bob\data\items\quest_items\q705\q705_gmpl_yens_book.w2ent",true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
							book.AddTag('closed_book_campfire');
			}
			if ( ( GetRainStrength()+GetSnowStrength() ) <= 0 )
			{
				book = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\bob\data\items\work\book\gen_open_book_a.w2ent",true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
							book.AddTag('open_book_campfire');
			}
			book.AddTag('book_campfire');	
			book.AddTag('stuff_campfire');
		}
			
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_book', 'campfire_exclude_book') )
			{
				theGame.GetEntityByTag('book_campfire').Destroy();
				FactsRemove("book_placed_campfire");	
			}
		//////////
		
		////////// HERBS
		//////////
		if ( !theGame.GetEntityByTag('herb_campfire') && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb', 'campfire_exclude_herb') )
		{
			herb = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
					("dlc\bob\data\environment\decorations\gameplay\generic\decoration_set\herbs\deco_gen_herb_f.w2ent",true ),
						thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
			herb.AddTag('herb_campfire');	
			herb.AddTag('stuff_campfire');	
		}
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb', 'campfire_exclude_herb') )
			{
				theGame.GetEntityByTag('herb_campfire').Destroy();
				FactsRemove("herb_placed_campfire");	
			}
		//////////
		
		//////////
		if ( !theGame.GetEntityByTag('herb1_campfire') && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb1', 'campfire_exclude_herb1') )
		{
			herb1 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
					("items\work\herbs\tool_herb_a.w2ent",true ),
						thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
			herb1.AddTag('herb1_campfire');	
			herb1.AddTag('stuff_campfire');	
		}
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb1', 'campfire_exclude_herb1') )
			{
				theGame.GetEntityByTag('herb1_campfire').Destroy();
				FactsRemove("herb1_placed_campfire");	
			}
		//////////
		
		//////////
		if ( !theGame.GetEntityByTag('herb2_campfire') && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb2', 'campfire_exclude_herb2') )
		{
			herb2 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
					("items\work\herbs\tool_herb_b.w2ent",true ),
						thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
			herb2.AddTag('herb2_campfire');	
			herb2.AddTag('stuff_campfire');	
		}
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb2', 'campfire_exclude_herb2') )
			{
				theGame.GetEntityByTag('herb2_campfire').Destroy();
				FactsRemove("herb2_placed_campfire");	
			}
		//////////
		
		////////// BOLTS
		//////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bolt', 'campfire_exclude_bolt')	&& thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Bolt, boltid) )
		{
			
				deployedEnt = (W3BoltProjectile)( thePlayer.GetInventory().GetDeploymentItemEntity(boltid) );
			
				if ( !theGame.GetEntityByTag('bolt0_campfire') )
				{
					bolt = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
							(deployedEnt.GetReadableName(),true ),
								thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
					bolt.AddTag('bolt0_campfire');	
					bolt.AddTag('stuff_campfire');	
					bolt.AddTag('bolts_campfire');	
					
					if ( thePlayer.GetInventory().ItemHasTag(boltid, theGame.params.TAG_INFINITE_AMMO) )
					{ quantity = 8; }
					else 
					{ quantity = thePlayer.GetInventory().GetItemQuantity( boltid ) - 1 ; }
					row1 = Min( quantity,4 );
					row2 = Min( quantity - row1,3 );
					row3 = Min( quantity - row1 - row2,2 );
					
					if ( row1 > 0 )
					{
						for(i=1; i<=row1; i+=1)
						{
							bolt = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								(deployedEnt.GetReadableName(),true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
							bolt.AddTag('stuff_campfire');	
							bolt.AddTag('bolts_campfire');	
							bolt.CreateAttachment(theGame.GetEntityByTag('bolt0_campfire'),,Vector(0+i*0.02,0,0)  );
						}
					}
					if ( row2 > 0 )
					{
						for(i=1; i<=row2; i+=1)
						{
							bolt = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								(deployedEnt.GetReadableName(),true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
							bolt.AddTag('stuff_campfire');	
							bolt.AddTag('bolts_campfire');	
							bolt.CreateAttachment(theGame.GetEntityByTag('bolt0_campfire'),,Vector(0.01+i*0.02,0,0-0.02)  );
						}
					}
					if ( row3 > 0 )
					{
						for(i=1; i<=row3; i+=1)
						{
							bolt = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								(deployedEnt.GetReadableName(),true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
							bolt.AddTag('stuff_campfire');	
							bolt.AddTag('bolts_campfire');	
							bolt.CreateAttachment(theGame.GetEntityByTag('bolt0_campfire'),,Vector(0.02+i*0.02,0,0-0.04)  );
						}
					}
				}
				
				if ( deployedEnt.GetReadableName() != theGame.GetEntityByTag('bolt0_campfire').GetReadableName() )
				{
					theGame.GetEntitiesByTag('bolts_campfire',dummies);
					for(i=0; i<dummies.Size(); i+=1)
					{
						dummies[i].Destroy();
					} 	
					
					FactsRemove("bolt_placed_campfire");	
				}
				
				
			}
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bolt', 'campfire_exclude_bolt') || !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Bolt, boltid) )
			{
				theGame.GetEntitiesByTag('bolts_campfire',dummies);
				for(i=0; i<dummies.Size(); i+=1)
				{
					dummies[i].Destroy();
				} 	
				
				FactsRemove("bolt_placed_campfire");	
			}
		//////////
		
		////////// BOMBS
		//////////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb1', 'campfire_exclude_bomb1') && thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard1, bomb1id) )
		{
			bomb1 = (W3Petard)( thePlayer.GetInventory().GetDeploymentItemEntity(bomb1id) );	
			if ( !theGame.GetEntityByTag('bomb1_campfire') )
			{
				bomb11 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
						(bomb1.GetReadableName(),true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
				bomb11.AddTag('bomb1_campfire');	
				bomb11.AddTag('stuff_campfire');
				//theGame.witcherLog.AddMessage(bomb1.GetReadableName());
			}
			
			if ( bomb1.GetReadableName() != theGame.GetEntityByTag('bomb1_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('bomb1_campfire').Destroy();
				FactsRemove("bomb1_placed_campfire");	
			}
		}
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb1', 'campfire_exclude_bomb1') || !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard1, bomb1id) )
		{
			theGame.GetEntityByTag('bomb1_campfire').Destroy();
			FactsRemove("bomb1_placed_campfire");	
		}
		////////////
		
		//////////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb2', 'campfire_exclude_bomb2') && thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard2, bomb2id) )
		{
			bomb2 = (W3Petard)( thePlayer.GetInventory().GetDeploymentItemEntity(bomb2id) );	
			if ( !theGame.GetEntityByTag('bomb2_campfire') )
			{
				bomb22 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
						(bomb2.GetReadableName(),true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
				bomb22.AddTag('bomb2_campfire');	
				bomb22.AddTag('stuff_campfire');
				//theGame.witcherLog.AddMessage(bomb2.GetReadableName());
			}
			
			if ( bomb2.GetReadableName() != theGame.GetEntityByTag('bomb2_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('bomb2_campfire').Destroy();
				FactsRemove("bomb2_placed_campfire");	
			}
		}
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb2', 'campfire_exclude_bomb2') || !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard2, bomb2id) )
		{
			theGame.GetEntityByTag('bomb2_campfire').Destroy();
			FactsRemove("bomb2_placed_campfire");	
		}
		////////////
		
		
		//////////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb3', 'campfire_exclude_bomb3') && thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard3, bomb3id) )
		{
			bomb3 = (W3Petard)( thePlayer.GetInventory().GetDeploymentItemEntity(bomb3id) );	
			if ( !theGame.GetEntityByTag('bomb3_campfire') )
			{
				bomb33 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
						(bomb3.GetReadableName(),true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
				bomb33.AddTag('bomb3_campfire');	
				bomb33.AddTag('stuff_campfire');
				//theGame.witcherLog.AddMessage(bomb3.GetReadableName());
			}
			
			if ( bomb3.GetReadableName() != theGame.GetEntityByTag('bomb3_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('bomb3_campfire').Destroy();
				FactsRemove("bomb3_placed_campfire");	
			}
		}
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb3', 'campfire_exclude_bomb3') || !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard3, bomb3id) )
		{
			theGame.GetEntityByTag('bomb3_campfire').Destroy();
			FactsRemove("bomb3_placed_campfire");	
		}
		////////////
		
		//////////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb4', 'campfire_exclude_bomb4') && thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard4, bomb4id) )
		{
			bomb4 = (W3Petard)( thePlayer.GetInventory().GetDeploymentItemEntity(bomb4id) );	
			if ( !theGame.GetEntityByTag('bomb4_campfire') )
			{
				bomb44 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
						(bomb4.GetReadableName(),true ),
							thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
				bomb44.AddTag('bomb4_campfire');	
				bomb44.AddTag('stuff_campfire');
				//theGame.witcherLog.AddMessage(bomb4.GetReadableName());
			}
			
			if ( bomb4.GetReadableName() != theGame.GetEntityByTag('bomb4_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('bomb4_campfire').Destroy();
				FactsRemove("bomb4_placed_campfire");	
			}
		}
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb4', 'campfire_exclude_bomb4') || !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Petard4, bomb4id) )
		{
			theGame.GetEntityByTag('bomb4_campfire').Destroy();
			FactsRemove("bomb4_placed_campfire");	
		}
		////////////
		
		
		////////// BOTTLE
		//////////
		if ( !theGame.GetEntityByTag('bottle1_campfire') && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bottle1', 'campfire_exclude_bottle1') )
		{
			bottle1 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
					("items\quest_items\mh107\mh107_item_czart_lure_potion.w2ent",true ),
						thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
			bottle1.AddTag('bottle1_campfire');	
			bottle1.AddTag('stuff_campfire');	
		}
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bottle1', 'campfire_exclude_bottle1') )
			{
				theGame.GetEntityByTag('bottle1_campfire').Destroy();
				FactsRemove("bottle1_placed_campfire");	
			}
		//////////
		
		
		////////// VIALS
		//////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial1', 'campfire_exclude_vial1') )
		{
			if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Potion1, potid) )
			{
				if ( thePlayer.GetInventory().IsItemPotion(potid) )
				{
					if ( !theGame.GetEntityByTag('vial1_campfire') )
					{
						vial1 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								("dlc\ep1\data\items\quest_items\q601\q601_item__empty_flask.w2ent",true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
						vial1.AddTag('vial1_campfire');	
						vial1.AddTag('stuff_campfire');	
					}
				}
				else
				{
					if ( theGame.GetEntityByTag('vial1_campfire') )
					{
						theGame.GetEntityByTag('vial1_campfire').Destroy();
						FactsRemove("vial1_placed_campfire");	
					}
				}
			}
			else
			{
				if ( theGame.GetEntityByTag('vial1_campfire') )
				{
					theGame.GetEntityByTag('vial1_campfire').Destroy();
					FactsRemove("vial1_placed_campfire");	
				}
			}
		}
		else 
		{
			if ( theGame.GetEntityByTag('vial1_campfire') ) 
			{
				theGame.GetEntityByTag('vial1_campfire').Destroy();
				FactsRemove("vial1_placed_campfire");	
			}
		}
		//////////
		
		//////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial2', 'campfire_exclude_vial2') )
		{
			if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Potion2, potid) )
			{
				if ( thePlayer.GetInventory().IsItemPotion(potid) )
				{
					if ( !theGame.GetEntityByTag('vial2_campfire') )
					{
						vial2 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								("dlc\ep1\data\items\quest_items\q601\q601_item__empty_flask.w2ent",true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
						vial2.AddTag('vial2_campfire');	
						vial2.AddTag('stuff_campfire');	
					}
				}
				else
				{
					if ( theGame.GetEntityByTag('vial2_campfire') )
					{
						theGame.GetEntityByTag('vial2_campfire').Destroy();
						FactsRemove("vial2_placed_campfire");	
					}
				}
			}
			else
			{
				if ( theGame.GetEntityByTag('vial2_campfire') )
				{
					theGame.GetEntityByTag('vial2_campfire').Destroy();
					FactsRemove("vial2_placed_campfire");	
				}
			}
		}
		else if ( theGame.GetEntityByTag('vial2_campfire') )
		{
			theGame.GetEntityByTag('vial2_campfire').Destroy();
			FactsRemove("vial2_placed_campfire");	
		}
		//////////
				
		//////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial3', 'campfire_exclude_vial3') )
		{
			if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Potion3, potid) )
			{
				if ( thePlayer.GetInventory().IsItemPotion(potid) )
				{
					if ( !theGame.GetEntityByTag('vial3_campfire') )
					{
						vial3 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								("dlc\ep1\data\items\quest_items\q601\q601_item__empty_flask.w2ent",true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
						vial3.AddTag('vial3_campfire');	
						vial3.AddTag('stuff_campfire');	
					}
				}
				else
				{
					if ( theGame.GetEntityByTag('vial3_campfire') )
					{
						theGame.GetEntityByTag('vial3_campfire').Destroy();
						FactsRemove("vial3_placed_campfire");	
					}
				}
			}
			else
			{
				if ( theGame.GetEntityByTag('vial3_campfire') )
				{
					theGame.GetEntityByTag('vial3_campfire').Destroy();
					FactsRemove("vial3_placed_campfire");	
				}
			}
		}
		else if ( theGame.GetEntityByTag('vial3_campfire') )
		{
			theGame.GetEntityByTag('vial3_campfire').Destroy();
			FactsRemove("vial3_placed_campfire");	
		}
		//////////
		
		//////////
		if ( !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial4', 'campfire_exclude_vial4') )
		{
			if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Potion4, potid) )
			{
				if ( thePlayer.GetInventory().IsItemPotion(potid) )
				{
					if ( !theGame.GetEntityByTag('vial4_campfire') )
					{
						vial4 = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource
								("dlc\ep1\data\items\quest_items\q601\q601_item__empty_flask.w2ent",true ),
									thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation()  );
						vial4.AddTag('vial4_campfire');	
						vial4.AddTag('stuff_campfire');	
					}
				}
				else
				{
					if ( theGame.GetEntityByTag('vial4_campfire') )
					{
						theGame.GetEntityByTag('vial4_campfire').Destroy();
						FactsRemove("vial4_placed_campfire");	
					}
				}
			}
			else
			{
				if ( theGame.GetEntityByTag('vial4_campfire') )
				{
					theGame.GetEntityByTag('vial4_campfire').Destroy();
					FactsRemove("vial4_placed_campfire");	
				}
			}
		}
		else if ( theGame.GetEntityByTag('vial4_campfire') ) 
		{
			theGame.GetEntityByTag('vial4_campfire').Destroy();
			FactsRemove("vial4_placed_campfire");	
		}
		//////////
		
	}
	
	if ( !meditation )
	{
		theGame.GetEntitiesByTag('stuff_campfire',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy(); 
			dummy = NULL;
		} 	
		
		
		FactsRemove("base_placed_campfire");		
		FactsRemove("book_placed_campfire");	
		FactsRemove("herb_placed_campfire");	
		FactsRemove("herb1_placed_campfire");	
		FactsRemove("herb2_placed_campfire");	
		FactsRemove("bolt_placed_campfire");	
		
		FactsRemove("bomb1_placed_campfire");	
		FactsRemove("bomb2_placed_campfire");	
		FactsRemove("bomb3_placed_campfire");
		FactsRemove("bomb4_placed_campfire");	
		
		FactsRemove("bottle1_placed_campfire");	
		
		FactsRemove("vial1_placed_campfire");	
		FactsRemove("vial2_placed_campfire");	
		FactsRemove("vial3_placed_campfire");	
		FactsRemove("vial4_placed_campfire");	
	}
}

function placestuffcampfire()
{
	var enable_changes_base,enable_changes_book,enable_changes_herb 							: Bool;	
	var enable_changes_herb1,enable_changes_herb2,hide_base,enable_changes_bolt					: Bool;	
	var enable_changes_bomb1,enable_changes_bomb2,enable_changes_bomb3,enable_changes_bomb4 	: Bool;
	var enable_changes_vial1,enable_changes_vial2,enable_changes_vial3,enable_changes_vial4 	: Bool;
	var enable_changes_bottle1																	: Bool;
	var base_roll, base_pitch, base_yaw 														: Float; 
	var base_pos_x,base_pos_y,base_pos_z   														: Float;
	var base_on_roach_position																	: Vector;
	var base_on_roach_rotation							 										: EulerAngles;
	var base_on_roach, book, herb,herb1,herb2,bolt,bomb1,bomb2,bomb3,bomb4,bottle1				: CEntity;
	var Configsw 																				: CInGameConfigWrapper;
	var vial1, vial2, vial3, vial4																: CEntity;
	var meshComponent 																			: CMeshComponent;

	
	if ( theInput.IsActionPressed( 'SwordSheathe' ) && FactsQuerySum("pressed_stuff_campfire")<=0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
		if ( StringToInt( Configsw.GetVarValue('swords_campfire_base', 'preset_campfire_base') ) < 8 )
		{
			Configsw.ApplyGroupPreset('swords_campfire_base', StringToInt( Configsw.GetVarValue('swords_campfire_base', 'preset_campfire_base') ) + 1 );
		}
		else 
		{
			Configsw.ApplyGroupPreset('swords_campfire_base', 0 );
		}
		theGame.GetInGameConfigWrapper().SetVarValue( 'swords_campfire_base', 'campfire_enable_changes_base', "true" ); 
		FactsAdd("pressed_stuff_campfire",,1);
		FactsRemove("campfire_place_stuff_1");
	}
	
	
	
	if ( FactsQuerySum ("campfire_place_stuff_1") > 0 ) { return; }
	FactsAdd("campfire_place_stuff_1",,1);
	
	hide_base = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_hide_base');
	
	enable_changes_base = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_enable_changes_base');
	
	enable_changes_book = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_book', 'campfire_enable_changes_book');
	
	enable_changes_herb = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb', 'campfire_enable_changes_herb');
	enable_changes_herb1 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb1', 'campfire_enable_changes_herb1');
	enable_changes_herb2 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb2', 'campfire_enable_changes_herb2');
	
	enable_changes_bolt = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bolt', 'campfire_enable_changes_bolt');
	
	enable_changes_bomb1 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb1', 'campfire_enable_changes_bomb1');
	enable_changes_bomb2 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb2', 'campfire_enable_changes_bomb2');
	enable_changes_bomb3 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb3', 'campfire_enable_changes_bomb3');
	enable_changes_bomb4 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb4', 'campfire_enable_changes_bomb4');
	
	enable_changes_bottle1 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bottle1', 'campfire_enable_changes_bottle1');
	
	enable_changes_vial1 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial1', 'campfire_enable_changes_vial1');
	enable_changes_vial2 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial2', 'campfire_enable_changes_vial2');
	enable_changes_vial3 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial3', 'campfire_enable_changes_vial3');
	enable_changes_vial4 = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial4', 'campfire_enable_changes_vial4');

	
	if ( ( theGame.GetEntityByTag('base_campfire') && FactsQuerySum("base_placed_campfire") <= 0 )
		|| enable_changes_base )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_base', 'base_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_base', 'base_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_base', 'base_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_base',  'base_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_base', 'base_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_base',   'base_yaw_campfire')); 
			
		base_on_roach = theGame.GetEntityByTag('base_campfire');
		base_on_roach.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X += base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z += base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		base_on_roach.CreateAttachment( thePlayer,,base_on_roach_position, base_on_roach_rotation );
		
		/*
		pos_xbow_start = xbow_on_roach.GetWorldPosition(); 		        		// start
		pos_xbow_start = TraceFloor(pos_xbow_start);
		
		pos_xbow_end = xbow_on_roach.GetWorldPosition() + xbow_on_roach.GetWorldUp()*0.4; 		        		// end
		pos_xbow_end = TraceFloor(pos_xbow_end);
		
		xbow_on_roach.BreakAttachment();
		xbow_on_roach_rotation.Roll -= adjust_angle_campfire( pos_xbow_end, pos_xbow_start );
		xbow_on_roach.CreateAttachment( thePlayer,,xbow_on_roach_position, xbow_on_roach_rotation );
		*/
		
		base_on_roach.BreakAttachment();
		base_on_roach_position = TraceFloor(base_on_roach.GetWorldPosition());
		base_on_roach_position.Z += base_pos_z;
		base_on_roach.Teleport( base_on_roach_position );
		
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_hide_base') )
		{
			meshComponent = ( CMeshComponent ) theGame.GetEntityByTag('base_campfire').GetComponentByClassName( 'CMeshComponent' );
			if ( meshComponent.IsVisible() )
			{
				meshComponent.SetVisible(false);
			}
		}
		else
		{
			meshComponent = ( CMeshComponent ) theGame.GetEntityByTag('base_campfire').GetComponentByClassName( 'CMeshComponent' );
			if ( !meshComponent.IsVisible() )
			{
				meshComponent.SetVisible(true);
			}
		}

		
		FactsAdd("resize_base",,2);
		
		FactsAdd("base_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_base )
		{
			enable_changes_book = true;
			enable_changes_herb = true;
			enable_changes_herb1 = true;
			enable_changes_herb2 = true;
			enable_changes_bolt = true;
			enable_changes_bomb1 = true;
			enable_changes_bomb2 = true;
			enable_changes_bomb3 = true;
			enable_changes_bomb4 = true;
			enable_changes_bottle1 = true;
			enable_changes_vial1 = true;
			enable_changes_vial2 = true;
			enable_changes_vial3 = true;
			enable_changes_vial4 = true;
			
			
			Configsw.SetVarValue( 'swords_campfire_base', 'campfire_enable_changes_base', "false" ); 
			enable_changes_base = false;
		}
	}
	
	if ( FactsQuerySum("resize_base") > 0 )
	{
		meshComponent = ( CMeshComponent ) theGame.GetEntityByTag('base_campfire').GetComponentByClassName( 'CMeshComponent' );
		meshComponent.SetScale( Vector( 1.5, 1.5, 1.5 ) );
	}
	

	if ( ( theGame.GetEntityByTag('book_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("book_placed_campfire") <= 0 )
		|| enable_changes_book )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_book', 'book_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_book', 'book_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_book', 'book_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_book',  'book_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_book', 'book_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_book',   'book_yaw_campfire')); 
			
		book = theGame.GetEntityByTag('book_campfire');
		book.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		if ( book.HasTag('open_book_campfire') )
		{
			base_on_roach_rotation.Roll = 0;
			base_on_roach_rotation.Pitch = 105;
			base_on_roach_rotation.Yaw = 0;
		}
		
		book.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_book', 'campfire_dontattach_book') )
		{
			book.BreakAttachment();
			base_on_roach_position = TraceFloor(book.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			book.Teleport( base_on_roach_position );
		}
		
		FactsAdd("book_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_book )
		{
			Configsw.SetVarValue('swords_campfire_book', 'campfire_enable_changes_book' , "false" ); 
			enable_changes_book = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('herb_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("herb_placed_campfire") <= 0 )
		|| enable_changes_herb )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_herb', 'herb_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_herb', 'herb_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_herb', 'herb_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_herb',  'herb_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_herb', 'herb_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_herb',   'herb_yaw_campfire')); 
			
		herb = theGame.GetEntityByTag('herb_campfire');
		herb.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		herb.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb', 'campfire_dontattach_herb') )
		{
			herb.BreakAttachment();
			base_on_roach_position = TraceFloor(herb.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			herb.Teleport( base_on_roach_position );
		}
			
		FactsAdd("herb_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_herb )
		{
			Configsw.SetVarValue('swords_campfire_herb', 'campfire_enable_changes_herb' , "false" ); 
			enable_changes_herb = false;
		}
	}
	
	if ( ( theGame.GetEntityByTag('herb1_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("herb1_placed_campfire") <= 0 )
		|| enable_changes_herb1 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1', 'herb1_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1', 'herb1_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1', 'herb1_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1',  'herb1_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1', 'herb1_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_herb1',   'herb1_yaw_campfire')); 
			
		herb1 = theGame.GetEntityByTag('herb1_campfire');
		herb1.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		herb1.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb1', 'campfire_dontattach_herb1') )
		{
			herb1.BreakAttachment();
			base_on_roach_position = TraceFloor(herb1.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			herb1.Teleport( base_on_roach_position );
		}
			
		FactsAdd("herb1_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_herb1 )
		{
			Configsw.SetVarValue('swords_campfire_herb1', 'campfire_enable_changes_herb1' , "false" ); 
			enable_changes_herb1 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('herb2_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("herb2_placed_campfire") <= 0 )
		|| enable_changes_herb2 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2', 'herb2_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2', 'herb2_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2', 'herb2_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2',  'herb2_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2', 'herb2_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_herb2',   'herb2_yaw_campfire')); 
			
		herb2 = theGame.GetEntityByTag('herb2_campfire');
		herb2.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		herb2.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_herb2', 'campfire_dontattach_herb2') )
		{
			herb2.BreakAttachment();
			base_on_roach_position = TraceFloor(herb2.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			herb2.Teleport( base_on_roach_position );
		}
			
		FactsAdd("herb2_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_herb2 )
		{
			Configsw.SetVarValue('swords_campfire_herb2', 'campfire_enable_changes_herb2' , "false" ); 
			enable_changes_herb2 = false;
		}
	}
	
	
	
	if ( ( theGame.GetEntityByTag('bolt0_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bolt_placed_campfire") <= 0 )
		|| enable_changes_bolt )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt', 'bolt_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt', 'bolt_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt', 'bolt_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt',  'bolt_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt', 'bolt_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bolt',   'bolt_yaw_campfire')); 
			
		bolt = theGame.GetEntityByTag('bolt0_campfire');
		bolt.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bolt.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bolt', 'campfire_dontattach_bolt') )
		{
			bolt.BreakAttachment();
			base_on_roach_position = TraceFloor(bolt.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bolt.Teleport( base_on_roach_position );
		}
			
		FactsAdd("bolt_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bolt )
		{
			Configsw.SetVarValue('swords_campfire_bolt', 'campfire_enable_changes_bolt' , "false" ); 
			enable_changes_bolt = false;
		}
	}
	
	
	
	if ( ( theGame.GetEntityByTag('bomb1_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bomb1_placed_campfire") <= 0 )
		|| enable_changes_bomb1 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1', 'bomb1_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1', 'bomb1_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1', 'bomb1_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1',  'bomb1_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1', 'bomb1_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb1',   'bomb1_yaw_campfire')); 
			
		bomb1 = theGame.GetEntityByTag('bomb1_campfire');
		bomb1.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bomb1.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb1', 'campfire_dontattach_bomb1') )
		{
			bomb1.BreakAttachment();
			base_on_roach_position = TraceFloor(bomb1.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bomb1.Teleport( base_on_roach_position );
		}
			
		FactsAdd("bomb1_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bomb1 )
		{
			Configsw.SetVarValue('swords_campfire_bomb1', 'campfire_enable_changes_bomb1' , "false" ); 
			enable_changes_bomb1 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('bomb2_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bomb2_placed_campfire") <= 0 )
		|| enable_changes_bomb2 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2', 'bomb2_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2', 'bomb2_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2', 'bomb2_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2',  'bomb2_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2', 'bomb2_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb2',   'bomb2_yaw_campfire')); 
			
		bomb2 = theGame.GetEntityByTag('bomb2_campfire');
		bomb2.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bomb2.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb2', 'campfire_dontattach_bomb2') )
		{
			bomb2.BreakAttachment();
			base_on_roach_position = TraceFloor(bomb2.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bomb2.Teleport( base_on_roach_position );
		}
			
		FactsAdd("bomb2_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bomb2 )
		{
			Configsw.SetVarValue('swords_campfire_bomb2', 'campfire_enable_changes_bomb2' , "false" ); 
			enable_changes_bomb2 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('bomb3_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bomb3_placed_campfire") <= 0 )
		|| enable_changes_bomb3 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3', 'bomb3_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3', 'bomb3_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3', 'bomb3_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3',  'bomb3_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3', 'bomb3_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb3',   'bomb3_yaw_campfire')); 
			
		bomb3 = theGame.GetEntityByTag('bomb3_campfire');
		bomb3.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bomb3.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb3', 'campfire_dontattach_bomb3') )
		{
			bomb3.BreakAttachment();
			base_on_roach_position = TraceFloor(bomb3.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bomb3.Teleport( base_on_roach_position );
		}
			
		FactsAdd("bomb3_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bomb3 )
		{
			Configsw.SetVarValue('swords_campfire_bomb3', 'campfire_enable_changes_bomb3' , "false" ); 
			enable_changes_bomb3 = false;
		}
	}
	
	if ( ( theGame.GetEntityByTag('bomb4_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bomb4_placed_campfire") <= 0 )
		|| enable_changes_bomb4 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4', 'bomb4_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4', 'bomb4_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4', 'bomb4_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4',  'bomb4_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4', 'bomb4_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bomb4',   'bomb4_yaw_campfire')); 
			
		bomb4 = theGame.GetEntityByTag('bomb4_campfire');
		bomb4.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bomb4.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( hide_base || theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bomb4', 'campfire_dontattach_bomb4') )
		{
			bomb4.BreakAttachment();
			base_on_roach_position = TraceFloor(bomb4.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bomb4.Teleport( base_on_roach_position );
		}
			
		FactsAdd("bomb4_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bomb4 )
		{
			Configsw.SetVarValue('swords_campfire_bomb4', 'campfire_enable_changes_bomb4' , "false" ); 
			enable_changes_bomb4 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('bottle1_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("bottle1_placed_campfire") <= 0 )
		|| enable_changes_bottle1 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1', 'bottle1_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1', 'bottle1_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1', 'bottle1_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1',  'bottle1_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1', 'bottle1_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_bottle1',   'bottle1_yaw_campfire')); 
			
		bottle1 = theGame.GetEntityByTag('bottle1_campfire');
		bottle1.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		bottle1.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_bottle1', 'campfire_dontattach_bottle1') )
		{
			bottle1.BreakAttachment();
			base_on_roach_position = TraceFloor(bottle1.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			bottle1.Teleport( base_on_roach_position );
		}
		
		FactsAdd("bottle1_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_bottle1 )
		{
			Configsw.SetVarValue('swords_campfire_bottle1', 'campfire_enable_changes_bottle1' , "false" ); 
			enable_changes_bottle1 = false;
		}
	}
	
	
	
	if ( ( theGame.GetEntityByTag('vial1_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("vial1_placed_campfire") <= 0 )
		|| enable_changes_vial1 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1', 'vial1_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1', 'vial1_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1', 'vial1_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1',  'vial1_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1', 'vial1_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_vial1',   'vial1_yaw_campfire')); 
			
		vial1 = theGame.GetEntityByTag('vial1_campfire');
		vial1.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		vial1.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial1', 'campfire_dontattach_vial1') )
		{
			vial1.BreakAttachment();
			base_on_roach_position = TraceFloor(vial1.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			vial1.Teleport( base_on_roach_position );
		}
		
		FactsAdd("vial1_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_vial1 )
		{
			Configsw.SetVarValue('swords_campfire_vial1', 'campfire_enable_changes_vial1' , "false" ); 
			enable_changes_vial1 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('vial2_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("vial2_placed_campfire") <= 0 )
		|| enable_changes_vial2 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2', 'vial2_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2', 'vial2_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2', 'vial2_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2',  'vial2_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2', 'vial2_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_vial2',   'vial2_yaw_campfire')); 
			
		vial2 = theGame.GetEntityByTag('vial2_campfire');
		vial2.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		vial2.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial2', 'campfire_dontattach_vial2') )
		{
			vial2.BreakAttachment();
			base_on_roach_position = TraceFloor(vial2.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			vial2.Teleport( base_on_roach_position );
		}
		
		FactsAdd("vial2_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_vial2 )
		{
			Configsw.SetVarValue('swords_campfire_vial2', 'campfire_enable_changes_vial2' , "false" ); 
			enable_changes_vial2 = false;
		}
	}
	
	
	if ( ( theGame.GetEntityByTag('vial3_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("vial3_placed_campfire") <= 0 )
		|| enable_changes_vial3 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3', 'vial3_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3', 'vial3_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3', 'vial3_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3',  'vial3_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3', 'vial3_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_vial3',   'vial3_yaw_campfire')); 
			
		vial3 = theGame.GetEntityByTag('vial3_campfire');
		vial3.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		vial3.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial3', 'campfire_dontattach_vial3') )
		{
			vial3.BreakAttachment();
			base_on_roach_position = TraceFloor(vial3.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			vial3.Teleport( base_on_roach_position );
		}
		
		FactsAdd("vial3_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_vial3 )
		{
			Configsw.SetVarValue('swords_campfire_vial3', 'campfire_enable_changes_vial3' , "false" ); 
			enable_changes_vial3 = false;
		}
	}
	
	if ( ( theGame.GetEntityByTag('vial4_campfire') && theGame.GetEntityByTag('base_campfire') && FactsQuerySum("vial4_placed_campfire") <= 0 )
		|| enable_changes_vial4 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			base_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4', 'vial4_pos_x_campfire')); 
			base_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4', 'vial4_pos_y_campfire')); 
			base_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4', 'vial4_pos_z_campfire')); 
			base_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4',  'vial4_roll_campfire')); 
			base_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4', 'vial4_pitch_campfire')); 
			base_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_vial4',   'vial4_yaw_campfire')); 
			
		vial4 = theGame.GetEntityByTag('vial4_campfire');
		vial4.BreakAttachment();
		
		base_on_roach_position.X = 0;             base_on_roach_rotation.Roll = 0;
		base_on_roach_position.Y = 0;             base_on_roach_rotation.Pitch = 0;
		base_on_roach_position.Z = 0;             base_on_roach_rotation.Yaw = 0;
		
		base_on_roach_position.X -= base_pos_x;            base_on_roach_rotation.Roll += base_roll;
		base_on_roach_position.Y += base_pos_y;            base_on_roach_rotation.Pitch += base_pitch;
		base_on_roach_position.Z -= base_pos_z;            base_on_roach_rotation.Yaw += base_yaw;
		
		vial4.CreateAttachment( theGame.GetEntityByTag('base_campfire'),,base_on_roach_position, base_on_roach_rotation );
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_vial4', 'campfire_dontattach_vial4') )
		{
			vial4.BreakAttachment();
			base_on_roach_position = TraceFloor(vial4.GetWorldPosition());
			base_on_roach_position.Z += base_pos_z;
			vial4.Teleport( base_on_roach_position );
		}
		
		FactsAdd("vial4_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" base_placed_campfire "); 
		
		if ( enable_changes_vial4 )
		{
			Configsw.SetVarValue('swords_campfire_vial4', 'campfire_enable_changes_vial4' , "false" ); 
			enable_changes_vial4 = false;
		}
	}
	
}	
	