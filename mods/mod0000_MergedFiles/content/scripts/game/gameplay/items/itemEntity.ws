/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




import class CItemEntity extends CEntity
{
	
	import final function GetParentEntity() : CEntity;
	
	
	import final function GetItemTags( out tags : array<name> );

	import final function GetMeshComponent() : CComponent;

	
	event OnGrab()
	{
		SetupDrawHolsterSounds();
	}
	
	
	event OnPut()
	{
		SetupDrawHolsterSounds();
	}
	
	event OnAttachmentUpdate(parentEntity : CEntity, itemName : name)
	{
		var actorParent : CActor;
		var dm 	: CDefinitionsManagerAccessor;
		
		actorParent = (CActor)parentEntity;
		if( actorParent )
		{
			if(theGame && actorParent.IsHuman())
			{
				if(itemName != '')
				{
					dm = theGame.GetDefinitionsManager();
					if(dm)
					{	
						if( IFT_Armors == dm.GetFilterTypeByItem(itemName) )
						{
							actorParent.AddTimer('DelaySoundInfoUpdate', 1);
						}	
					}
				}
				else 
				{
					actorParent.AddTimer('DelaySoundInfoUpdate', 1);
				}
			}
		}
	}
	
	public function SetupDrawHolsterSounds()
	{
		var parentEntity : CEntity;
		var identification : name;
		var component : CComponent;
		
		parentEntity = (CEntity) GetParentEntity();
		if( parentEntity )
		{
			component = GetMeshComponent();

			if( component )
			{
				identification = GetMeshSoundTypeIdentification( component );
				parentEntity.SoundSwitch( "weapon_type", identification );
				identification = GetMeshSoundSizeIdentification( component );
				parentEntity.SoundSwitch( "weapon_size", identification );
			}
		}
	}
	
	import final function GetItemCategory() : name; 
	
	event OnItemCollision( object : CObject, physicalActorindex : int, shapeIndex : int )
	{
		var victim : CGameplayEntity;
		var owner : CActor;
		var ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		owner = (CActor)GetParentEntity();
		
		if ( ent != this && owner && ent != owner )
		{
			victim = (CGameplayEntity)component.GetEntity();
			
			if ( victim )
			{
				if ( physicalActorindex == 0 && shapeIndex == 0 && ((CMovingAgentComponent)component).HasRagdoll() )
					return false;
					
				owner.OnCollisionFromItem(victim, this);
			}
			return true;
		}	
	}
	
	event OnGiantWeaponCollision( object : CObject, physicalActorindex : int, shapeIndex : int )
	{
		var victim : CActor;
		var owner : CActor;
		var ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		owner = (CActor)GetParentEntity();
		
		if ( ent != this && owner && ent != owner )
		{
			victim = (CActor)component.GetEntity();
			
			if ( victim )
			{
				if ( physicalActorindex == 0 && shapeIndex == 0 && ((CMovingAgentComponent)component).HasRagdoll() )
					return false;
					
				owner.OnCollisionFromGiantWeapon(victim, this);
			}
			return true;
		}	
	}
}

class W3EffectItem extends CItemEntity
{
	editable var effectName : name;
	
	event OnGrab()
	{	
		if ( effectName != '' )
		{
			DestroyEffect(effectName);
			PlayEffectSingle(effectName, this );
		}
		super.OnGrab();
	}
	
	event OnPut()
	{
		if ( effectName != '' )
		{
			StopEffectIfActive(effectName);
		}
		super.OnPut();
	}
}



class W3UsableItem extends CItemEntity
{
	editable var itemType : EUsableItemType;
	editable var blockedActions : array<EInputActionBlock>;
	var wasOnHiddenCalled : bool;
	
	hint itemType = "Kind of animations to be used";
	hint blockedActions = "List of actions blocked when actively using this item";
	
	event OnDestroyed()
	{
		if ( !wasOnHiddenCalled )
		{
			OnHidden( GetParentEntity() );
		}
	}
	event OnUsed( usedBy : CEntity )
	{
		var i : int;
		
		if( usedBy == thePlayer )
		{
			blockedActions.PushBack( EIAB_Parry );
			blockedActions.PushBack( EIAB_Counter );
			
			for( i = 0; i < blockedActions.Size(); i += 1)
			{
				thePlayer.BlockAction( blockedActions[i], 'UsableItem' );
			}
		}
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		var i : int;
		
		wasOnHiddenCalled = true;
		
		if( hiddenBy == thePlayer )
		{
			thePlayer.BlockAllActions( 'UsableItem', false );
		}
	}
	
	function SetVisibility( isVisible : bool )
	{
		var comps : array <CComponent>;
		var dComp : CDrawableComponent;
		var i : int;

		comps = GetComponentsByClassName( 'CDrawableComponent' );
		
		for( i=0; i < comps.Size (); i+=1 )
		{
			dComp = (CDrawableComponent)comps[i];
			
			if( dComp && dComp.GetName() != "shadow_capsule" )
			{
				dComp.SetVisible( isVisible );	
			}	
		}
	}
}
//#mod ++NaturalTorchlight++ Utility class for light items
enum ENaturalShadowType
{
	NST_Distant,
	NST_Near,
	NST_All,
	NST_None
};
enum ENaturalCaveType
{
	NCT_None,
	NCT_Cave,
	NCT_Cavern,
	NCT_CaveOfDreams
};
struct SNaturalArea
{
	var area : int;
	var city : bool;
	var cave : ENaturalCaveType;
};
struct SNaturalLight
{
	var light 					: CLightComponent;
	var isStale					: bool;
	var isNear					: bool;
	var isDistant				: bool;
	var color, colorSet			: Color;
	var shadow, shadowSet		: ELightShadowCastingMode;
	var blend, blendSet			: float;
	var group, groupSet			: EEnvColorGroup;
	var flicker, flickerSet		: SLightFlickering;
};
class CNaturalLightManager
{	
	private const var GUI			: name;
	default GUI						= 'NaturalTorchlight';
	private var config				: CInGameConfigWrapper;
	private var guiInstalled		: bool;
	private var guiGroup			: name;
	private var guiOverride			: name;
	default guiOverride				= 'None';
	private var entity				: CItemEntity;
	private var lights				: array<SNaturalLight>;
	private var brightness			: float;
	private var menuEnabled			: bool;
	default brightness				= 0.0;
	default menuEnabled				= true;
	private var transitionActive	: bool;
	private var transitionLength	: float;
	default transitionLength		= 1.0;
	var c1, c2, t1, t2, d1, d2		: float;
	function SetGUI(value : name)
	{
		guiOverride = value;
		guiGroup = GetActiveGUI();
		guiInstalled = guiGroup != 'None';
	}
	function ClearGUI()
	{
		guiOverride = 'None';
		guiGroup = GetActiveGUI();
		guiInstalled = guiGroup != 'None';
	}
	function SetBrightness(value : float)
	{
		brightness = value;
	}
	function Reset()
	{
		var i : int;
		c1 = 1.0;
		c2 = 1.0;
		t1 = c1;
		t2 = c2;
		d1 = 0.0;
		d2 = 0.0;
		for(i = 0; i < lights.Size(); i += 1)
		{
			lights[i].colorSet = lights[i].color;
			lights[i].shadowSet = lights[i].shadow;
			lights[i].blendSet = lights[i].blend;
			lights[i].flickerSet = lights[i].flicker;
			lights[i].groupSet = lights[i].group;
			lights[i].isStale = true;
		}
		ApplySettings();
	}
	function SetMenuEnabled(enabled : bool)
	{
		menuEnabled = enabled;
	}
	function SetColor(i : int, red, green, blue : byte)
	{
		lights[i].colorSet = Color(red, green, blue, 255);
		lights[i].isStale = true;
	}
	function ClearColor(i : int)
	{
		lights[i].colorSet = lights[i].color;
		lights[i].isStale = true;
	}
	function SetFlickeringStrength(i : int, x : float)
	{
		lights[i].flickerSet.flickerStrength = x;
		lights[i].isStale = true;
	}
	function ClearFlickeringStrength(i : int)
	{
		lights[i].flickerSet.flickerStrength = lights[i].flicker.flickerStrength;
		lights[i].isStale = true;
	}
	function SetFlickeringPeriod(i : int, x : float)
	{
		lights[i].flickerSet.flickerPeriod = x;
		lights[i].isStale = true;
	}
	function ClearFlickeringPeriod(i : int)
	{
		lights[i].flickerSet.flickerPeriod = lights[i].flicker.flickerPeriod;
		lights[i].isStale = true;
	}
	function SetGroup(i : int, group : EEnvColorGroup)
	{
		lights[i].groupSet = group;
		lights[i].isStale = true;
	}
	function ClearGroup(i : int)
	{
		lights[i].groupSet = lights[i].group;
		lights[i].isStale = true;
	}
	function SetNear(i : int)
	{
		lights[i].isNear = true;
		lights[i].isDistant = false;
	}
	function SetDistant(i : int)
	{
		lights[i].isNear = false;
		lights[i].isDistant = true;
	}
	function Initialize(self : CItemEntity)
	{
		var comps 	: array<CComponent>;
		var i		: int;
		entity = self;	
		comps = entity.GetComponentsByClassName('CLightComponent');
		lights.Resize(comps.Size());
		for(i = 0; i < comps.Size(); i += 1)
		{
			lights[i].light = (CLightComponent)comps[i];
			lights[i].color = lights[i].light.color;
			lights[i].colorSet = lights[i].light.color;
			lights[i].flicker = lights[i].light.lightFlickering;
			lights[i].flickerSet = lights[i].light.lightFlickering;
			lights[i].shadow = lights[i].light.shadowCastingMode;
			lights[i].shadowSet = lights[i].light.shadowCastingMode;
			lights[i].blend = lights[i].light.shadowBlendFactor;
			lights[i].blendSet = lights[i].light.shadowBlendFactor;
			lights[i].group = lights[i].light.envColorGroup;
			lights[i].groupSet = lights[i].light.envColorGroup;
		}
		if(!config) config = theGame.GetInGameConfigWrapper();
		guiGroup = GetActiveGUI();
		guiInstalled = guiGroup != 'None';
	}
	function Start()
	{
		OnUpdate();
		entity.AddTimer('Update', 1.0, true);
	}
	function Stop()
	{
		entity.RemoveTimer('Update');
		entity.RemoveTimer('Transition');
		transitionActive = false;
	}
	function OnUpdate(optional delta : float, optional id : int)
	{
		var areaInfo		: SNaturalArea;
		var m1, m2			: float;
		var useCustom		: bool;
		var s1, s2			: ELightShadowCastingMode;
		var b1, b2			: float;
		var nearChanged		: bool;
		var distChanged		: bool;
		var i				: int;
		if(guiInstalled && menuEnabled)
		{
			transitionLength = GetGUIMultiplier('TransitionInterval');
			switch(GetGUIShadows())
			{
				case NST_Distant:
					s1 = LSCM_None;
					s2 = LSCM_Normal;
					break;
				case NST_Near:
					s1 = LSCM_Normal;
					s2 = LSCM_None;
					break;
				case NST_All:
					s1 = LSCM_Normal;
					s2 = LSCM_Normal;
					break;
				case NST_None:
					s1 = LSCM_None;
					s2 = LSCM_None;
			}
			b1 = 1 - ((float)config.GetVarValue(guiGroup, 'NearBlend'));
			b2 = 1 - ((float)config.GetVarValue(guiGroup, 'FarBlend'));
			for(i = 0; i < lights.Size(); i += 1)
			{
				if(lights[i].isNear && (lights[i].shadowSet != s1 || lights[i].blendSet != b1))
				{
					lights[i].shadowSet = s1;
					lights[i].blendSet = b1;
					lights[i].isStale = true;
				}
				if(lights[i].isDistant && (lights[i].shadowSet != s2 || lights[i].blendSet != b2))
				{
					lights[i].shadowSet = s2;
					lights[i].blendSet = b2;
					lights[i].isStale = true;
				}
			}
		}
		areaInfo = GetCurrentAreaInformation();
		useCustom = guiInstalled && ((bool)config.GetVarValue(guiGroup, 'Override')) && menuEnabled;
		m1 = 1.0; m2 = 1.0;
		// Gather all custom modifiers
		if(areaInfo.cave > 0)
		{
			if(useCustom)
			{
				m1 = GetGUIMultiplier('CaveNearMod');
				m2 = GetGUIMultiplier('CaveFarMod');
			}
		}
		else switch(areaInfo.area)
		{
			case AN_NMLandNovigrad:
			case AN_Velen:
				if(areaInfo.city)
				{
					if(useCustom)
					{
						m1 = GetGUIMultiplier('CityNearMod');
						m2 = GetGUIMultiplier('CityFarMod');
					}
				}
				else
				{
					if(useCustom)
					{
						m1 = GetGUIMultiplier('VelenNearMod');
						m2 = GetGUIMultiplier('VelenFarMod');
					}
				}
				break;
			case AN_Skellige_ArdSkellig:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('SkelligeNearMod');
					m2 = GetGUIMultiplier('SkelligeFarMod');
				}
				break;
			case AN_Kaer_Morhen:
				m2 = 0.5; // Fix for overbright torch lighting in Kaer Morhen (vanilla)
				if(useCustom)
				{
					m1 = GetGUIMultiplier('KaerNearMod');
					m2 = GetGUIMultiplier('KaerFarMod');
				}
				break;
			case AN_Prologue_Village:
			case AN_Prologue_Village_Winter:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('PrologueNearMod');
					m2 = GetGUIMultiplier('PrologueFarMod');
				}
				break;
			case AN_Wyzima:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('WyzimaNearMod');
					m2 = GetGUIMultiplier('WyzimaFarMod');
				}
				break;
			case AN_Island_of_Myst:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('MystNearMod');
					m2 = GetGUIMultiplier('MystFarMod');
				}
				break;
			case AN_Spiral:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('SpiralNearMod');
					m2 = GetGUIMultiplier('SpiralFarMod');
				}
				break;
			case AN_Dlc_Bob:
				if(useCustom)
				{
					m1 = GetGUIMultiplier('ToussaintNearMod');
					m2 = GetGUIMultiplier('ToussaintFarMod');
				}
				break;
		}
		// Multiply by global modifiers
		if(guiInstalled && menuEnabled)
		{
			m1 *= GetGUIMultiplier('GlobalNearMod');
			m2 *= GetGUIMultiplier('GlobalFarMod');
		}
		// Runs once (at start)
		if(delta == 0.0)
		{
			t1 = m1;
			c1 = m1;
			t2 = m2;
			c2 = m2;	
			d1 = 0;
			d2 = 0;
			for(i = 0; i < lights.Size(); i += 1)
			{
				if(lights[i].isNear || lights[i].isDistant)
					lights[i].isStale = true;
			}
		}
		// Set new targets and deltas
		if(t1 != m1)
		{
			t1 = m1;
			d1 = (t1 - c1) / transitionLength;
		}
		if(t2 != m2)
		{
			t2 = m2;
			d2 = (t2 - c2) / transitionLength;
		}
		// Start transition if needed
		if(!transitionActive && (c1 != t1 || c2 != t2))
		{
			entity.AddTimer('Transition', 0.01, true);
			transitionActive = true;
		}
		// Ensure lights are updated
		if(!transitionActive)
			ApplySettings();
	}
	function OnTransition(optional delta : float, optional id : int)
	{
		var nearChanged, distChanged	: bool;
		var i							: int;
		if(d1 != 0)
		{
			c1 += d1*delta;
			if(d1 > 0 && c1 >= t1 || d1 < 0 && c1 <= t1)
			{
				c1 = t1;
				d1 = 0;
			}
			nearChanged = true;
		}
		if(d2 != 0)
		{
			c2 += d2*delta;
			if(d2 > 0 && c2 >= t2 || d2 < 0 && c2 <= t2)
			{
				c2 = t2;
				d2 = 0;
			}
			distChanged = true;
		}
		for(i = 0; i < lights.Size(); i += 1)
			if(nearChanged && lights[i].isNear || distChanged && lights[i].isDistant) lights[i].isStale = true;
		ApplySettings();
		if(transitionActive && c1 == t1 && c2 == t2)
		{
			entity.RemoveTimer('Transition');
			transitionActive = false;
		}
	}
	private function ApplySettings()
	{
		var i		: int;
		var nt		: SNaturalLight;
		for(i = 0; i < lights.Size(); i += 1)
		{
			nt = lights[i];
			if(!nt.isStale) continue;
			if(nt.isNear)
				nt.light.color = GetColorMul(nt.colorSet, c1);
			else
				nt.light.color = GetColorMul(nt.colorSet, c2);
			nt.light.shadowCastingMode = nt.shadowSet;
			nt.light.shadowBlendFactor = nt.blendSet;
			nt.light.envColorGroup = nt.groupSet;
			nt.light.lightFlickering = nt.flickerSet;
			nt.light.brightness = brightness;
			nt.light.SetEnabled(false);
			nt.light.SetEnabled(true);
			nt.light.brightness = 0;
			nt.isStale = false;
			lights[i] = nt;
		}
	}
	private function GetColorMul(c : Color, m : float) : Color
	{
		var mc : Color;
		var v : Vector;
		if(m < 0) m = 0;
		v.X = c.Red * m;
		v.Y = c.Green * m;
		v.Z = c.Blue * m;
		if(v.X > 255) v.X = 255;
		if(v.Y > 255) v.Y = 255;
		if(v.Z > 255) v.Z = 255;
		mc.Red = (byte)v.X;
		mc.Green = (byte)v.Y;
		mc.Blue = (byte)v.Z;
		mc.Alpha = c.Alpha;
		return mc;
	}
	private function GetActiveGUI() : name
	{
		if(!config) config = theGame.GetInGameConfigWrapper();
		if(guiOverride != 'None' && config.GetGroupDisplayName(guiOverride) != "None")
			return guiOverride;
		else if(config.GetGroupDisplayName(GUI) != "None")
			return GUI;
		else
			return 'None';
	}
	private function GetGUIMultiplier(id : name) : float
	{
		return (1 + ((float)config.GetVarValue(guiGroup, id)));
	}
	private function GetGUIShadows() : ENaturalShadowType
	{
		return (ENaturalShadowType)((int)config.GetVarValue(guiGroup, 'Shadows'));
	}
	private function GetCurrentAreaInformation() : SNaturalArea
	{
		var area		: int;
		var defs 		: array<string>;
		var areaInfo 	: SNaturalArea;
		var i			: int;
		areaInfo.city = false;
		GetActiveAreaEnvironmentDefinitions(defs);
		for(i = 0; i < defs.Size(); i += 1)
		{
			switch(defs[i])
			{
				case "env_novigrad_cave":
					areaInfo.cave = NCT_Cave;
					break;
				case "cave_catacombs":
					areaInfo.cave = NCT_Cavern;
					break;
				case "env_skellige_sq209_03":
					areaInfo.cave = NCT_CaveOfDreams;
					break;
				case "env_novigrad_city":
					areaInfo.city = true;
			}
		}
		areaInfo.area = theGame.GetCommonMapManager().GetCurrentArea();
		return areaInfo;
	}
}
//#endmod

//#mod --NaturalTorchlight++ Change class to inherit our custom torch
//class W3LightSource extends W3UsableItem
class W3LightSource extends W3NaturalTorchlight
//#endmod
{
	var worldName : String;
	
	event OnUsed( usedBy : CEntity )
	{
		blockedActions.PushBack( EIAB_HeavyAttacks );
		blockedActions.PushBack( EIAB_SpecialAttackHeavy );
		
		super.OnUsed( usedBy );
		
		worldName =  theGame.GetWorld().GetDepotPath();
		if( StrFindFirst( worldName, "bob" ) < 0 )
		{
			this.PlayEffect( 'light_on' );
		}
		else
		{
			this.PlayEffect( 'light_on_bob' );
		}
		
		if( usedBy == thePlayer )
		{
			// W3EE - Begin
			thePlayer.UnblockAction( EIAB_Counter, 'UsableItem' );
			thePlayer.UnblockAction( EIAB_Parry, 'UsableItem' );
			// W3EE - End
			thePlayer.UnblockAction( EIAB_Signs, 'UsableItem' );
			thePlayer.AddTag( theGame.params.TAG_OPEN_FIRE );
		}
	}

	event OnHidden( usedBy : CEntity )
	{
		if( usedBy == thePlayer )
		{
			thePlayer.RemoveTag( theGame.params.TAG_OPEN_FIRE );
		}
		
		super.OnHidden ( usedBy );
		this.StopEffect( 'light_on' );	
		this.StopEffect( 'light_on_bob' );	
	}
}

class W3ShieldUsableItem extends W3UsableItem
{
	editable var factAddedOnUse : string;
	editable var factValue : int;
	editable var factTimeValid : int;
	editable var removeFactOnHide : bool;
	
	var i : int;
	
	event OnUsed( usedBy : CEntity )
	{
		for( i = 0; i < blockedActions.Size(); i += 1)
		{
			thePlayer.BlockAction( blockedActions[i], 'UsableItem' );
		}
		FactsAdd( factAddedOnUse, factValue, factTimeValid );
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		if( removeFactOnHide )
		{
			FactsRemove( factAddedOnUse );		
		}
	}
}

class W3QuestUsableItem extends W3UsableItem
{
	editable var factAddedOnUse : string;
	editable var factValue : int;
	editable var factTimeValid : int;
	editable var removeFactOnHide : bool;
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed(usedBy);
		FactsAdd( factAddedOnUse, factValue, factTimeValid );
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		super.OnHidden(hiddenBy);
		if ( removeFactOnHide )
		{
			FactsRemove( factAddedOnUse );		
		}
	}
}

class W3MeteorItem extends W3QuestUsableItem
{
	private var collisionGroups : array<name>;
	
	editable var meteorResourceName 	: name;
	
	default meteorResourceName = 'ciri_meteor';
	default itemType = UI_Meteor;
	
	private var meteorEntityTemplate : CEntityTemplate;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		meteorEntityTemplate = (CEntityTemplate)LoadResource(meteorResourceName);
		
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var userPosition : Vector;
		var meteorPosition : Vector;
		var userRotation : EulerAngles;
		
		var meteorEntity :  W3MeteorProjectile;
		
		super.OnUsed( usedBy );
		
		if ( usedBy == thePlayer )
		{
			if ( thePlayer.IsInInterior() )
			{
				thePlayer.DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_here" ));
				return false;
			}
		}
		
		userPosition = usedBy.GetWorldPosition();
		userRotation = usedBy.GetWorldRotation();
		
		
		meteorPosition = userPosition;
		meteorPosition.Z += 50;
		
		meteorEntity = (W3MeteorProjectile)theGame.CreateEntity(meteorEntityTemplate, meteorPosition, userRotation);
		
		
		meteorEntity.Init(NULL);
		meteorEntity.decreasePlayerDmgBy = 0.7;
		meteorEntity.ShootProjectileAtPosition( meteorEntity.projAngle, meteorEntity.projSpeed, userPosition, 500, collisionGroups );
	}
}

class W3EyeOfLoki extends W3QuestUsableItem
{
	editable var environment : name;
	hint environment = "Environment to activate when mask is put while active.";
	editable var effect : CName;
	hint effect = "Effect to play when mask is put while active.";
	editable var activeWhenFact : CName;
	hint activeWhenFact = "Mask is active (playes fx when used) when this fact is true";
	editable var soundOnStart : name;
	hint soundOnStart = "Sound to play when mask is put";
	editable var soundOnStop : name;
	hint soundOnStop = "Sound to play when mask is hidden";

	var envID : int;
	var active : bool;
	
	default itemType = UI_Mask;
	
	event OnUsed( usedBy : CEntity )
	{
		var environmentRes : CEnvironmentDefinition;
	
		
		
		
		blockedActions.PushBack( EIAB_Roll );
		
		blockedActions.PushBack( EIAB_RunAndSprint );
		
		blockedActions.PushBack( EIAB_Parry );
		
		blockedActions.PushBack( EIAB_Counter );
		blockedActions.PushBack( EIAB_HeavyAttacks );
		blockedActions.PushBack( EIAB_SpecialAttackHeavy );
		
		
		blockedActions.PushBack( EIAB_Slide );
	
		super.OnUsed( usedBy );
		
		if( FactsQuerySum( activeWhenFact ) )
		{
			active = true;
			
			thePlayer.SoundEvent( soundOnStart );
			
			theGame.GetGameCamera().PlayEffect( effect );
			
			environmentRes = (CEnvironmentDefinition)LoadResource( environment, true );
			envID = ActivateEnvironmentDefinition( environmentRes, 1000, 1, 1.f );
			theGame.SetEnvironmentID(envID);
		}
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		if( active ) 
		{
			active = false;
			
			theGame.GetGameCamera().StopEffect( effect );

			DeactivateEnvironment( envID, 1 );
			
			thePlayer.SoundEvent( soundOnStop );
			
		}
		super.OnHidden( hiddenBy );	
	}
}

//#mod --SmartLamp++ Inherit our custom lamp class
//class W3MagicOilLamp extends W3QuestUsableItem 
  class W3MagicOilLamp extends W3SmartLamp
//#endmod
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed ( usedBy );
		this.PlayEffect( 'light_on' );
	}
	event OnHidden( usedBy : CEntity )
	{
		super.OnHidden ( usedBy );
		this.StopEffect( 'light_on' );
		
	}
	
}
class W3Potestaquisitor extends W3QuestUsableItem
{
	editable var detectableTag : name;
	hint detectableTag = "Tag for CEntities that cause a reaction";
	editable var detectableRange : float;
	default detectableRange = 40.0;
	hint detectableRange = "Range at which reactions start. Scales at quarters";
	editable var closestRange : float;
	default closestRange = 2.0;
	hint closestRange = "Range at which final reaction starts";
	editable var potestaquisitorFact : string;
	default potestaquisitorFact = "potestaquisitorLevel";
	hint potestaquisitorFact = "Fact name for detection. Is removed when detection is stopped";
	editable var soundEffectType : EFocusModeSoundEffectType;
	hint soundEffectType = "Sound effect to be played on detected CEntities";
	editable var effect : name;
	hint effect = "Effect to play on potestaquisitor when it is taken out.";	
	
	var registeredAnomalies : array< CGameplayEntity >;
	var previousClosestAnomaly : CGameplayEntity;
	
	event OnUsed( usedBy : CEntity )
	{
		this.PlayEffect( effect );
		StartScanningAnomalies(true);
		super.OnUsed(usedBy);
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		this.StopEffect( effect );
		StartScanningAnomalies(false);
		super.OnHidden(hiddenBy);
	}
	
	private function StartScanningAnomalies (shouldStart:bool)
	{
		if (shouldStart)
		{
			registeredAnomalies.Clear();
			ScanningAnomalies (0.0);
			AddTimer('ScanningAnomalies',0.5,true);
		}
		else
		{
			RemoveTimer('ScanningAnomalies');
			StopScanningAnomalies();
		}
	}
	
	private timer function ScanningAnomalies ( dt : float, optional id : int)
	{
		var i, closestAnomalyIndex, registeredAnomaliesSize, foundAnomaliesSize : int;
		var foundAnomalies : array< CGameplayEntity >;
		var foundAnomaliesDistances : array< float >;
		var currentClosestAnomaly : CGameplayEntity;
		var dist : float;
		
		
		FindGameplayEntitiesInRange(foundAnomalies, thePlayer, detectableRange, 100000, detectableTag);
		
		foundAnomaliesSize = foundAnomalies.Size();
		
		for ( i = 0; i < foundAnomaliesSize; i += 1 )
		{
			if(!registeredAnomalies.Contains(foundAnomalies[i]))
				{
					registeredAnomalies.PushBack(foundAnomalies[i]);
					foundAnomalies[i].SetFocusModeSoundEffectType(soundEffectType);
					foundAnomalies[i].SoundEvent( "qu_nml_401_vacuum_detector_loop_start" );
				} 
		}
		
		
		for ( i = 0; i < registeredAnomaliesSize; i += 1 )
		{
			if (!registeredAnomalies[i].HasTag(detectableTag)) 
			{
				registeredAnomalies.Remove(registeredAnomalies[i]);
			}
		}

		registeredAnomaliesSize = registeredAnomalies.Size();
		foundAnomaliesDistances.Resize( registeredAnomaliesSize );
				
		if ( registeredAnomaliesSize > 0 )
		{
			
			for ( i = registeredAnomaliesSize -1; i > -1; i -= 1 )
			{	
				if (!registeredAnomalies[i].HasTag(detectableTag)) 
				{
					registeredAnomalies.Remove(registeredAnomalies[i]);
				}
			}	
			foundAnomaliesSize = foundAnomalies.Size();
			
			
			for ( i = 0; i < registeredAnomaliesSize; i += 1 )
			{
				foundAnomaliesDistances[i] = VecDistance( registeredAnomalies[i].GetWorldPosition(), this.GetWorldPosition() );
			}
			closestAnomalyIndex = ArrayFindMinF( foundAnomaliesDistances );
			
			
			currentClosestAnomaly = registeredAnomalies[closestAnomalyIndex];

			dist = foundAnomaliesDistances[closestAnomalyIndex];
			
			
			
			if (previousClosestAnomaly.GetName() != currentClosestAnomaly.GetName()) 
			{
				previousClosestAnomaly.StopAllEffects();
				previousClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_1" );
				FactsRemove(potestaquisitorFact);
			}
			
			if (dist < detectableRange)
			{
				if (dist > detectableRange*0.75)
				{
					if (FactsQuerySum(potestaquisitorFact) != 1) FactsSet(potestaquisitorFact,1,-1);
					currentClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_1" );
					this.UpdateEffect('signal_01');
				
				}
				else if (dist > detectableRange*0.50)
				{	
					if (FactsQuerySum(potestaquisitorFact) != 2) FactsSet(potestaquisitorFact,2,-1);
					currentClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_2" );
					this.UpdateEffect('signal_02');
				}
				else if (dist > detectableRange*0.25)
				{
					if (FactsQuerySum(potestaquisitorFact) != 3) FactsSet(potestaquisitorFact,3,-1);
					currentClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_3" );
					this.PlayEffect( 'signal_03' );
				}
				else if (dist > closestRange)
				{
					if (FactsQuerySum(potestaquisitorFact) != 4) FactsSet(potestaquisitorFact,4,-1);
					currentClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_4" );
					this.UpdateEffect('signal_04');
				}
				else
				{
					if (FactsQuerySum(potestaquisitorFact) != 5) FactsSet(potestaquisitorFact,5,-1);
					currentClosestAnomaly.SoundEvent( "qu_nml_401_vacuum_detector_intensity_5" );
					this.UpdateEffect('signal_activated');
				}
			}
			else
			{
				if ( FactsDoesExist ( potestaquisitorFact ))
				{
					FactsRemove ( potestaquisitorFact );
				}
			}
			previousClosestAnomaly = currentClosestAnomaly;
		}
	}
	
	private function UpdateEffect (effectName:name)
	{
		this.StopAllEffects();
		this.PlayEffect( effectName );
	}
	
	private function StopScanningAnomalies()
	{
		var i : int;
		var soundOffEffectType : EFocusModeSoundEffectType;

		for ( i = 0; i < registeredAnomalies.Size(); i += 1 )
		{
			soundOffEffectType = FMSET_None;
			registeredAnomalies[i].SetFocusModeSoundEffectType(soundOffEffectType);
			registeredAnomalies[i].SoundEvent( "qu_nml_401_vacuum_detector_loop_stop" );
		}
		
		FactsRemove(potestaquisitorFact);
	}
}


class W3HornvalHorn extends W3QuestUsableItem
{
	
	
	editable var range : float;
	editable var duration : float;
	
	default itemType = UI_Horn;
	
	event OnUsed( usedBy : CEntity )
	{
		var i 				: int;
		var actorsAround 	: array<CActor>;
		var actor 			: CActor;
		var params			: SCustomEffectParams;
		
		super.OnUsed(usedBy);
		
		
		
		params.effectType 	= EET_HeavyKnockdown;
		params.creator 		= thePlayer;
		
		actorsAround = GetActorsInRange( thePlayer, range, -1, '', true );
		for( i = 0; i < actorsAround.Size(); i += 1 )
		{
			actor = actorsAround[ i ];
			if( actor.HasAbility('mon_siren_base') )
			{	
				params.duration 	= duration + RandF()* 2;
				actor.AddEffectCustom( params );
			}
		}
	}	
}


class W3FiendLure extends W3QuestUsableItem
{
	editable var range 			: float;
	editable var duration 		: float;
	editable var cloudEntity 	: CEntityTemplate;
	
	event OnUsed( usedBy : CEntity )
	{
		var l_cloudEntity 	: CEntity;
		var l_destruct		: W3DestructSelfEntity;
		
		super.OnUsed(usedBy);
		
		l_cloudEntity = theGame.CreateEntity( cloudEntity, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		
		l_destruct = (W3DestructSelfEntity) l_cloudEntity;		
		if( l_destruct )
		{
			l_destruct.SetTimer( duration );
		}
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( l_cloudEntity, 'BiesLure', duration, range, 1, -1, true, true );
	}
}
