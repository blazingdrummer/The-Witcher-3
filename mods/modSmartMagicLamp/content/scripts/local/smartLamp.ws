//#mod ++SmartLamp++ Dynamically changes betweeen yellow and green magic light when appropriate

class W3SmartLamp extends W3QuestUsableItem
{
	var lightManager		: CNaturalLightManager;
	
	private const var MOD_NAME	: name;
	default MOD_NAME			= 'SmartLamp';
	
	var activeEffect		: name;
	default activeEffect	= 'None';
	
	var cleanupNeeded		: bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		lightManager = new CNaturalLightManager in this;
		lightManager.Initialize(this);
		
		// Shared settings
		lightManager.SetGUI('SmartLamp');
		lightManager.SetNear(0);
		lightManager.SetNear(1);
		lightManager.SetDistant(2);
		
		// Set current lamp configuratin
		if(IsLampGhostNear())
		{
			SetMagic();
			PlayEffectSingle('light_on_magic');
			activeEffect = 'light_on_magic';
		}
		else
		{
			SetYellow();
			PlayEffectSingle('light_on_yellow');
			activeEffect = 'light_on_yellow';
		}
		
		lightManager.Start();
	}
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed( usedBy );
		
		lightManager = new CNaturalLightManager in this;
		lightManager.Initialize(this);
		
		// Shared settings
		lightManager.SetGUI('SmartLamp');
		lightManager.SetNear(0);
		lightManager.SetNear(1);
		lightManager.SetDistant(2);
		
		// Set current lamp configuratin
		if(IsLampGhostNear())
		{
			SetMagic();
			PlayEffectSingle('light_on_magic');
			activeEffect = 'light_on_magic';
		}
		else
		{
			SetYellow();
			PlayEffectSingle('light_on_yellow');
			activeEffect = 'light_on_yellow';
		}
		
		lightManager.Start();
	}

	event OnHidden( usedBy : CEntity )
	{
		super.OnHidden ( usedBy );
		
		lightManager.Stop();
		delete lightManager;
	}
	
	function Update(optional delta : float, optional id : int)
	{
		var magicMode : bool;
		
		// Handle quest effects
		if(IsEffectActive('light_blinking'))
		{
			if(activeEffect == 'light_on_magic')
				lightManager.SetBrightness(444);
			else
			{
				lightManager.ClearFlickeringPeriod(0);
				lightManager.ClearFlickeringPeriod(1);
				lightManager.ClearFlickeringPeriod(2);
			}
			
			lightManager.SetFlickeringPeriod(0, 0.08);
			lightManager.SetFlickeringPeriod(1, 0.08);
			lightManager.SetFlickeringPeriod(2, 0.08);
			lightManager.SetFlickeringStrength(0, 1);
			lightManager.SetFlickeringStrength(1, 1);
			lightManager.SetFlickeringStrength(2, 1);
			
			cleanupNeeded = true;
		}
		else if(cleanupNeeded)
		{
			if(activeEffect == 'light_on_magic')
			{
				lightManager.ClearFlickeringPeriod(0);
				lightManager.ClearFlickeringPeriod(1);
				lightManager.ClearFlickeringPeriod(2);
			}
			else
			{
				lightManager.SetFlickeringPeriod(0, 0.2);
				lightManager.SetFlickeringPeriod(1, 0.2);
				lightManager.SetFlickeringPeriod(2, 0.2);
			}
			
			lightManager.ClearFlickeringStrength(0);
			lightManager.ClearFlickeringStrength(1);
			lightManager.ClearFlickeringStrength(2);
			
			cleanupNeeded = false;
		}
		
		// Switch light mode
		magicMode = IsLampGhostNear();
		
		if(!cleanupNeeded && magicMode && activeEffect != 'light_on_magic')
		{
			if(IsEffectActive('light_on_yellow'))
			{
				StopEffect('light_on_yellow');
			}
			else
			{
				SetMagic();
				PlayEffectSingle('light_on_magic');
				activeEffect = 'light_on_magic';
			}
		}
		else if(!cleanupNeeded && !magicMode && activeEffect != 'light_on_yellow')
		{
			if(IsEffectActive('light_on_magic'))
			{
				StopEffect('light_on_magic');
			}
			else
			{
				SetYellow();
				PlayEffectSingle('light_on_yellow');
				activeEffect = 'light_on_yellow';
			}
		}
		
		lightManager.OnUpdate(delta, id);
	}
	
	function Transition(optional delta : float, optional id : int)
	{	
		lightManager.OnTransition(delta, id);
	}
	
	function SetMagic()
	{
		lightManager.SetBrightness(0);
		lightManager.Reset();
		lightManager.SetMenuEnabled(false);
	}
	
	private function GetRGBConfigValue(nam : name) : float
	{
		var conf: CInGameConfigWrapper;
		
		conf = theGame.GetInGameConfigWrapper();
		
		return (float)conf.GetVarValue(MOD_NAME, nam);
	}
	
	function SetYellow()
	{
		/* NaturalTorchlight color reference
			
			Near:		85	83	81
			Distant:	23	18	10
			
		*/
		var r1 : float = GetRGBConfigValue('NearRedMod');
		var g1 : float = GetRGBConfigValue('NearGreenMod');
		var b1 : float = GetRGBConfigValue('NearBlueMod');
		var r2 : float = GetRGBConfigValue('FarRedMod');
		var g2 : float = GetRGBConfigValue('FarGreenMod');
		var b2 : float = GetRGBConfigValue('FarBlueMod');
		
		
		var m1 : float = 1.0;
		var m2 : float = 0.6;
		var m3 : float = 1.0;
		
		lightManager.SetColor(0, (byte)(r1*m1), (byte)(g1*m1), (byte)(b1*m1));
		lightManager.SetColor(1, (byte)(r1*m2), (byte)(g1*m2), (byte)(b1*m2));
		lightManager.SetColor(2, (byte)(r2*m3), (byte)(g2*m3), (byte)(b2*m3));
		
		lightManager.SetBrightness(180);
		lightManager.SetGroup(0, ECG_FX_FireLight);
		lightManager.SetGroup(1, ECG_FX_FireLight);
		
		lightManager.SetFlickeringPeriod(0, 0.2);
		lightManager.SetFlickeringPeriod(1, 0.2);
		lightManager.SetFlickeringPeriod(2, 0.2);
		
		lightManager.SetMenuEnabled(true);
	}
	
	function IsLampGhostNear() : bool
	{
		var entities	: array<CGameplayEntity>;
		var i			: int;
		var clue		: W3MonsterClue;
		var magic		: W3MagicLampEntity;
		
		FindGameplayEntitiesInRange(entities, GetWitcherPlayer(), 10.0, 100);
		for(i = 0; i < entities.Size(); i += 1)
		{
			magic = (W3MagicLampEntity)entities[i];
			if(magic)
				return true;
			else
			{
				clue = (W3MonsterClue)entities[i];
				if(clue && clue.GetAutoEffect() == 'ghost_presence')
					return true;
				else
				{
					if(StrFindFirst(entities[i].GetTagsString(), "ghost_mark") > 0)
						return true;
				}
			}
		}
		return false;
	}
}

//#endmod