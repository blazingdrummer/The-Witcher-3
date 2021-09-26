function crossbowtorchonroach()
{
	var enable_changes,front_bone,disable_mod,reset_mod					: Bool;	
	var Configsw 														: CInGameConfigWrapper;
	var crossbow_pos_x,crossbow_pos_y,crossbow_pos_z   					: Float;
	var torch_pos_x,torch_pos_y,torch_pos_z   							: Float;
	var dummy															: CEntity;
	var crossbow_roll, crossbow_pitch, crossbow_yaw 					: Float;
	var torch_roll, torch_pitch, torch_yaw 								: Float; 
	var crossbow_on_roach,torch_on_roach								: CEntity;
	var crossbow_on_roach_position,torch_on_roach_position 				: Vector;
	var crossbow_on_roach_rotation,torch_on_roach_rotation 				: EulerAngles;
	var meshComponent 													: CMeshComponent;
	var crossbowid,crossbowid_0,torchid,torchid_0, torchid_02, itemId2, itemId22		: SItemUniqueId;
	var items 															: array<SItemUniqueId>;
	var i 																: Int;
	var dummies															: array<CEntity>;

	// CUSTOM MOD FOR SOR
	var ent , ent2          : CEntity;
	var meshcomp     : CDrawableComponent;

	var ids : array<SItemUniqueId>;
	var size : int;
	// CUSTOM MOD FOR SOR

	enable_changes = false;

	// B1.2
	reset_mod = false;
	reset_mod = theGame.GetInGameConfigWrapper().GetVarValue('crossbowtorchonroach', 'reset_mod_ctor');
	if ( reset_mod ) 
	{ 
		FactsAdd ("equip_torch_on_geralt",,2);
		FactsAdd ("equip_crossbow_on_geralt",,2);
		
		theGame.GetInGameConfigWrapper().SetVarValue( 'crossbowtorchonroach', 'reset_mod_ctor', "false" ); 
		reset_mod = false;
	}
	// E1.2

	enable_changes = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'enable_changes');
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }
	front_bone = theGame.GetInGameConfigWrapper().GetVarValue('crossbowtorchonroach', 'front_bone');

	// B1.2
	if ( !thePlayer.GetHorseWithInventory() && FactsQuerySum("checking_horse_ct")<=0 )
	{
		FactsAdd("checking_horse_ct",,2);
		FactsAdd("should_enable_changes_ct",,3);
	}

	if ( FactsQuerySum("checking_horse_ct")<=0 && FactsQuerySum("should_enable_changes_ct")>0)
	{
		enable_changes = true;
	}
	// E1.2

	// CUSTOM MOD FOR SOR
	// CROSSBOW
	if ( FactsQuerySum("equip_crossbow_on_geralt") > 0 && FactsQuerySum("animation") <= 0 )
	{
		FactsRemove("equip_crossbow_on_geralt");
		FactsAdd ("destroy_crossbow_comps",,1);
		// B1.2
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'crossbow')
			    && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted_c") <= 0 )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		// E1.2

		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   thePlayer.GetInventory().ItemHasTag(items[i], 'crossbow')
			    && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow')
			    && FactsQuerySum("tagsdeleted_c") <= 0 )
			{
				thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
				if ( !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, crossbowid) )
				{
					thePlayer.EquipItem(items[i]);

					// AUTO SELECT THE CROSSBOW IF RETRIEVED WHILE RIDING HORSE
					GetWitcherPlayer().SelectQuickslotItem( thePlayer.inv.GetSlotForItemId(items[i]) );

					// CUSTOM MOD FOR SOR

				}
				FactsAdd ("tagsdeleted_c",,1);

			}
		}
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	// TORCH
	if ( FactsQuerySum("equip_torch_on_geralt") > 0 && FactsQuerySum("animation") <= 0 )
	{
		FactsRemove("equip_torch_on_geralt");
		FactsAdd ("destroy_torch_comps",,1);
		// B1.2
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (   (GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemName( items[i] ) == 'q106_magic_oillamp')
			    && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted_t") <= 0 )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		// E1.2

		thePlayer.GetInventory().GetAllItems(items);	
		for(i=0; i<items.Size(); i+=1)
		{
			if (  (thePlayer.inv.GetItemName( items[i] ) == 'q106_magic_oillamp')
			    && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			    && FactsQuerySum("tagsdeleted_t") <= 0 )
			{
				thePlayer.GetInventory().RemoveItemTag(items[i], 'NoShow');
				//if ( !thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, crossbowid) )
				//{ 
				if(!thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot1, itemId2 ) || !thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot2, itemId22 ))
					thePlayer.EquipItem(items[i]);
					// CUSTOM MOD FOR SOR
				FactsAdd ("tagsdeleted_t",,1);

			}
		}
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// CROSSBOW
	if ( FactsQuerySum("unequip_again_c") > 0 && theGame.GetEntityByTag('crossbow_bow_on_roach') && theGame.GetEntityByTag('dummy_comp_crossbow') )
	{
		FactsRemove("unequip_again_c");
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_c') )
			{

				thePlayer.EquipItem(items[i]);
				// CUSTOM MOD FOR SOR

				thePlayer.GetInventory().RemoveItemTag(items[i], 'to_reequip_c');
			}

			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'crossbow')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			  && !thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_c')	)
			{
				//B1.2
				//thePlayer.UnequipItem(items[i]);
				GetWitcherPlayer().GetHorseManager().MoveItemToHorse(items[i], 1);
				GetWitcherPlayer().UpdateEncumbrance();
				//E1.2
			}
		}
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// TORCH
	if ( FactsQuerySum("unequip_again_t") > 0 && theGame.GetEntityByTag('torch_fire_on_roach') && theGame.GetEntityByTag('dummy_comp_torch') )
	{
		FactsRemove("unequip_again_t");
		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_t') )
			{
				thePlayer.EquipItem(items[i]);
				// CUSTOM MOD FOR SOR
				thePlayer.GetInventory().RemoveItemTag(items[i], 'to_reequip_t');
			}
			
			if ( (thePlayer.inv.GetItemName( items[i] ) == 'q106_magic_oillamp')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') 
			  && !thePlayer.GetInventory().ItemHasTag(items[i], 'to_reequip_t')	)
			{
				//B1.2
				//thePlayer.UnequipItem(items[i]);
				GetWitcherPlayer().GetHorseManager().MoveItemToHorse(items[i], 1);
				GetWitcherPlayer().UpdateEncumbrance();
				//E1.2
			}
		}
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// CROSSBOW
	if ( FactsQuerySum("crossbow_on_roach") > 0 && !theGame.GetEntityByTag('crossbow_bow_on_roach') )
	{
		if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, crossbowid_0) )
		{
			if ( thePlayer.GetInventory().ItemHasTag(crossbowid_0, 'crossbow')
			  && !thePlayer.GetInventory().ItemHasTag(crossbowid_0, 'NoShow') )
			{
				thePlayer.GetInventory().AddItemTag(crossbowid_0, 'to_reequip_c');
			}
		}
		
		// B1.2
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'crossbow')
			  && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		//E1.2

		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( thePlayer.GetInventory().ItemHasTag(items[i], 'crossbow')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') )
			{
				 thePlayer.EquipItem(items[i]);
				 getcrossbow();
				 createdummycrossbow();
				 
				 FactsAdd("unequip_again_c");
				 // CUSTOM MOD FOR SOR
			}
		}
		
		enable_changes = true;
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// TORCH
	if ( FactsQuerySum("torch_on_roach") > 0 && !theGame.GetEntityByTag('torch_fire_on_roach') )
	{
		
		if ( thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot1, torchid_0 ) )
		{

			if ( (thePlayer.inv.GetItemName( torchid_0 ) == 'q106_magic_oillamp')
			  && !thePlayer.GetInventory().ItemHasTag(torchid_0, 'NoShow') )
			{
				thePlayer.GetInventory().AddItemTag(torchid_0, 'to_reequip_t');
			}
		}
		
		if ( thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot2, torchid_02 ) )
		{

			if ( (thePlayer.inv.GetItemName( torchid_02 ) == 'q106_magic_oillamp')
			  && !thePlayer.GetInventory().ItemHasTag(torchid_02, 'NoShow') )
			{
				thePlayer.GetInventory().AddItemTag(torchid_02, 'to_reequip_t');
			}
		}
		// B1.2
		GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( (GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemName( items[i] ) == 'q106_magic_oillamp')
			  && GetWitcherPlayer().GetHorseManager().GetInventoryComponent().ItemHasTag(items[i], 'NoShow') )
			{
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(items[i]);
				GetWitcherPlayer().UpdateEncumbrance();
			}
		}
		// E1.2

		thePlayer.GetInventory().GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if ( (thePlayer.inv.GetItemName( items[i] ) == 'q106_magic_oillamp')
			  && thePlayer.GetInventory().ItemHasTag(items[i], 'NoShow') )
			{
				 thePlayer.EquipItem(items[i]);
				 gettorch();
				 createdummytorch();
				 
				 FactsAdd("unequip_again_t");
				 // CUSTOM MOD FOR SOR
			}
		}
		
		enable_changes = true;
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// CROSSBOW
	if ( FactsQuerySum("destroy_crossbow_comps") > 0 && FactsQuerySum("animation") <= 0 )
	{
		theGame.GetEntitiesByTag('crossbow_bow_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			// BE1.2
			dummy.Destroy(); dummy = NULL;
		}
		
		theGame.GetEntitiesByTag('dummy_comp_crossbow',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy();
			dummy = NULL;
		}

		FactsRemove ("destroy_crossbow_comps");
		FactsRemove ("crossbow_on_roach");
		FactsRemove ("crossbow_comps_placed");
		FactsAdd ("checking_c",,1);

	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// TORCH
	if ( FactsQuerySum("destroy_torch_comps") > 0 && FactsQuerySum("animation") <= 0 )
	{
		theGame.GetEntitiesByTag('torch_fire_on_roach',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			// BE1.2
			dummy.Destroy(); dummy = NULL;
		}
		
		theGame.GetEntitiesByTag('dummy_comp_torch',dummies);
		for(i=0; i<dummies.Size(); i+=1)
		{
			dummy = dummies[i];
			dummy.Destroy();
			dummy = NULL;
		}

		FactsRemove ("destroy_torch_comps");
		FactsRemove ("torch_on_roach");
		FactsRemove ("torch_comps_placed");
		FactsAdd ("checking_t",,1);
	}
	// CUSTOM MOD FOR SOR
	

	// CUSTOM MOD FOR SOR
	/// CROSSBOW
	if ( theGame.GetEntityByTag('crossbow_bow_on_roach') && FactsQuerySum("crossbow_comps_placed") <= 0 
		&& FactsQuerySum("animation") <= 0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			crossbow_pos_x = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_x')); 
			crossbow_pos_y = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_y')); 
			crossbow_pos_z = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_z')); 
			crossbow_roll = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_roll')); 
			crossbow_pitch = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pitch')); 
			crossbow_yaw = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_yaw')); 
		
		crossbow_on_roach = theGame.GetEntityByTag('crossbow_bow_on_roach');
		
		crossbow_on_roach_position.X = 0;            			   crossbow_on_roach_rotation.Roll = 0;
		crossbow_on_roach_position.Y = 0;            			   crossbow_on_roach_rotation.Pitch = 0;
		crossbow_on_roach_position.Z = 0;            			   crossbow_on_roach_rotation.Yaw = 0;
		
		crossbow_on_roach_position.X += crossbow_pos_x;            crossbow_on_roach_rotation.Roll += crossbow_roll;
		crossbow_on_roach_position.Y -= crossbow_pos_y;            crossbow_on_roach_rotation.Pitch += crossbow_pitch;
		crossbow_on_roach_position.Z -= crossbow_pos_z;            crossbow_on_roach_rotation.Yaw += crossbow_yaw;
		
		crossbow_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_crossbow'),,crossbow_on_roach_position, crossbow_on_roach_rotation );
		
		FactsAdd("crossbow_on_roach",,-1);
		FactsAdd("crossbow_comps_placed",,-1);
		//theGame.witcherLog.AddMessage(" silver_comps_placed "); 
	}
	// CUSTOM MOD FOR SOR

	// CUSTOM MOD FOR SOR
	/// TORCH
	if ( theGame.GetEntityByTag('torch_fire_on_roach') && FactsQuerySum("torch_comps_placed") <= 0 
		&& FactsQuerySum("animation") <= 0 )
	{
		Configsw = theGame.GetInGameConfigWrapper();
			torch_pos_x = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_x')); 
			torch_pos_y = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_y')); 
			torch_pos_z = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_z')); 
			torch_roll = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_roll')); 
			torch_pitch = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pitch')); 
			torch_yaw = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_yaw')); 
		
		torch_on_roach = theGame.GetEntityByTag('torch_fire_on_roach');
		
		torch_on_roach_position.X = 0;            			   torch_on_roach_rotation.Roll = 0;
		torch_on_roach_position.Y = 0;            			   torch_on_roach_rotation.Pitch = 0;
		torch_on_roach_position.Z = 0;            			   torch_on_roach_rotation.Yaw = 0;
		
		torch_on_roach_position.X += torch_pos_x;            torch_on_roach_rotation.Roll += torch_roll;
		torch_on_roach_position.Y -= torch_pos_y;            torch_on_roach_rotation.Pitch += torch_pitch;
		torch_on_roach_position.Z -= torch_pos_z;            torch_on_roach_rotation.Yaw += torch_yaw;
		
		torch_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_torch'),,torch_on_roach_position, torch_on_roach_rotation );

		
		FactsAdd("torch_on_roach",,-1);
		FactsAdd("torch_comps_placed",,-1);
		//theGame.witcherLog.AddMessage(" silver_comps_placed "); 
	}
	// CUSTOM MOD FOR SOR

	if ( enable_changes  )
	{
		Configsw = theGame.GetInGameConfigWrapper();

			// CUSTOM MOD FOR SOR
			crossbow_pos_x = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_x')); 
			crossbow_pos_y = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_y')); 
			crossbow_pos_z = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pos_z')); 
			crossbow_roll = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_roll')); 
			crossbow_pitch = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_pitch')); 
			crossbow_yaw = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'crossbow_yaw'));

			torch_pos_x = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_x')); 
			torch_pos_y = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_y')); 
			torch_pos_z = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pos_z')); 
			torch_roll = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_roll')); 
			torch_pitch = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_pitch')); 
			torch_yaw = StringToFloat( Configsw.GetVarValue('crossbowtorchonroach', 'torch_yaw')); 
			// CUSTOM MOD FOR SOR
		
		// CUSTOM MOD FOR SOR
		createdummycrossbow();
		createdummytorch();
		// CUSTOM MOD FOR SOR
	

		// CUSTOM MOD FOR SOR
		// CROSSBOW
		if ( theGame.GetEntityByTag('crossbow_bow_on_roach') )
		{
			crossbow_on_roach = theGame.GetEntityByTag('crossbow_bow_on_roach');
			crossbow_on_roach.BreakAttachment();
			
			crossbow_on_roach_position.X = 0;                 		  crossbow_on_roach_rotation.Roll = 0;
			crossbow_on_roach_position.Y = 0;                 		  crossbow_on_roach_rotation.Pitch = 0;
			crossbow_on_roach_position.Z = 0;                 		  crossbow_on_roach_rotation.Yaw = 0;
			
			crossbow_on_roach_position.X += crossbow_pos_x;               crossbow_on_roach_rotation.Roll += crossbow_roll;
			crossbow_on_roach_position.Y -= crossbow_pos_y;               crossbow_on_roach_rotation.Pitch += crossbow_pitch;
			crossbow_on_roach_position.Z -= crossbow_pos_z;               crossbow_on_roach_rotation.Yaw += crossbow_yaw;
			
			crossbow_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_crossbow'),,crossbow_on_roach_position, crossbow_on_roach_rotation );
		}
		// CUSTOM MOD FOR SOR

		// CUSTOM MOD FOR SOR
		// TORCH
		if ( theGame.GetEntityByTag('torch_fire_on_roach') )
		{
			torch_on_roach = theGame.GetEntityByTag('torch_fire_on_roach');
			torch_on_roach.BreakAttachment();

			torch_on_roach_position.X = 0;                 		  torch_on_roach_rotation.Roll = 0;
			torch_on_roach_position.Y = 0;                 		  torch_on_roach_rotation.Pitch = 0;
			torch_on_roach_position.Z = 0;                 		  torch_on_roach_rotation.Yaw = 0;

			torch_on_roach_position.X += torch_pos_x;               torch_on_roach_rotation.Roll += torch_roll;
			torch_on_roach_position.Y -= torch_pos_y;               torch_on_roach_rotation.Pitch += torch_pitch;
			torch_on_roach_position.Z -= torch_pos_z;               torch_on_roach_rotation.Yaw += torch_yaw;

			torch_on_roach.CreateAttachment( theGame.GetEntityByTag('dummy_comp_torch'),,torch_on_roach_position, torch_on_roach_rotation );

			
		}
		// CUSTOM MOD FOR SOR
		
		//theGame.witcherLog.AddMessage(" CHANGES "); 
		Configsw.SetVarValue( 'swordsonroach', 'enable_changes', "false" ); 
		enable_changes = false;
		
	}

}


// CUSTOM MOD FOR SOR
function putcrossbowonroach()
{
	var crossbowid				  						: SItemUniqueId;
	var items 											: array<SItemUniqueId>;
	var i												: Int;
	var disable_mod										: Bool;	
	var meshComponent_c 								: CMeshComponent;
	var dummy_c											: CEntity;
	
	
	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }
	
	if ( thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, crossbowid)
		&& !thePlayer.IsCombatMusicEnabled() 
		&& FactsQuerySum("crossbow_on_roach") <= 0 
		&& FactsQuerySum("checking_c") <= 0
		&& FactsQuerySum("doublecheck_c") <= 0
		&& !thePlayer.IsUsingHorse()
		)
	{
		getcrossbow();
		createdummycrossbow();

		//thePlayer.UnequipItem(crossbowid);
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(crossbowid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
		// CUSTOM MOD FOR SOR

		// CUSTOM MOD FOR SOR
		FactsAdd ("do_nothing_c",,3);
		FactsAdd ("return_false",,1);
		FactsAdd ("doublecheck_c",,1);
		
		anima_give();
	}
	

	if ( FactsQuerySum("crossbow_on_roach") > 0 && FactsQuerySum("do_nothing_c") <= 0 )
	{
		dummy_c = theGame.GetEntityByTag('crossbow_bow_on_roach');
		meshComponent_c = ( CMeshComponent ) dummy_c.GetComponentByClassName( 'CMeshComponent' );
		if ( meshComponent_c.IsVisible() )
		{
			if ( !thePlayer.IsUsingHorse() )
			{
				FactsAdd ("return_false",,1);
				anima_take();
				FactsAdd ("equip_crossbow_on_geralt",,2);
			}
			else
			{
				FactsAdd ("return_false",,1);
				FactsAdd ("equip_crossbow_on_geralt",,2);
			}
		}
	}
	
}
// CUSTOM MOD FOR SOR

// CUSTOM MOD FOR SOR
function puttorchonroach()
{
	var torchid, torchid1, torchid2				  							: SItemUniqueId;
	var items 											: array<SItemUniqueId>;
	var i												: Int;
	var disable_mod										: Bool;	
	var meshComponent_t 								: CMeshComponent;
	var dummy_t											: CEntity;
	

	disable_mod = theGame.GetInGameConfigWrapper().GetVarValue('swordsonroach', 'disable_mod');
	if ( disable_mod ) { return; }

	if ( (thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot1, torchid1 ) || thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot2, torchid2 ))
		&& !thePlayer.IsCombatMusicEnabled()
		&& FactsQuerySum("torch_on_roach") <= 0
		&& FactsQuerySum("checking_t") <= 0
		&& FactsQuerySum("doublecheck_t") <= 0
		&& !thePlayer.IsUsingHorse()
		)
	{
		thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot1, torchid1 );
		thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot2, torchid2 );
		if(thePlayer.inv.GetItemName(torchid1) == 'q106_magic_oillamp')
			torchid = torchid1;
		else if(thePlayer.inv.GetItemName(torchid2) == 'q106_magic_oillamp')
			torchid = torchid2;
		gettorch();
		createdummytorch();
		//thePlayer.UnequipItem(torchid);
		GetWitcherPlayer().GetHorseManager().MoveItemToHorse(torchid, 1);
		GetWitcherPlayer().UpdateEncumbrance();
		// CUSTOM MOD FOR SOR

		// CUSTOM MOD FOR SOR
		FactsAdd ("do_nothing_t",,3);
		FactsAdd ("return_false",,1);
		FactsAdd ("doublecheck_t",,1);
		//theGame.witcherLog.AddMessage(" UNEQUIP "); 
		anima_give();
	}
	
	if ( FactsQuerySum("torch_on_roach") > 0 && FactsQuerySum("do_nothing_t") <= 0 )
	{
		dummy_t = theGame.GetEntityByTag('torch_fire_on_roach');
		meshComponent_t = ( CMeshComponent ) dummy_t.GetComponentByClassName( 'CMeshComponent' );
		if ( meshComponent_t.IsVisible() )
		{
			if ( !thePlayer.IsUsingHorse() )
			{
				FactsAdd ("return_false",,1);
				anima_take();
				FactsAdd ("equip_torch_on_geralt",,2);
			}
			else
			{
				FactsAdd ("return_false",,1);
				FactsAdd ("equip_torch_on_geralt",,2);
			}
		}
	}
	
}
// CUSTOM MOD FOR SOR


// CUSTOM MOD FOR SOR
function getcrossbow()
{
	var crossbowid						: SItemUniqueId; 
	var crossbow						: CEntity; 
	var crossbowcopy					: CEntity;

	// CUSTOM MOD FOR SOR
	var temp : CEntityTemplate;
	// CUSTOM MOD FOR SOR
	
	if ( !theGame.GetEntityByTag('crossbow_bow_on_roach') )
	{
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, crossbowid);
		crossbow = thePlayer.GetInventory().GetItemEntityUnsafe( crossbowid );
		thePlayer.GetInventory().AddItemTag(crossbowid, 'NoShow');

		theGame.witcherLog.AddMessage(crossbow.GetReadableName()); 
		// B1.2
		crossbowcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource(crossbow.GetReadableName(),true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		// E1.2
		
		crossbowcopy.AddTag('crossbow_bow_on_roach');
	}
}
// CUSTOM MOD FOR SOR

// CUSTOM MOD FOR SOR
function gettorch()
{
	var torchid, torchid2, lampid				: SItemUniqueId;
	var torch						: CEntity;
	var torchcopy					: CEntity;
	var proceed						: bool;

	// CUSTOM MOD FOR SOR
	var temp : CEntityTemplate;
	var comp:CComponent;
	// CUSTOM MOD FOR SOR

	if ( !theGame.GetEntityByTag('torch_fire_on_roach') )
	{
		thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot1, torchid );
		//lampid = thePlayer.GetSelectedItemId();
		if(thePlayer.inv.GetItemName(torchid) == 'q106_magic_oillamp')
		{
			lampid = torchid;
			proceed = true;
		}
		else
		{
			thePlayer.inv.GetItemEquippedOnSlot( EES_Quickslot2, torchid2 );
			if(thePlayer.inv.GetItemName(torchid2) == 'q106_magic_oillamp')
			{
				lampid = torchid2;
				proceed = true;
			}
		}
	
		if(proceed)
		{
		
			torchcopy = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("items\usable\q106_magic_oillamp.w2ent",true ), //FINAL
			thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
			
			thePlayer.GetInventory().AddItemTag(lampid, 'NoShow');

			comp = torchcopy.GetComponentByClassName('CGameplayLightComponent');
			((CGameplayLightComponent)comp).SetLight(true);

			torchcopy.AddTag('torch_fire_on_roach');
		}

	}
}
// CUSTOM MOD FOR SOR

// CUSTOM MOD FOR SOR
function createdummycrossbow()
{
	var front_bone  									: Bool;
	var boneIndex 										: int;
	var boneName 										: name;
	var boneRotation									: EulerAngles;
	var bonePosition									: Vector;
	var dummycompcrossbow								: CEntity;
	var dummies_crossbow								: array<CEntity>;
	var i : Int;
	
	theGame.GetEntitiesByTag('dummy_comp_crossbow',dummies_crossbow);
	
	for(i=0; i<dummies_crossbow.Size(); i+=1)
	{
		dummies_crossbow[i].Destroy();
	}
	
	if ( !theGame.GetEntityByTag('dummy_comp_crossbow') )
	{
		
		front_bone = theGame.GetInGameConfigWrapper().GetVarValue('crossbowtorchonroach', 'front_bone');
		
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
		
		dummycompcrossbow = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("gameplay\templates\signs\pc_quen.w2ent",true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		dummycompcrossbow.AddTag('dummy_comp_crossbow');
		dummycompcrossbow.CreateAttachmentAtBoneWS(thePlayer.GetHorseWithInventory(), boneName, bonePosition, boneRotation );
		
	}
}
// CUSTOM MOD FOR SOR

// CUSTOM MOD FOR SOR
function createdummytorch()
{
	var front_bone  									: Bool;
	var boneIndex 										: int;
	var boneName 										: name;
	var boneRotation									: EulerAngles;
	var bonePosition									: Vector;
	var dummycomptorch									: CEntity;
	var dummies_torch									: array<CEntity>;
	var i : Int;

	theGame.GetEntitiesByTag('dummy_comp_torch',dummies_torch);
	
	for(i=0; i<dummies_torch.Size(); i+=1)
	{
		dummies_torch[i].Destroy();
	}
	
	if ( !theGame.GetEntityByTag('dummy_comp_torch') )
	{
		
		front_bone = theGame.GetInGameConfigWrapper().GetVarValue('crossbowtorchonroach', 'front_bone');
		
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
		
		dummycomptorch = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("gameplay\templates\signs\pc_quen.w2ent",true ),
		thePlayer.GetWorldPosition()-100, thePlayer.GetWorldRotation()  );
		dummycomptorch.AddTag('dummy_comp_torch');
		dummycomptorch.CreateAttachmentAtBoneWS(thePlayer.GetHorseWithInventory(), boneName, bonePosition, boneRotation );
		
	}
}
// CUSTOM MOD FOR SOR
