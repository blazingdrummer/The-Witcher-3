
function swordsonroach()
{
	var enable_changes,front_bone,disable_mod,reset_mod,enable_changes_scabs	: Bool;	
	var Configsw 																: CInGameConfigWrapper;
	var steel_pos_x,steel_pos_y,steel_pos_z   									: Float;
	var silver_pos_x,silver_pos_y,silver_pos_z   								: Float;
	var steel_scab_pos_x,steel_scab_pos_y,steel_scab_pos_z  					: Float;
	var silver_scab_pos_x,silver_scab_pos_y,silver_scab_pos_z  					: Float;
	var dummy																	: CEntity;
	var steel_roll, steel_pitch, steel_yaw 										: Float; 
	var silver_roll, silver_pitch, silver_yaw 									: Float; 
	var steel_scab_roll, steel_scab_pitch, steel_scab_yaw						: Float; 
	var silver_scab_roll,silver_scab_pitch,silver_scab_yaw						: Float; 
	var steel_on_roach,silver_on_roach											: CEntity;
	var steel_scab_on_roach,silver_scab_on_roach								: CEntity;
	var steel_on_roach_position,silver_on_roach_position						: Vector;
	var steel_on_roach_rotation,silver_on_roach_rotation 						: EulerAngles;
	var steel_scab_on_roach_position,silver_scab_on_roach_position 				: Vector;
	var steel_scab_on_roach_rotation,silver_scab_on_roach_rotation 				: EulerAngles;
	var meshComponent 															: CMeshComponent;
	var steelid,steelid_0,silverid,silverid_0	  								: SItemUniqueId;
	var items 																	: array<SItemUniqueId>;
	var i 																		: Int;
	var dummies																	: array<CEntity>;
	
	//boneName = 'r_shoulder';
	//boneName = 'spine3';
	//boneName = 'pelvis';
	
	//boneName = 'spine2';
	//boneName = 'spine1';
	
	enable_changes = false;
	enable_changes_scabs = false;
	
	reset_mod = false;
	reset_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'reset_mod_swor');
	if ( reset_mod ) 
	{ 
		FactsAdd ("equip_silver_on_geralt",,2);
		FactsAdd ("equip_steel_on_geralt",,2);
		
		theGame.GetInGameConfigWrapper().SetVarValue( 'swordsonroach', 'reset_mod_swor', "false" ); 
		reset_mod = false;
	}
	
	enable_changes = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'enable_changes');
	enable_changes_scabs = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach_scabbards', 'enable_changes_scabbards');
	
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }
	front_bone = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'front_bone');


	if ( !thePlayer.GetHorseWithInventory() && FactsQuerySum("checking_horse")<=0 )
	{
		FactsAdd("checking_horse",,2);
		FactsAdd("should_enable_changes",,3);
	}

	if ( FactsQuerySum("checking_horse")<=0 && FactsQuerySum("should_enable_changes")>0)
	{
		enable_changes = true;
	}	

	/// STEEL
	if ( FactsQuerySum("equip_steel_on_geralt") > 0 && FactsQuerySum("animation") <= 0 )
	{
		FactsAdd ("destroy_steel_comps",,1);
		FactsRemove("equip_steel_on_geralt");
		
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSteelWeapon')
			    && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted") <= 0 )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if (   thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSteelWeapon')
			    && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted") <= 0 )
			{
				thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
				if ( !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid) )
				{    thePlayer.EquipItem(items[i]);    }
				FactsAdd ("tagsdeleted",,1);
				//theGame.witcherLog.AddMessage(" EQUIP "); 
				//theGame.witcherLog.AddMessage(" CHECK 2"); 
			}
		}
	}
	
	/// SILVER
	if ( FactsQuerySum("equip_silver_on_geralt") > 0 && FactsQuerySum("animation") <= 0 )
	{
		FactsRemove("equip_silver_on_geralt");
		FactsAdd ("destroy_silver_comps",,1);
		
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSilverWeapon')
			    && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted_s") <= 0 )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		
		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSilverWeapon')
			    && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted_s") <= 0 )
			{
				thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
				if ( !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid) )
				{    thePlayer.EquipItem(items[i]);    }
				FactsAdd ("tagsdeleted_s",,1);
				//theGame.witcherLog.AddMessage(" EQUIP "); 
				//theGame.witcherLog.AddMessage(" CHECK 2"); 
			}
		}
	}
	
	
	/// STEEL
	if ( FactsQuerySum("unequip_again") > 0 && theGame.GetEntityByTag('steel_sword_on_roach') && theGame.GetEntityByTag('steel_scab_on_roach')
		&& theGame.GetEntityByTag('dummy_comp') )
	{
		FactsRemove("unequip_again");
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip') )
			{
				thePlayer.EquipItem(items[i]);
				thePlayer.GetInventory().RemoveItemTag(items[i], 'to_reequip');
			}
			
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSteelWeapon')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			  && !thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip')	)
			{
				 //thePlayer.UnequipItem(items[i]);
				 GetWitcherPlayer().GetHorseManager().MoveItemToHorse(items[i], 1);
				 GetWitcherPlayer().UpdateEncumbrance();
			}
		}
	}
	
	/// SILVER
	if ( FactsQuerySum("unequip_again_s") > 0 && theGame.GetEntityByTag('silver_sword_on_roach') && theGame.GetEntityByTag('silver_scab_on_roach')
		&& theGame.GetEntityByTag('dummy_comp_silver') )
	{
		FactsRemove("unequip_again_s");
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_s') )
			{
				thePlayer.EquipItem(items[i]);
				thePlayer.GetInventory().RemoveItemTag(items[i], 'to_reequip_s');
			}
			
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSilverWeapon')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			  && !thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_s')	)
			{
				 //thePlayer.UnequipItem(items[i]);
				 GetWitcherPlayer().GetHorseManager().MoveItemToHorse(items[i], 1);
				 GetWitcherPlayer().UpdateEncumbrance();
			}
		}
	}
	
	/// STEEL
	if ( FactsQuerySum("steel_on_roach") > 0 && !theGame.GetEntityByTag('steel_sword_on_roach') && !theGame.GetEntityByTag('steel_scab_on_roach') )
	{
		if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid_0) )
		{
			if ( thePlayer.GetInventory().ItemHasTag(steelid_0, 'PlayerSteelWeapon')
			  && !thePlayer.GetInventory().ItemHasTag(steelid_0, 'NoShow') )
			{
				thePlayer.GetInventory().AddItemTag(steelid_0, 'to_reequip');
			}
		}
		
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSteelWeapon')
			  && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSteelWeapon')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') )
			{
				 thePlayer.EquipItem(items[i]);
				 getsteelscab();
				 getsteel();
				 createdummy();
				 FactsAdd("unequip_again");
			}
		}
		
		//theGame.witcherLog.AddMessage(" reequipping steel sword "); 
		
		enable_changes = true;
	}
	
	/// SILVER
	if ( FactsQuerySum("silver_on_roach") > 0 && !theGame.GetEntityByTag('silver_sword_on_roach') && !theGame.GetEntityByTag('silver_scab_on_roach') )
	{
		//theGame.witcherLog.AddMessage(" reequipping silver sword "); 
		if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid_0) )
		{
			if ( thePlayer.GetInventory().ItemHasTag(silverid_0, 'PlayerSilverWeapon')
			  && !thePlayer.GetInventory().ItemHasTag(silverid_0, 'NoShow') )
			{
				thePlayer.GetInventory().AddItemTag(silverid_0, 'to_reequip_s');
			}
		}
		
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'PlayerSilverWeapon')
			  && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'PlayerSilverWeapon')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') )
			{
				 thePlayer.EquipItem(items[i]);
				 getsilverscab();
				 getsilver();
				 createdummysilver();
				 FactsAdd("unequip_again_s");
			}
		}
		
		//theGame.witcherLog.AddMessage(" reequipping silver sword "); 
		
		enable_changes = true;
	}
	
	/// STEEl
	if ( FactsQuerySum("destroy_steel_comps") > 0 && FactsQuerySum("animation") <= 0 )
	{
		theGame.GetEntitiesByTag('steel_sword_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy(); dummy = NULL;
		}
		
		theGame.GetEntitiesByTag('steel_scab_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy(); dummy = NULL;
		}
		
		theGame.GetEntitiesByTag('dummy_comp',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy();
			dummy = NULL;
		}

		FactsRemove ("destroy_steel_comps");
		FactsRemove ("steel_on_roach");
		FactsRemove ("steel_comps_placed");
		FactsAdd ("checking",,1);
		/*
		if ( theGame.GetEntityByTag('steel_sword_on_roach') )
		{
			theGame.witcherLog.AddMessage(" steel_sword_on_roach "); 
		}
		if ( theGame.GetEntityByTag('steel_scab_on_roach') )
		{
			theGame.witcherLog.AddMessage(" steel_scab_on_roach "); 
		}
		if ( theGame.GetEntityByTag('dummy_comp') )
		{
			theGame.witcherLog.AddMessage(" dummy_comp "); 
		}
		*/
	}
	
	/// SILVER
	if ( FactsQuerySum("destroy_silver_comps") > 0 && FactsQuerySum("animation") <= 0 )
	{
		theGame.GetEntitiesByTag('silver_sword_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy(); dummy = NULL;
		}
	
		theGame.GetEntitiesByTag('silver_scab_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy(); dummy = NULL;
		}
		
		theGame.GetEntitiesByTag('dummy_comp_silver',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy();
			dummy = NULL;
		}

		FactsRemove ("destroy_silver_comps");
		FactsRemove ("silver_on_roach");
		FactsRemove ("silver_comps_placed");
		FactsAdd ("checking_s",,1);
		/*
		if ( theGame.GetEntityByTag('silver_sword_on_roach') )
		{
			theGame.witcherLog.AddMessage(" silver_sword_on_roach "); 
		}
		if ( theGame.GetEntityByTag('silver_scab_on_roach') )
		{
			theGame.witcherLog.AddMessage(" silver_scab_on_roach "); 
		}
		if ( theGame.GetEntityByTag('dummy_comp_silver') )
		{
			theGame.witcherLog.AddMessage(" dummy_comp_silver "); 
		}
		*/
	}
	
	/// STEEL
	if ( theGame.GetEntityByTag('steel_sword_on_roach') && theGame.GetEntityByTag('steel_scab_on_roach') && FactsQuerySum("steel_comps_placed") <= 0 
		&& FactsQuerySum("animation") <= 0 )
	{
	
		Configsw = theGame.GetInGameConfigWrapper();
			steel_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_x')); 
			steel_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_y')); 
			steel_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_z')); 
			steel_roll = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_roll')); 
			steel_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pitch')); 
			steel_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_yaw')); 
			
			steel_scab_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_x_swor')); 
			steel_scab_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_y_swor')); 
			steel_scab_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_z_swor')); 
			steel_scab_roll = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_roll_swor')); 
			steel_scab_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pitch_swor')); 
			steel_scab_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_yaw_swor')); 
		
		steel_on_roach = theGame.GetEntityByTag('steel_sword_on_roach');
		
		steel_on_roach_position.X = 0;             steel_on_roach_rotation.Roll = 0;
		steel_on_roach_position.Y = 0;             steel_on_roach_rotation.Pitch = 0;
		steel_on_roach_position.Z = 0;             steel_on_roach_rotation.Yaw = 0;
		
		steel_on_roach_position.X += steel_pos_y;            steel_on_roach_rotation.Roll += steel_roll;
		steel_on_roach_position.Y -= steel_pos_z;            steel_on_roach_rotation.Pitch += steel_pitch;
		steel_on_roach_position.Z -= steel_pos_x;            steel_on_roach_rotation.Yaw += steel_yaw;
		
		steel_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp'),,steel_on_roach_position, steel_on_roach_rotation );
		
		
		steel_scab_on_roach = theGame.GetEntityByTag('steel_scab_on_roach');
		
		steel_scab_on_roach_position.X = 0;           steel_scab_on_roach_rotation.Roll = 0;
		steel_scab_on_roach_position.Y = 0;           steel_scab_on_roach_rotation.Pitch = 0;
		steel_scab_on_roach_position.Z = 0;           steel_scab_on_roach_rotation.Yaw = 0;
										
		steel_scab_on_roach_position.X += 0.61;       steel_scab_on_roach_rotation.Roll += -24.3; 
		steel_scab_on_roach_position.Y -= 0.09;       steel_scab_on_roach_rotation.Pitch += 180;
		steel_scab_on_roach_position.Z -= -1.71;      steel_scab_on_roach_rotation.Yaw += 14.4 + 0.41;   //fix
		
		steel_scab_on_roach_position.X += steel_scab_pos_x;      steel_scab_on_roach_rotation.Roll += steel_scab_roll; 
		steel_scab_on_roach_position.Y -= steel_scab_pos_y;      steel_scab_on_roach_rotation.Pitch += steel_scab_pitch;
		steel_scab_on_roach_position.Z -= steel_scab_pos_z;      steel_scab_on_roach_rotation.Yaw += steel_scab_yaw;   
		
		steel_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('steel_sword_on_roach'),,steel_scab_on_roach_position, steel_scab_on_roach_rotation );
		
		
		FactsAdd("steel_on_roach",,-1);
		FactsAdd("steel_comps_placed",,-1);
		//theGame.witcherLog.AddMessage(" steel_comps_placed "); 
	}
	
	/// SILVER
	if ( theGame.GetEntityByTag('silver_sword_on_roach') && theGame.GetEntityByTag('silver_scab_on_roach') && FactsQuerySum("silver_comps_placed") <= 0 
		&& FactsQuerySum("animation") <= 0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			silver_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_x')); 
			silver_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_y')); 
			silver_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_z')); 
			silver_roll = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_roll')); 
			silver_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pitch')); 
			silver_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_yaw')); 
			
			silver_scab_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_x_swor')); 
			silver_scab_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_y_swor')); 
			silver_scab_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_z_swor')); 
			silver_scab_roll = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_roll_swor')); 
			silver_scab_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pitch_swor')); 
			silver_scab_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_yaw_swor')); 
		
		silver_on_roach = theGame.GetEntityByTag('silver_sword_on_roach');
		
		silver_on_roach_position.X = 0;            			   silver_on_roach_rotation.Roll = 0;
		silver_on_roach_position.Y = 0;            			   silver_on_roach_rotation.Pitch = 0;
		silver_on_roach_position.Z = 0;            			   silver_on_roach_rotation.Yaw = 0;
		
		silver_on_roach_position.X += silver_pos_y;            silver_on_roach_rotation.Roll += silver_roll;
		silver_on_roach_position.Y -= silver_pos_z;            silver_on_roach_rotation.Pitch += silver_pitch;
		silver_on_roach_position.Z -= silver_pos_x;            silver_on_roach_rotation.Yaw += silver_yaw;
		
		silver_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_silver'),,silver_on_roach_position, silver_on_roach_rotation );
		
		
		silver_scab_on_roach = theGame.GetEntityByTag('silver_scab_on_roach');
		
		silver_scab_on_roach_position.X = 0;         			steel_scab_on_roach_rotation.Roll = 0;
		silver_scab_on_roach_position.Y = 0;         			steel_scab_on_roach_rotation.Pitch = 0;
		silver_scab_on_roach_position.Z = 0;         			steel_scab_on_roach_rotation.Yaw = 0;
										
		silver_scab_on_roach_position.X += 0.61 + 0.025;        silver_scab_on_roach_rotation.Roll += -24.3 - 5.5; //Y
		silver_scab_on_roach_position.Y -= 0.09 - 0.1;          silver_scab_on_roach_rotation.Pitch += 180 - 1.5;  //Z
		silver_scab_on_roach_position.Z -= -1.71 + 0.07;        silver_scab_on_roach_rotation.Yaw += 14.4 + 4;   //X
		
		silver_scab_on_roach_position.X += silver_scab_pos_x;        silver_scab_on_roach_rotation.Roll += silver_scab_roll; //Y
		silver_scab_on_roach_position.Y -= silver_scab_pos_y;          silver_scab_on_roach_rotation.Pitch += silver_scab_pitch;  //Z
		silver_scab_on_roach_position.Z -= silver_scab_pos_z;        silver_scab_on_roach_rotation.Yaw += silver_scab_yaw;   //X
		
		silver_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('silver_sword_on_roach'),,silver_scab_on_roach_position, silver_scab_on_roach_rotation );
		
		
		FactsAdd("silver_on_roach",,-1);
		FactsAdd("silver_comps_placed",,-1);
		//theGame.witcherLog.AddMessage(" silver_comps_placed "); 
	}
	
	if ( enable_changes || enable_changes_scabs )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			steel_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_x')); 
			steel_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_y')); 
			steel_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pos_z')); 
			steel_roll = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_roll')); 
			steel_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_pitch')); 
			steel_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach', 'steel_yaw')); 
			
			silver_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_x')); 
			silver_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_y')); 
			silver_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pos_z')); 
			silver_roll = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_roll')); 
			silver_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_pitch')); 
			silver_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach', 'silver_yaw')); 
			
			steel_scab_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_x_swor')); 
			steel_scab_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_y_swor')); 
			steel_scab_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pos_z_swor')); 
			steel_scab_roll = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_roll_swor')); 
			steel_scab_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_pitch_swor')); 
			steel_scab_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'steel_scab_yaw_swor')); 
			
			silver_scab_pos_x = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_x_swor')); 
			silver_scab_pos_y = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_y_swor')); 
			silver_scab_pos_z = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pos_z_swor')); 
			silver_scab_roll = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_roll_swor')); 
			silver_scab_pitch = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_pitch_swor')); 
			silver_scab_yaw = StringToFloat( Configsw.GetVarValue('swordsonroach_scabbards', 'silver_scab_yaw_swor')); 
		
		createdummy();
		createdummysilver();
		
		// STEEL
		if ( theGame.GetEntityByTag('steel_sword_on_roach') )
		{
			steel_on_roach = theGame.GetEntityByTag('steel_sword_on_roach');
			steel_on_roach.BreakAttachment();
			
			steel_on_roach_position.X = 0;                           steel_on_roach_rotation.Roll = 0;
			steel_on_roach_position.Y = 0;                           steel_on_roach_rotation.Pitch = 0;
			steel_on_roach_position.Z = 0;                           steel_on_roach_rotation.Yaw = 0;
			
			steel_on_roach_position.X += steel_pos_y;                steel_on_roach_rotation.Roll += steel_roll;
			steel_on_roach_position.Y -= steel_pos_z;                steel_on_roach_rotation.Pitch += steel_pitch;
			steel_on_roach_position.Z -= steel_pos_x;                steel_on_roach_rotation.Yaw += steel_yaw;
						
			steel_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp'),,steel_on_roach_position, steel_on_roach_rotation );
		}
		
		// SILVER
		if ( theGame.GetEntityByTag('silver_sword_on_roach') )
		{
			silver_on_roach = theGame.GetEntityByTag('silver_sword_on_roach');
			silver_on_roach.BreakAttachment();
			
			silver_on_roach_position.X = 0;                 		  silver_on_roach_rotation.Roll = 0;
			silver_on_roach_position.Y = 0;                 		  silver_on_roach_rotation.Pitch = 0;
			silver_on_roach_position.Z = 0;                 		  silver_on_roach_rotation.Yaw = 0;
			
			silver_on_roach_position.X += silver_pos_y;               silver_on_roach_rotation.Roll += silver_roll;
			silver_on_roach_position.Y -= silver_pos_z;               silver_on_roach_rotation.Pitch += silver_pitch;
			silver_on_roach_position.Z -= silver_pos_x;               silver_on_roach_rotation.Yaw += silver_yaw;
						
			silver_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_silver'),,silver_on_roach_position, silver_on_roach_rotation );
		}
		
		// STEEL
		if ( theGame.GetEntityByTag('steel_scab_on_roach') )
		{
			steel_scab_on_roach = theGame.GetEntityByTag('steel_scab_on_roach');
			steel_scab_on_roach.BreakAttachment();
			
			steel_scab_on_roach_position.X = 0;     	  			steel_scab_on_roach_rotation.Roll = 0;
			steel_scab_on_roach_position.Y = 0;           			steel_scab_on_roach_rotation.Pitch = 0;
			steel_scab_on_roach_position.Z = 0;           			steel_scab_on_roach_rotation.Yaw = 0;
						
			steel_scab_on_roach_position.X += 0.61;       			steel_scab_on_roach_rotation.Roll += -24.3; 
			steel_scab_on_roach_position.Y -= 0.09;       			steel_scab_on_roach_rotation.Pitch += 180;
			steel_scab_on_roach_position.Z -= -1.71;      			steel_scab_on_roach_rotation.Yaw += 14.4 + 0.41;   
			     
					
			steel_scab_on_roach_position.X += steel_scab_pos_x;	    steel_scab_on_roach_rotation.Roll += steel_scab_roll;
			steel_scab_on_roach_position.Y -= steel_scab_pos_y;     steel_scab_on_roach_rotation.Pitch += steel_scab_pitch;
			steel_scab_on_roach_position.Z -= steel_scab_pos_z;     steel_scab_on_roach_rotation.Yaw += steel_scab_yaw;
							
			steel_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('steel_sword_on_roach'),,steel_scab_on_roach_position, steel_scab_on_roach_rotation );
		}
		
		// SILVER
		if ( theGame.GetEntityByTag('silver_scab_on_roach') )
		{
			silver_scab_on_roach = theGame.GetEntityByTag('silver_scab_on_roach');
			silver_scab_on_roach.BreakAttachment();
			
			silver_scab_on_roach_position.X = 0;     	              silver_scab_on_roach_rotation.Roll = 0;
			silver_scab_on_roach_position.Y = 0;                      silver_scab_on_roach_rotation.Pitch = 0;
			silver_scab_on_roach_position.Z = 0;                      silver_scab_on_roach_rotation.Yaw = 0;
			                                                          
		    silver_scab_on_roach_position.X += 0.61 + 0.025;       silver_scab_on_roach_rotation.Roll += -24.3 - 5.5; //Y
		    silver_scab_on_roach_position.Y -= 0.09 - 0.1;        silver_scab_on_roach_rotation.Pitch += 180 - 1.5;  //Z
		    silver_scab_on_roach_position.Z -= -1.71 + 0.07;      silver_scab_on_roach_rotation.Yaw += 14.4 + 4;   //X
			     
			
			silver_scab_on_roach_position.X += silver_scab_pos_x;	  silver_scab_on_roach_rotation.Roll += silver_scab_roll;
			silver_scab_on_roach_position.Y -= silver_scab_pos_y;     silver_scab_on_roach_rotation.Pitch += silver_scab_pitch;
			silver_scab_on_roach_position.Z -= silver_scab_pos_z;     silver_scab_on_roach_rotation.Yaw += silver_scab_yaw;
			
			silver_scab_on_roach.CreateAttachment( theGame.GetEntityByTag('silver_sword_on_roach'),,silver_scab_on_roach_position, silver_scab_on_roach_rotation );
		}
		/*
		if( FactsQuerySum("steel_on_roach") > 0 )
		{
			theGame.witcherLog.AddMessage(" FACT STEEL"); 
		}
		
		if( FactsQuerySum("silver_on_roach") > 0 )
		{
			theGame.witcherLog.AddMessage(" FACT SILVER"); 
		}
		*/
		//theGame.witcherLog.AddMessage(" CHANGES "); 
		
		Configsw.SetVarValue( 'swordsonroach', 'enable_changes', "false" ); 
		enable_changes = false;
		
		Configsw.SetVarValue( 'swordsonroach_scabbards', 'enable_changes_scabbards', "false" ); 
		enable_changes_scabs = false;
		
		/*
		if ( theGame.GetEntityByTag('steel_sword_on_roach') )
		{
			theGame.witcherLog.AddMessage(" steel_sword_on_roach "); 
		}
		if ( theGame.GetEntityByTag('steel_scab_on_roach') )
		{
			theGame.witcherLog.AddMessage(" steel_scab_on_roach "); 
		}
		if ( theGame.GetEntityByTag('dummy_comp') )
		{
			theGame.witcherLog.AddMessage(" dummy_comp "); 
		}
		*/
	}
}

function getsteelscab()
{
	var scabbardscomp 									: CDrawableComponent;
	var i 												: int;
	var items 											: array<SItemUniqueId>;
	var meshComponent 									: CMeshComponent;
	var ent 											: CEntity;
	
	if ( !theGame.GetEntityByTag('steel_scab_on_roach') )
	{
		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{	
			if ( thePlayer.GetInventory().GetItemCategory(items[i]) == 'steel_scabbards' )
			{
				scabbardscomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(items[i])).GetMeshComponent());
				if( scabbardscomp.IsVisible() )
				{
					ent = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(thePlayer.GetInventory().GetItemEntityUnsafe(items[i]).GetReadableName(),true ),
					thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
					meshComponent = ( CMeshComponent ) ent.GetComponentByClassName( 'CMeshComponent' );
					meshComponent.SetScale( Vector( 1.03, 1.03, 1.03 ) );
					ent.AddTag('steel_scab_on_roach');
					//theGame.witcherLog.AddMessage(" steel_scab_on_roach "); 
				}
			}
		}
	}
}

function getsteel()
{
	var steelid							: SItemUniqueId; 
	var swordsteel						: CEntity; 
	var steelcopy						: CEntity;
	
	if ( !theGame.GetEntityByTag('steel_sword_on_roach') )
	{
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
		swordsteel = thePlayer.GetInventory().GetItemEntityUnsafe( steelid );
		thePlayer.GetInventory().AddItemTag(steelid, 'NoShow');
		steelcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(swordsteel.GetReadableName(),true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		steelcopy.AddTag('steel_sword_on_roach');
		//theGame.witcherLog.AddMessage(" steel_sword_on_roach "); 
	}
}

function createdummy()
{
	var front_bone  									: Bool;
	var boneIndex 										: int;
	var boneName 										: name;
	var boneRotation									: EulerAngles;
	var bonePosition									: Vector;
	var dummycomp										: CEntity;
	var dummies											: array<CEntity>;
	var i : Int;
	
	//boneName = 'r_shoulder';
	//boneName = 'spine3';
	//boneName = 'pelvis';
	
	//boneName = 'spine2';
	//boneName = 'spine1';
	
	theGame.GetEntitiesByTag('dummy_comp',dummies);
	
	for(i=0; i<dummies.Size(); i+=1)
	{
		dummies[i].Destroy();
	}
	
	if ( !theGame.GetEntityByTag('dummy_comp') )
	{
		
		front_bone = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'front_bone');
		
		if ( front_bone )
		{
			boneName = 'spine2';
		}
		else
		{
			boneName = 'spine1';
		}	
		
		boneIndex = thePlayer.GetHorseWithInventory().GetBoneIndex( boneName );	
		thePlayer.GetHorseWithInventory().GetBoneWorldPositionAndRotationByIndex( boneIndex, bonePosition, boneRotation );
		
		dummycomp = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("gameplay\templates\signs\pc_quen.w2ent",true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		dummycomp.AddTag('dummy_comp');
		dummycomp.CreateAttachmentAtBoneWS(thePlayer.GetHorseWithInventory(), boneName, bonePosition, boneRotation );
		//theGame.witcherLog.AddMessage(" dummy_comp "); 
	}
}

function putsteelonroach()
{
	var steelid				  							: SItemUniqueId;
	var items 											: array<SItemUniqueId>;
	var i												: Int;
	var disable_mod										: Bool;	
	var meshComponent 									: CMeshComponent;
	var dummy 											: CEntity;
	
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }
	
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid)
		&& !thePlayer.IsCombatMusicEnabled() 
		&& FactsQuerySum("steel_on_roach") <= 0 
		&& FactsQuerySum("checking") <= 0
		&& FactsQuerySum("doublecheck") <= 0
		&& !thePlayer.IsUsingHorse()
		)
	{
		getsteel();
		getsteelscab();
		createdummy();
		//thePlayer.UnequipItem(steelid);
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(steelid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
		FactsAdd ("do_nothing",,3);
		FactsAdd ("return_false",,1);
		FactsAdd ("doublecheck",,1);
		//theGame.witcherLog.AddMessage(" UNEQUIP "); 
		anima_give();
	}
	
	if ( FactsQuerySum("steel_on_roach") > 0 && FactsQuerySum("do_nothing") <= 0 )
	{
		dummy = theGame.GetEntityByTag('steel_sword_on_roach');
		meshComponent = ( CMeshComponent ) dummy.GetComponentByClassName( 'CMeshComponent' );
		if ( meshComponent.IsVisible() )
		{
			if ( !thePlayer.IsUsingHorse() )
			{
				FactsAdd ("return_false",,1);
				anima_take();
				FactsAdd ("equip_steel_on_geralt",,2);
			}
			else
			{
				FactsAdd ("return_false",,1);
				FactsAdd ("equip_steel_on_geralt",,2);
			}
		}
	}
}

function putsilveronroach()
{
	var silverid				  						: SItemUniqueId;
	var items 											: array<SItemUniqueId>;
	var i												: Int;
	var disable_mod										: Bool;	
	var meshComponent_s 								: CMeshComponent;
	var dummy_s											: CEntity;
	
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }
	
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid)
		&& !thePlayer.IsCombatMusicEnabled() 
		&& FactsQuerySum("silver_on_roach") <= 0 
		&& FactsQuerySum("checking_s") <= 0
		&& FactsQuerySum("doublecheck_s") <= 0
		&& !thePlayer.IsUsingHorse()
		)
	{
		getsilver();
		getsilverscab();
		createdummysilver();
		//thePlayer.UnequipItem(silverid);
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(silverid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
		FactsAdd ("do_nothing_s",,3);
		FactsAdd ("return_false",,1);
		FactsAdd ("doublecheck_s",,1);
		//theGame.witcherLog.AddMessage(" UNEQUIP "); 
		anima_give();
	}
	
	if ( FactsQuerySum("silver_on_roach") > 0 && FactsQuerySum("do_nothing_s") <= 0 )
	{
		dummy_s = theGame.GetEntityByTag('silver_sword_on_roach');
		meshComponent_s = ( CMeshComponent ) dummy_s.GetComponentByClassName( 'CMeshComponent' );
		if ( meshComponent_s.IsVisible() )
		{
			if ( !thePlayer.IsUsingHorse() )
			{
				FactsAdd ("return_false",,1);
				anima_take();
				FactsAdd ("equip_silver_on_geralt",,2);
			}
			else
			{
				FactsAdd ("return_false",,1);
				FactsAdd ("equip_silver_on_geralt",,2);
			}
		}
	}
}



function createdummysilver()
{
	var front_bone  									: Bool;
	var boneIndex 										: int;
	var boneName 										: name;
	var boneRotation									: EulerAngles;
	var bonePosition									: Vector;
	var dummycompsilver									: CEntity;
	var dummies_silver									: array<CEntity>;
	var i : Int;
	
	//boneName = 'r_shoulder';
	//boneName = 'spine3';
	//boneName = 'pelvis';
	
	//boneName = 'spine2';
	//boneName = 'spine1';
	
	theGame.GetEntitiesByTag('dummy_comp_silver',dummies_silver);
	
	for(i=0; i<dummies_silver.Size(); i+=1)
	{
		dummies_silver[i].Destroy();
	}
	
	if ( !theGame.GetEntityByTag('dummy_comp_silver') )
	{
		
		front_bone = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'front_bone');
		
		if ( front_bone )
		{
			boneName = 'spine2';
		}
		else
		{
			boneName = 'spine1';
		}	
		
		boneIndex = thePlayer.GetHorseWithInventory().GetBoneIndex( boneName );	
		thePlayer.GetHorseWithInventory().GetBoneWorldPositionAndRotationByIndex( boneIndex, bonePosition, boneRotation );
		
		dummycompsilver = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("gameplay\templates\signs\pc_quen.w2ent",true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		dummycompsilver.AddTag('dummy_comp_silver');
		dummycompsilver.CreateAttachmentAtBoneWS(thePlayer.GetHorseWithInventory(), boneName, bonePosition, boneRotation );
		//theGame.witcherLog.AddMessage(" dummy_comp_silver "); 
	}
}

function getsilver()
{
	var silverid						: SItemUniqueId; 
	var swordsilver						: CEntity; 
	var silvercopy						: CEntity;
	
	if ( !theGame.GetEntityByTag('silver_sword_on_roach') )
	{
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
		swordsilver = thePlayer.GetInventory().GetItemEntityUnsafe( silverid );
		thePlayer.GetInventory().AddItemTag(silverid, 'NoShow');
		silvercopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(swordsilver.GetReadableName(),true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		silvercopy.AddTag('silver_sword_on_roach');
		//theGame.witcherLog.AddMessage(" silver_sword_on_roach "); 
	}
}

function getsilverscab()
{
	var scabbardscomp_s 								: CDrawableComponent;
	var i 												: int;
	var items 											: array<SItemUniqueId>;
	var meshComponent 									: CMeshComponent;
	var ent_s 											: CEntity;
	
	if ( !theGame.GetEntityByTag('silver_scab_on_roach') )
	{
		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{	
			if ( thePlayer.GetInventory().GetItemCategory(items[i]) == 'silver_scabbards' )
			{
				scabbardscomp_s = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(items[i])).GetMeshComponent());
				if( scabbardscomp_s.IsVisible() )
				{
					ent_s = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(thePlayer.GetInventory().GetItemEntityUnsafe(items[i]).GetReadableName(),true ),
					thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
					meshComponent = ( CMeshComponent ) ent_s.GetComponentByClassName( 'CMeshComponent' );
					meshComponent.SetScale( Vector( 1.03, 1.03, 1.03 ) );
					ent_s.AddTag('silver_scab_on_roach');
					//theGame.witcherLog.AddMessage(" silver_scab_on_roach "); 
				}
			}
		}
	}
}

function anima_give()
{
	if ( theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'play_anim') )
	{
		thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_sword_forge_put_away_sword',0.5,0.5);
		FactsAdd("animation",,1);
	}
}

function anima_take()
{
	if ( theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'play_anim') )
	{
		thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'geralt_touching_wall',0.5,0.5);
		FactsAdd("animation",,1);
	}
}
