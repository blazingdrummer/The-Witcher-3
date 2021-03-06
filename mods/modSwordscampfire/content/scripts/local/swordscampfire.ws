function swordscampfire()
{
	var disable_mod											: Bool;
	
	for_possible_additions();
	
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_disable_mod');
	if ( disable_mod ) { return; }
	
	if ( ( thePlayer.GetCurrentStateName()== 'Meditation' || thePlayer.GetCurrentStateName()== 'MeditationWaiting' 
		|| thePlayer.GetCurrentStateName()== 'W3EEMeditation' || thePlayer.GetCurrentStateName()== 'AlchemyBrewing' )
		&& !((W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' )).GetWasUsed() )
	{ 
		if( theInput.IsActionPressed( 'CameraLock' ) && FactsQuerySum("button_focus_pressed")<=0 && FactsQuerySum("enable_campfire_key")<=0 )
		{
			FactsAdd("button_focus_pressed",,1);
			FactsAdd("enable_campfire_key",,-1);
			FactsAdd("key_is_waiting",,1);
		}
	
		FactsAdd("geralt_meditates",,1);
		if ( FactsQuerySum("weapons_left_campfire") <= 0 )
		{
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_use_key') )
			{
				if ( FactsQuerySum("enable_campfire_key") > 0 )
				{
					prepare_for_picnic(true);
					placeweaponscampfire();
					FactsAdd("campfire_ready",,-1);
				}
			}
			else
			{
				prepare_for_picnic(true);
				placeweaponscampfire();
				FactsAdd("campfire_ready",,-1);
			}
		}
	}
	
	if ( thePlayer.GetCurrentStateName()!= 'Meditation' &&  thePlayer.GetCurrentStateName()!= 'MeditationWaiting' 
	  && thePlayer.GetCurrentStateName()!= 'W3EEMeditation' && thePlayer.GetCurrentStateName()!= 'AlchemyBrewing'
		&& FactsQuerySum("geralt_meditates")>0 )
	{
		if ( FactsQuerySum("weapons_left_campfire") <= 0 )
		{
			prepare_for_picnic(false);
			FactsRemove("enable_campfire_key");
			FactsRemove("campfire_ready");
		}
	}
	
	if( FactsQuerySum("weapons_left_campfire") <= 0 )
	{
		if( FactsQuerySum("campfire_ready") > 0 )
		{
			if( theInput.IsActionPressed( 'CameraLock' ) && FactsQuerySum("button_retrieve_pressed")<=0 
			&& ( ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_use_key') && FactsQuerySum("key_is_waiting") <= 0 )
					|| !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_use_key') ) )
			{
				FactsAdd("button_retrieve_pressed",,1);
				leave_weapons();
				
				if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_disable_stuff') )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons_left" ) );
					
				}
				else
				{
					if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_leave_stuff') )
					{
						theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons_and_stuff_left" ) );
					}
					else
					{
						theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons_left" ) );
					}
				}
				
			}
		}
	}
		
	if( FactsQuerySum("weapons_left_campfire") > 0 )
	{
		if( FactsQuerySum("geralt_meditates") <= 0 )
		{
			if( theInput.IsActionPressed( 'CameraLock' ) && FactsQuerySum("button_retrieve_pressed")<=0 )
			{
				FactsAdd("button_retrieve_pressed",,1);
				play_anima_campfire();
			}
		}
	}
	
	if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_reset_left') )
	{
		FactsAdd("restore_weapons_menu",,1);
		retrieve_weapons();
		theGame.GetInGameConfigWrapper().SetVarValue( 'swords_campfire', 'swords_campfire_reset_left', "false" ); 
	}
	
	if( FactsQuerySum("stop_action_campfire") <= 0 && FactsQuerySum("stop_action_campfire_take") > 0 )
	{
		FactsRemove("stop_action_campfire_take");
		thePlayer.PlayerStopAction( 07 );
		FactsAdd("animation_campfire_take_weapons",,1);
	}
	
	if( FactsQuerySum("animation_campfire_take_weapons") > 0 )
	{
		retrieve_weapons();
		FactsRemove("animation_campfire_take_weapons");
	}
	
}	

function prepare_for_picnic( meditation : bool )
{
	var swordsteel, swordsilver, scabsteel, scabsilver,xbow,altmodel				: CEntity;
	var steelcomp, silvercomp,scabbardscomp, scabbardscompsteel,scabbardscompsilver	: CDrawableComponent;
	var sw 																			: int; 
	var n, lenght 																	: Float; 
	var steelid,silverid, xid   													: SItemUniqueId;
	var scabbards		 															: array<SItemUniqueId>; 
	var steelscabcopy,silverscabcopy,steelcopy,silvercopy,xbowcopy,xbowtagged		: CEntity;
	var comp 																		: CMeshComponent;
	var meshComponent 																: CMeshComponent;
	var pos 																		: Vector;
	var dummy																		: CEntity;
	var exclude_xbow,exclude_scabs													: Bool;

	if ( !meditation ) { FactsRemove("campfire_check_weapons_1"); }
	if ( FactsQuerySum ("campfire_check_weapons_1") > 0 ) { return; }
	FactsAdd("campfire_check_weapons_1",,1);
	
	////////// XBOW //////////////
	
	exclude_xbow = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_exclude_xbow');
	
	if ( !exclude_xbow && meditation )
	{
		
		if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, xid) )
		{	
			xbow = thePlayer.GetInventory().GetItemEntityUnsafe(xid);	
			
			if ( !theGame.GetEntityByTag('xbow_campfire') )
			{
				xbowcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(xbow.GetReadableName(),true ),
				thePlayer.GetWorldPosition()-thePlayer.GetWorldUp()*2, thePlayer.GetWorldRotation()  );
				xbowcopy.AddTag('xbow_campfire');	
			}
			
			if ( theGame.GetEntityByTag('xbow_on_roach_invmod') )
			{
				dummy = theGame.GetEntityByTag('xbow_on_roach_invmod');
				comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
				comp.SetVisible(false);
			}
		}
		else 
		{ 	
			theGame.GetEntityByTag('xbow_campfire').Destroy(); 
			FactsRemove("xbow_comps_placed_campfire");
		}
		
		
		
		if( !thePlayer.GetInventory().IsItemHeld(xid) || thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponHolster' 
			&& theGame.GetEntityByTag('xbow_campfire') ) 
		{
			if ( xbow.GetReadableName() != theGame.GetEntityByTag('xbow_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('xbow_campfire').Destroy();
				FactsRemove("xbow_comps_placed_campfire");
			}	
			
			xbow.SetHideInGame(false);
			xbow.SetHideInGame(true);
		}
		else
		{
			theGame.GetEntityByTag('xbow_campfire').Destroy();
			FactsRemove("xbow_comps_placed_campfire");
			xbow.SetHideInGame(false);
		}
	}
	
	
	if ( !meditation )
	{
		if ( !thePlayer.GetInventory().HasItem( 'ghost_of_the_sun' ) )
		{  
			if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, xid) )
			{	
				xbow = thePlayer.GetInventory().GetItemEntityUnsafe(xid);
				xbow.SetHideInGame(false);  
			}
		}
		
		theGame.GetEntityByTag('xbow_campfire').Destroy();
		FactsRemove("xbow_comps_placed_campfire");
		
		if ( theGame.GetEntityByTag('xbow_on_roach_invmod') )
		{
			dummy = theGame.GetEntityByTag('xbow_on_roach_invmod');
			comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
			comp.SetVisible(true);
		}
		//theGame.witcherLog.AddMessage("abort meditation"); 
	}
	
	
	
	
	
	////////// SWORDS /////////////
	
	//// STEEL
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid) )
	{
		swordsteel = thePlayer.GetInventory().GetItemEntityUnsafe(steelid);
		steelcomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(steelid)).GetMeshComponent());
		
		if ( meditation )
		{
			if(!thePlayer.GetInventory().IsItemMounted(steelid) && !thePlayer.GetInventory().IsItemHeld(steelid) )  
				{  thePlayer.GetInventory().MountItem( steelid, false, false );  }
			
			if ( steelcomp.IsVisible() && !thePlayer.GetInventory().IsItemHeld(steelid) ) 
			{ 
				steelcomp.SetVisible(false); 
			}	
			if ( !steelcomp.IsVisible() && thePlayer.GetInventory().IsItemHeld(steelid) ) 
			{ 
				steelcomp.SetVisible(true); 
			}	
			
			if ( !theGame.GetEntityByTag('steel_sword_campfire') )
			{
				steelcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(swordsteel.GetReadableName(),true ),
				thePlayer.GetWorldPosition()-thePlayer.GetWorldUp()*2, thePlayer.GetWorldRotation()  );
				steelcopy.AddTag('steel_sword_campfire');
			}
			
			if ( swordsteel.GetReadableName() != theGame.GetEntityByTag('steel_sword_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('steel_sword_campfire').Destroy();
				theGame.GetEntityByTag('steel_scab_campfire').Destroy();
				FactsRemove("steel_comps_placed_campfire");
			}
			
			if ( theGame.GetEntityByTag('steel_sword_on_roach_invmod') )
			{
				dummy = theGame.GetEntityByTag('steel_sword_on_roach_invmod');
				comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
				comp.SetVisible(false);
			}
		}
		else 
		{
			if ( !steelcomp.IsVisible() ) 	
			{ 
				steelcomp.SetVisible(true);
			}
			
			theGame.GetEntityByTag('steel_sword_campfire').Destroy(); 
			theGame.GetEntityByTag('steel_scab_campfire').Destroy(); 
			FactsRemove("steel_comps_placed_campfire");
			
			if ( theGame.GetEntityByTag('steel_sword_on_roach_invmod') )
			{
				dummy = theGame.GetEntityByTag('steel_sword_on_roach_invmod');
				comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
				comp.SetVisible(true);
			}
		}
		
	}
	else 
	{ 
		theGame.GetEntityByTag('steel_sword_campfire').Destroy(); 
		theGame.GetEntityByTag('steel_scab_campfire').Destroy(); 
		FactsRemove("steel_comps_placed_campfire");
	}
	
	
	//// SILVER
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid) )
	{
		swordsilver = thePlayer.GetInventory().GetItemEntityUnsafe(silverid);
		silvercomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		if ( meditation )
		{
			if(!thePlayer.GetInventory().IsItemMounted(silverid) && !thePlayer.GetInventory().IsItemHeld(silverid) )  
				{  thePlayer.GetInventory().MountItem( silverid, false, false );  }
			
			if ( silvercomp.IsVisible() && !thePlayer.GetInventory().IsItemHeld(silverid) ) 
			{ 
				silvercomp.SetVisible(false); 
			}	
			if ( !silvercomp.IsVisible() && thePlayer.GetInventory().IsItemHeld(silverid) ) 
			{ 
				silvercomp.SetVisible(true); 
			}	
			
			if ( !theGame.GetEntityByTag('silver_sword_campfire') )
			{
				silvercopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(swordsilver.GetReadableName(),true ),
				thePlayer.GetWorldPosition()-thePlayer.GetWorldUp()*2, thePlayer.GetWorldRotation()  );
				silvercopy.AddTag('silver_sword_campfire');
			}
			
			if ( swordsilver.GetReadableName() != theGame.GetEntityByTag('silver_sword_campfire').GetReadableName() )
			{
				theGame.GetEntityByTag('silver_sword_campfire').Destroy();
				theGame.GetEntityByTag('silver_scab_campfire').Destroy();
				FactsRemove("silver_comps_placed_campfire");
			}
			
			if ( theGame.GetEntityByTag('silver_sword_on_roach_invmod') )
			{
				dummy = theGame.GetEntityByTag('silver_sword_on_roach_invmod');
				comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
				comp.SetVisible(false);
			}
		}
		else 
		{
			if ( !silvercomp.IsVisible() ) 	
			{ 
				silvercomp.SetVisible(true);
			}
			
			theGame.GetEntityByTag('silver_sword_campfire').Destroy(); 
			theGame.GetEntityByTag('silver_scab_campfire').Destroy(); 
			FactsRemove("silver_comps_placed_campfire");
			
			if ( theGame.GetEntityByTag('silver_sword_on_roach_invmod') )
			{
				dummy = theGame.GetEntityByTag('silver_sword_on_roach_invmod');
				comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
				comp.SetVisible(true);
			}
		}		
		
	}
	else 
	{ 
		theGame.GetEntityByTag('silver_sword_campfire').Destroy(); 
		theGame.GetEntityByTag('silver_scab_campfire').Destroy(); 
		FactsRemove("silver_comps_placed_campfire");
	}
	
	
	///////// SCABBARDS /////////////
	
	exclude_scabs = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_exclude_scabs');

	if ( !exclude_scabs )
	{
		thePlayer.GetInventory().GetAllItems(scabbards);	
		for(sw=0; sw<scabbards.Size(); sw+=1)
		{	
			if ( thePlayer.GetInventory().GetItemCategory(scabbards[sw]) == 'steel_scabbards' )
			{
				if ( !theGame.GetEntityByTag('steel_scab_campfire') && meditation )
				{
					steelscabcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw]).GetReadableName(),true ),
					thePlayer.GetWorldPosition()-thePlayer.GetWorldUp()*2, thePlayer.GetWorldRotation()  );
					meshComponent = ( CMeshComponent ) steelscabcopy.GetComponentByClassName( 'CMeshComponent' );
					meshComponent.SetScale( Vector( 1.03, 1.03, 1.03 ) );
					steelscabcopy.AddTag('steel_scab_campfire');
					//theGame.witcherLog.AddMessage(thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw]).GetReadableName()); 
				}
				
				scabbardscompsteel = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw])).GetMeshComponent());
				if ( scabbardscompsteel.IsVisible() && meditation ) 	
				{ 
					scabbardscompsteel.SetVisible(false); 	
				}
				
				if ( !scabbardscompsteel.IsVisible() && !meditation ) 	
				{ 
					scabbardscompsteel.SetVisible(true); 	
				}
				
				if ( theGame.GetEntityByTag('steel_scab_on_roach_invmod') && meditation )
				{
					dummy = theGame.GetEntityByTag('steel_scab_on_roach_invmod');
					comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
					comp.SetVisible(false);
				}
				
				if ( theGame.GetEntityByTag('steel_scab_on_roach_invmod') && !meditation )
				{
					dummy = theGame.GetEntityByTag('steel_scab_on_roach_invmod');
					comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
					comp.SetVisible(true);
				}
			}
			else if ( thePlayer.GetInventory().GetItemCategory(scabbards[sw]) == 'silver_scabbards' )
			{
				if ( !theGame.GetEntityByTag('silver_scab_campfire') && meditation )
				{
					silverscabcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw]).GetReadableName(),true ),
					thePlayer.GetWorldPosition()-thePlayer.GetWorldUp()*2, thePlayer.GetWorldRotation()  );
					meshComponent = ( CMeshComponent ) silverscabcopy.GetComponentByClassName( 'CMeshComponent' );
					meshComponent.SetScale( Vector( 1.03, 1.03, 1.03 ) );
					silverscabcopy.AddTag('silver_scab_campfire');
				}
				
				scabbardscompsilver = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw])).GetMeshComponent());
				if ( scabbardscompsilver.IsVisible() && meditation ) 	
				{ 
					scabbardscompsilver.SetVisible(false); 	
				}
				
				if ( !scabbardscompsilver.IsVisible() && !meditation ) 	
				{ 
					scabbardscompsilver.SetVisible(true); 	
				}
				
				if ( theGame.GetEntityByTag('silver_scab_on_roach_invmod') && meditation )
				{
					dummy = theGame.GetEntityByTag('silver_scab_on_roach_invmod');
					comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
					comp.SetVisible(false);
				}
				
				if ( theGame.GetEntityByTag('silver_scab_on_roach_invmod') && !meditation )
				{
					dummy = theGame.GetEntityByTag('silver_scab_on_roach_invmod');
					comp = (CMeshComponent)dummy.GetComponentByClassName( 'CMeshComponent' );
					comp.SetVisible(true);
				}
			}
		}
	}
}



function placeweaponscampfire()
{

	var enable_changes_swords,enable_changes_scabs,enable_changes_xbow,disable_mod				: Bool;	
	var dont_align_xbow,dont_align_swords                                                       : Bool;	
	var Configsw 																				: CInGameConfigWrapper;
	var steel_pos_x,steel_pos_y,steel_pos_z   													: Float;
	var silver_pos_x,silver_pos_y,silver_pos_z   												: Float;
	var steel_scab_pos_x,steel_scab_pos_y,steel_scab_pos_z  									: Float;
	var silver_scab_pos_x,silver_scab_pos_y,silver_scab_pos_z  									: Float;
	var dummy																					: CEntity;
	var steel_roll, steel_pitch, steel_yaw 														: Float; 
	var silver_roll, silver_pitch, silver_yaw 													: Float; 
	var steel_scab_roll, steel_scab_pitch, steel_scab_yaw										: Float; 
	var silver_scab_roll,silver_scab_pitch,silver_scab_yaw										: Float; 
	var steel_on_roach,silver_on_roach															: CEntity;
	var steel_scab_on_roach,silver_scab_on_roach												: CEntity;
	var steel_on_roach_position,silver_on_roach_position										: Vector;
	var steel_on_roach_rotation,silver_on_roach_rotation 										: EulerAngles;
	var steel_scab_on_roach_position,silver_scab_on_roach_position 								: Vector;
	var steel_scab_on_roach_rotation,silver_scab_on_roach_rotation 								: EulerAngles;
	var meshComponent 																			: CMeshComponent;
	var steelid,steelid_0,silverid,silverid_0	  												: SItemUniqueId;
	var items 																					: array<SItemUniqueId>;
	var i 																						: Float;
	var z 																						: Int;
	var dummies																					: array<CEntity>;
	
	var xbow_roll, xbow_pitch, xbow_yaw 														: Float; 
	var xbow_pos_x,xbow_pos_y,xbow_pos_z   														: Float;
	var xbow_on_roach_position																	: Vector;
	var xbow_on_roach_rotation							 										: EulerAngles;
	var xbow_on_roach 																			: CEntity;
	var pos																						: Vector;
	var altmodel_boat																			: CEntity;
	var vehicle 																				: CVehicleComponent;
	var entities 																				: array<CGameplayEntity>;
	var boat 																					: CEntity;
	
	var pos_steel_start : Vector;
	var pos_steel_test : float;
	var pos_steel_end : Vector;
	var steel_heights : array< float >; 
	var pos_silver_start : Vector;
	var pos_silver_end : Vector;
	var pos_silver_test : float;
	var silver_heights : array< float >; 
	var pos_xbow_start : Vector;
	var pos_xbow_end : Vector;
	var n :   Int ;
	
	
	if ( theInput.IsActionPressed( 'SteelSword' ) && FactsQuerySum("pressed_swords_campfire")<=0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
		if ( StringToInt( Configsw.GetVarValue('swords_campfire_swords', 'preset_campfire_swords') ) < 3 )
		{
			Configsw.ApplyGroupPreset('swords_campfire_swords', StringToInt( Configsw.GetVarValue('swords_campfire_swords', 'preset_campfire_swords') ) + 1 );
		}
		else 
		{
			Configsw.ApplyGroupPreset('swords_campfire_swords', 0 );
		}
		theGame.GetInGameConfigWrapper().SetVarValue( 'swords_campfire_swords', 'campfire_enable_changes', "true" ); 
		FactsAdd("pressed_swords_campfire",,1);
		FactsRemove("campfire_place_weapons_1");
	}

	if ( theInput.IsActionPressed( 'SilverSword' ) && FactsQuerySum("pressed_xbow_campfire")<=0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
		if ( StringToInt( Configsw.GetVarValue('swords_campfire_xbow', 'preset_campfire_xbow') ) < 5 )
		{
			Configsw.ApplyGroupPreset('swords_campfire_xbow', StringToInt( Configsw.GetVarValue('swords_campfire_xbow', 'preset_campfire_xbow') ) + 1 );
		}
		else 
		{
			Configsw.ApplyGroupPreset('swords_campfire_xbow', 0 );
		}
		theGame.GetInGameConfigWrapper().SetVarValue( 'swords_campfire_xbow', 'campfire_enable_changes_xbow', "true" ); 
		FactsAdd("pressed_xbow_campfire",,1);
		FactsRemove("campfire_place_weapons_1");
	}
	
	if ( FactsQuerySum ("campfire_place_weapons_1") > 0 ) { return; }
	FactsAdd("campfire_place_weapons_1",,1);
	
	enable_changes_swords = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_swords', 'campfire_enable_changes');
	enable_changes_scabs = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_scabbards', 'campfire_enable_changes_scabs');
	enable_changes_xbow = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_xbow', 'campfire_enable_changes_xbow');
	
	/// XBOW
	if ( ( theGame.GetEntityByTag('xbow_campfire') && FactsQuerySum("xbow_comps_placed_campfire") <= 0 )
		|| enable_changes_xbow )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			xbow_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow', 'xbow_pos_x_campfire')); 
			xbow_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow', 'xbow_pos_y_campfire')); 
			xbow_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow', 'xbow_pos_z_campfire')); 
			xbow_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow',  'xbow_roll_campfire')); 
			xbow_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow', 'xbow_pitch_campfire')); 
			xbow_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_xbow',   'xbow_yaw_campfire')); 
			
		xbow_on_roach = theGame.GetEntityByTag('xbow_campfire');
		xbow_on_roach.BreakAttachment();
		
		xbow_on_roach_position.X = 0;             xbow_on_roach_rotation.Roll = 0;
		xbow_on_roach_position.Y = 0;             xbow_on_roach_rotation.Pitch = 0;
		xbow_on_roach_position.Z = 0;             xbow_on_roach_rotation.Yaw = 0;
		
		xbow_on_roach_position.X += xbow_pos_x;            xbow_on_roach_rotation.Roll += xbow_roll;
		xbow_on_roach_position.Y += xbow_pos_y;            xbow_on_roach_rotation.Pitch += xbow_pitch;
		xbow_on_roach_position.Z += xbow_pos_z;            xbow_on_roach_rotation.Yaw += xbow_yaw;
		
		xbow_on_roach.CreateAttachment( thePlayer,,xbow_on_roach_position, xbow_on_roach_rotation );
		
		dont_align_xbow = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_xbow', 'xbow_campfire_align');
		
		if ( !dont_align_xbow )
		{
			pos_xbow_start = xbow_on_roach.GetWorldPosition(); 		        		// start
			pos_xbow_start = TraceFloor(pos_xbow_start);
			
			pos_xbow_end = xbow_on_roach.GetWorldPosition() + xbow_on_roach.GetWorldUp()*0.4; 		        		// end
			pos_xbow_end = TraceFloor(pos_xbow_end);
			
			xbow_on_roach.BreakAttachment();
			xbow_on_roach_rotation.Roll -= adjust_angle_campfire( pos_xbow_end, pos_xbow_start );
			xbow_on_roach.CreateAttachment( thePlayer,,xbow_on_roach_position, xbow_on_roach_rotation );
		
			xbow_on_roach.BreakAttachment();
			xbow_on_roach_position = TraceFloor(xbow_on_roach.GetWorldPosition());
			xbow_on_roach_position.Z += 0.05;
			xbow_on_roach.Teleport( xbow_on_roach_position );
		}
		
		FactsAdd("xbow_comps_placed_campfire",,-1);
		//theGame.witcherLog.AddMessage(" xbow_comps_placed_campfire "); 
		
		if ( enable_changes_xbow )
		{
			Configsw.SetVarValue( 'swords_campfire_xbow', 'campfire_enable_changes_xbow', "false" ); 
			enable_changes_xbow = false;
		}
	}
	
	
	/// STEEL
	if ( ( theGame.GetEntityByTag('steel_sword_campfire') && FactsQuerySum("steel_comps_placed_campfire")<=0 )
		|| enable_changes_swords || enable_changes_scabs )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			steel_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_pos_x_campfire')); 
			steel_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_pos_y_campfire')); 
			steel_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_pos_z_campfire')); 
			steel_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_roll_campfire')); 
			steel_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_pitch_campfire')); 
			steel_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'steel_yaw_campfire')); 
			
			steel_scab_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_pos_x_campfire')); 
			steel_scab_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_pos_y_campfire')); 
			steel_scab_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_pos_z_campfire')); 
			steel_scab_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_roll_campfire')); 
			steel_scab_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_pitch_campfire')); 
			steel_scab_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'steel_scab_yaw_campfire')); 
		
		steel_on_roach = theGame.GetEntityByTag('steel_sword_campfire');
		steel_on_roach.BreakAttachment();
		
		steel_on_roach_position.X = 0;             steel_on_roach_rotation.Roll = 0;
		steel_on_roach_position.Y = 0;             steel_on_roach_rotation.Pitch = 0;
		steel_on_roach_position.Z = 0;             steel_on_roach_rotation.Yaw = 0;
		
		steel_on_roach_position.X += steel_pos_x;            steel_on_roach_rotation.Roll += steel_roll;
		steel_on_roach_position.Y += steel_pos_y;            steel_on_roach_rotation.Pitch += steel_pitch;
		steel_on_roach_position.Z += steel_pos_z;            steel_on_roach_rotation.Yaw += steel_yaw;
		
		steel_on_roach.CreateAttachment( thePlayer,,steel_on_roach_position, steel_on_roach_rotation );
			
		dont_align_swords = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_swords', 'swords_campfire_align');
		
		if ( !dont_align_swords )
		{
			pos_steel_start = steel_on_roach.GetWorldPosition();// - steel_on_roach.GetWorldUp()*0.25; 												// initial
			pos_steel_start = TraceFloor(pos_steel_start);													
			
			
			steel_heights.Clear();
			for(i=0.1; i<=1.1; i+=0.1)
			{
				pos_steel_end = steel_on_roach.GetWorldPosition() + steel_on_roach.GetWorldUp()*i;
				pos_steel_end = TraceFloor(pos_steel_end);
				
				pos_steel_test = adjust_angle_campfire( pos_steel_end, pos_steel_start );
				steel_heights.PushBack(pos_steel_test);
			}
			
			steel_on_roach.BreakAttachment();
			steel_on_roach_rotation.Pitch += steel_heights[ ArrayFindMaxF(steel_heights) ];
			steel_on_roach.CreateAttachment( thePlayer,,steel_on_roach_position, steel_on_roach_rotation );
						
			steel_on_roach.BreakAttachment();
			steel_on_roach_position = TraceFloor(steel_on_roach.GetWorldPosition());
			steel_on_roach.Teleport( steel_on_roach_position );
		}
		
		/// STEEL SCABBARD
		if ( theGame.GetEntityByTag('steel_scab_campfire') )
		{
			steel_scab_on_roach = theGame.GetEntityByTag('steel_scab_campfire');
			steel_scab_on_roach.BreakAttachment();
			
			steel_scab_on_roach_position.X = 0;           steel_scab_on_roach_rotation.Roll = 0;
			steel_scab_on_roach_position.Y = 0;           steel_scab_on_roach_rotation.Pitch = 0;
			steel_scab_on_roach_position.Z = 0;           steel_scab_on_roach_rotation.Yaw = 0;
											
			steel_scab_on_roach_position.X += 0.61;       steel_scab_on_roach_rotation.Roll += -24.3; 
			steel_scab_on_roach_position.Y -= 0.09;       steel_scab_on_roach_rotation.Pitch += 180;
			steel_scab_on_roach_position.Z -= -1.71;      steel_scab_on_roach_rotation.Yaw += 14.4 + 0.41;   
			
			steel_scab_on_roach_position.X += steel_scab_pos_x;      steel_scab_on_roach_rotation.Roll += steel_scab_roll; 
			steel_scab_on_roach_position.Y -= steel_scab_pos_y;      steel_scab_on_roach_rotation.Pitch += steel_scab_pitch;
			steel_scab_on_roach_position.Z -= steel_scab_pos_z;      steel_scab_on_roach_rotation.Yaw += steel_scab_yaw;   
			
			steel_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('steel_sword_campfire'),,steel_scab_on_roach_position, steel_scab_on_roach_rotation );
		}
		
		FactsAdd("steel_comps_placed_campfire",,-1);
		//FactsAdd("should_enable_changes_swords_campfire",,1);
		//theGame.witcherLog.AddMessage(" steel_comps_placed_campfire "); 
	}
	
	
	/// SILVER
	if ( ( theGame.GetEntityByTag('silver_sword_campfire') && FactsQuerySum("silver_comps_placed_campfire")<=0 )
		|| enable_changes_swords || enable_changes_scabs )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			silver_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_pos_x_campfire')); 
			silver_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_pos_y_campfire')); 
			silver_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_pos_z_campfire')); 
			silver_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_roll_campfire')); 
			silver_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_pitch_campfire')); 
			silver_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_swords', 'silver_yaw_campfire')); 
			
			silver_scab_pos_x = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_pos_x_campfire')); 
			silver_scab_pos_y = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_pos_y_campfire')); 
			silver_scab_pos_z = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_pos_z_campfire')); 
			silver_scab_roll = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_roll_campfire')); 
			silver_scab_pitch = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_pitch_campfire')); 
			silver_scab_yaw = StringToFloat( Configsw.GetVarValue('swords_campfire_scabbards', 'silver_scab_yaw_campfire')); 
		
		silver_on_roach = theGame.GetEntityByTag('silver_sword_campfire');
		silver_on_roach.BreakAttachment();
		
		silver_on_roach_position.X = 0;             silver_on_roach_rotation.Roll = 0;
		silver_on_roach_position.Y = 0;             silver_on_roach_rotation.Pitch = 0;
		silver_on_roach_position.Z = 0;             silver_on_roach_rotation.Yaw = 0;
		
		silver_on_roach_position.X += silver_pos_x;            silver_on_roach_rotation.Roll += silver_roll;
		silver_on_roach_position.Y += silver_pos_y;            silver_on_roach_rotation.Pitch += silver_pitch;
		silver_on_roach_position.Z += silver_pos_z;            silver_on_roach_rotation.Yaw += silver_yaw;
		
		silver_on_roach.CreateAttachment( thePlayer,,silver_on_roach_position, silver_on_roach_rotation );
		
		dont_align_swords = theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_swords', 'swords_campfire_align');
		
		if ( !dont_align_swords )
		{
			pos_silver_start = silver_on_roach.GetWorldPosition();// - silver_on_roach.GetWorldUp()*0.25; 												// initial
			pos_silver_start = TraceFloor(pos_silver_start);													
			
			silver_heights.Clear();
			for(i=0.1; i<=1.1; i+=0.1)
			{
				pos_silver_end = silver_on_roach.GetWorldPosition() + silver_on_roach.GetWorldUp()*i;
				pos_silver_end = TraceFloor(pos_silver_end);
				
				pos_silver_test = adjust_angle_campfire( pos_silver_end, pos_silver_start );
				silver_heights.PushBack(pos_silver_test);
			}
			
			silver_on_roach.BreakAttachment();
			silver_on_roach_rotation.Pitch += silver_heights[ ArrayFindMaxF(silver_heights) ];
			silver_on_roach.CreateAttachment( thePlayer,,silver_on_roach_position, silver_on_roach_rotation );
						
			silver_on_roach.BreakAttachment();
			silver_on_roach_position = TraceFloor(silver_on_roach.GetWorldPosition());
			silver_on_roach.Teleport( silver_on_roach_position );
		}
		
		/// SILVER SCABBARD
		if ( theGame.GetEntityByTag('silver_scab_campfire') )
		{
			silver_scab_on_roach = theGame.GetEntityByTag('silver_scab_campfire');
			silver_scab_on_roach.BreakAttachment();
			
			silver_scab_on_roach_position.X = 0;           silver_scab_on_roach_rotation.Roll = 0;
			silver_scab_on_roach_position.Y = 0;           silver_scab_on_roach_rotation.Pitch = 0;
			silver_scab_on_roach_position.Z = 0;           silver_scab_on_roach_rotation.Yaw = 0;
											
			silver_scab_on_roach_position.X += 0.61 + 0.025;       silver_scab_on_roach_rotation.Roll += -24.3 - 5.5;
			silver_scab_on_roach_position.Y -= 0.09 - 0.1;       silver_scab_on_roach_rotation.Pitch += 180 - 1.5; ;
			silver_scab_on_roach_position.Z -= -1.71 + 0.07;      silver_scab_on_roach_rotation.Yaw += 14.4 + 4;
			
			silver_scab_on_roach_position.X += silver_scab_pos_x;      silver_scab_on_roach_rotation.Roll += silver_scab_roll; 
			silver_scab_on_roach_position.Y -= silver_scab_pos_y;      silver_scab_on_roach_rotation.Pitch += silver_scab_pitch;
			silver_scab_on_roach_position.Z -= silver_scab_pos_z;      silver_scab_on_roach_rotation.Yaw += silver_scab_yaw;   
			
			silver_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('silver_sword_campfire'),,silver_scab_on_roach_position, silver_scab_on_roach_rotation );
		}
		
		FactsAdd("silver_comps_placed_campfire",,-1);
		//FactsAdd("should_enable_changes_swords_campfire",,1);
		//theGame.witcherLog.AddMessage(" silver_comps_placed_campfire "); 
	}
	
	if ( enable_changes_swords || enable_changes_scabs )
	{
		Configsw.SetVarValue( 'swords_campfire_swords', 'campfire_enable_changes', "false" ); 
		Configsw.SetVarValue( 'swords_campfire_scabbards', 'campfire_enable_changes_scabs', "false" ); 
		
		enable_changes_swords = false;
		enable_changes_scabs = false;
	}
}	
	
function adjust_angle_campfire( from, to : Vector) : float
{
	var slopeFlat	: Vector;
	var slope		: Vector;
	var angle		: float;

	slope		= VecNormalize( from - to );
	slopeFlat	= slope;
	slopeFlat.Z	= 0.0f;
	slopeFlat	= VecNormalize( slopeFlat );
	angle		= AngleNormalize180( VecGetAngleBetween ( slope, slopeFlat ) );
	if( slope.Z < 0.0f )
	{
		angle *= -1.0f;
	}
	return angle;
}



function leave_weapons()
{
	var silverid, steelid, xid	  						: SItemUniqueId;
	
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid) )
	{
		thePlayer.GetInventory().AddItemTag(silverid, 'NoShow');
		thePlayer.GetInventory().AddItemTag(silverid, 'Quest');
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(silverid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
	}
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid) )
	{
		thePlayer.GetInventory().AddItemTag(steelid, 'NoShow');
		thePlayer.GetInventory().AddItemTag(steelid, 'Quest');
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(steelid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
	}
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, xid) && !theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_exclude_xbow') )
	{
		thePlayer.GetInventory().AddItemTag(xid, 'NoShow');
		thePlayer.GetInventory().AddItemTag(xid, 'Quest');
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(xid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
	}
	FactsAdd("weapons_left_campfire",,-1);
	if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_leave_stuff') )
	{
		FactsAdd("stuff_left_campfire",,-1);
	}
}

function retrieve_weapons()
{
	var items 																	: array<SItemUniqueId>;
	var i 																		: Int;
	
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if ( (  GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSilverWeapon') 
				 || GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSteelWeapon')
				 || GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'crossbow')
				 )
				&& GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'Quest')  
				&& GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') 
			   )
			{
					GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
					GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		
		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'Quest') && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow')  )
			{
				if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSilverWeapon') )
				{
					thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
					thePlayer.GetInventory().RemoveItemTag(items[i], 'Quest');
					if ( !GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SilverSword) )
					{    thePlayer.EquipItem(items[i]);    }
				}
				if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSteelWeapon') )
				{
					thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
					thePlayer.GetInventory().RemoveItemTag(items[i], 'Quest');
					if ( !GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SteelSword) )
					{    thePlayer.EquipItem(items[i]);    }
				}
				if ( thePlayer.GetInventory().ItemHasTag(items[i], 'crossbow') )
				{
					thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
					thePlayer.GetInventory().RemoveItemTag(items[i], 'Quest');
					if ( !GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_RangedWeapon) )
					{    thePlayer.EquipItem(items[i]);    }
				}
			}
		}
		
		FactsRemove("weapons_left_campfire");
		FactsRemove("stuff_left_campfire");
		FactsRemove("enable_campfire_key");
		FactsRemove("campfire_ready");
		
		prepare_for_picnic(false);
		prepare_stuff_for_picnic(false);
		
		
		if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire_base', 'campfire_disable_stuff') ) 
		{
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons_taken" ) );
			
		}
		else
		{
			if ( theGame.GetInGameConfigWrapper().GetVarValue('swords_campfire', 'swords_campfire_leave_stuff') )
			{
				theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons__and_stuff_taken" ) );
			}
			else
			{
				theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "swords_campfire_weapons_taken" ) );
			}
		}
		
		
}

/*
function play_anima_campfire()
{
	if ( 	VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('silver_sword_campfire').GetWorldPosition() ) <1.5
		||  VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('steel_sword_campfire').GetWorldPosition() ) <1.5
		||  VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('xbow_campfire').GetWorldPosition() ) <1.5
		||  FactsQuerySum("restore_weapons_menu") > 0
		)
	{
		thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_loot_ground_start',0.5,1);
		FactsAdd("animation_campfire",,2);
		FactsAdd("animation_campfire_take_weapons",,3);
	}
}
*/

function play_anima_campfire()
{
	if ( 	VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('silver_sword_campfire').GetWorldPosition() ) <1.5
		||  VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('steel_sword_campfire').GetWorldPosition() ) <1.5
		||  VecDistance( GetWitcherPlayer().GetWorldPosition(), theGame.GetEntityByTag('xbow_campfire').GetWorldPosition() ) <1.5
		||  FactsQuerySum("restore_weapons_menu") > 0
		)
	{
		thePlayer.PlayerStartAction(07);
		FactsAdd("stop_action_campfire",,2);
		FactsAdd("stop_action_campfire_take",,3);
	}
}

