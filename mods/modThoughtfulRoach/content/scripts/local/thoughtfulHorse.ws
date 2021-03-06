//#mod ++ThoughtfulRoach++ Horse AI tweaks and bugfixes

class W3Thoughtful_Horse_InventoryListener extends IInventoryScriptedListener
{
	private const var MOD_NAME	: name;
	default MOD_NAME			= 'ThoughtfulRoach';
	
	private var inventory		: CInventoryComponent;
	private var isSanitizing	: bool;
	
	private var manager			: W3HorseManager;
	public var parkingAllowed	: bool;
	public var following 		: bool;
	public var followTask 		: CBTTaskHorseSummon;
	
	function Initialize(inv : CInventoryComponent, man : W3HorseManager)
	{
		inventory = inv;
		manager = man;
		Sanitize();
	}
	
	function IsParkingAllowed() : bool
	{
		if(!parkingAllowed)	return false;
		else if(GetInterruptParking() &&
			VecDistanceSquared(thePlayer.GetWorldPosition(),
			thePlayer.GetHorseWithInventory().GetWorldPosition())
			< 25.0)
		{
			SetParkingAllowed(true);
			return false;
		}
		else return true;
	}
	
	function SetParkingAllowed(allow : bool)
	{
		var interval : int;
		interval = GetParkingInterval();
		if(allow && interval > 0)
		{
			parkingAllowed = false;
			manager.RemoveTimer('AllowParking');
			manager.AddTimer('AllowParking', interval);
		}
		else
		{
			parkingAllowed = false;
			manager.RemoveTimer('AllowParking');
		}
	}
	
	function ToggleFollow()
	{
	var textF : string;
	var textNF : string;

	textF = "Roach Following";
	textNF = "Roach Waiting";

	if(GetToggleFollow()) following = !following;
	else following = false;
	SetParkingAllowed(true);

	if(!following){
	thePlayer.DisplayHudMessage( textNF );
	}
	else{
	thePlayer.DisplayHudMessage( textF );
	}
	}
	
	function ClearFollow()
	{
		following = false;
		manager.RemoveTimer('MonitorFollow');
		followTask = NULL;
	}
	
	function IsFollowing() : bool { return following; }
	
	function SetFollowTask(task : CBTTaskHorseSummon)
	{
		followTask = task;
		manager.AddTimer('MonitorFollow', 0.1, true);
	}
	
	// Config
	function GetConfigValue(nam : name) : string
	{
		var conf: CInGameConfigWrapper;
		var value: string;
		
		conf = theGame.GetInGameConfigWrapper();
		
		value = conf.GetVarValue(MOD_NAME, nam);
		return value;
	}
	
	function GetParkingInterval() : int
	{
		var id : int;
		var ret : int;
		
		id =(int)GetConfigValue('ParkingOption');
		
		switch(id)
		{
			case 0: { ret = 1; break; }
			case 1: { ret = 120; break; }
			case 2: { ret = 300; break; }
			case 3: { ret = 600; break; }
			case 4: { ret = 0; break; }
			default: { ret = 0; break; }
		}

		return ret;
	}
	
	function GetInterruptParking() : bool
	{
		return (bool)GetConfigValue('InterruptParking');
	}
	
	function GetToggleFollow() : bool
	{
		return (bool)GetConfigValue('ToggleFollow');
	}
	
	// Hair fixes
	event OnInventoryScriptedEvent( eventType : EInventoryEventType, itemId : SItemUniqueId, quantity : int, fromAssociatedInventory : bool )
	{
		if(!isSanitizing)
		{
			GetWitcherPlayer().GetHorseManager().AddTimer('FixHorseHair', 0, false, false, TICK_Main, false, true);
		}
	}
	
	function AddTailIfNeeded() : bool
	{
		var items : array<SItemUniqueId>;
		
		if(!inventory.HasItem('Horse apex tail'))
		{
			items = inventory.AddAnItem('Horse apex tail');
			inventory.MountItem(items[0]);
			return true;
		}
		return false;
	}
	
	function AddHairIfNeeded() : bool
	{
		var items : array<SItemUniqueId>;
		
		if(!inventory.HasItem('Horse Hair 0') && !inventory.HasItem('Devil Saddle'))
		{
			items = inventory.AddAnItem('Horse Hair 0');
			inventory.MountItem(items[0]);
			return true;
		}
		return false;
	}
	
	function RemoveItem(item : name, cond : bool) : bool
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		if(inventory.HasItem(item) && !cond)
		{
			items = inventory.GetItemsByName(item);
			for(i = 0; i < items.Size(); i += 1)
			{
				inventory.UnmountItem(items[i]);
				inventory.RemoveItem(items[i]);
			}
			return true;
		}
		return false;
	}
	
	function Sanitize()
	{
		var items : array<SItemUniqueId>;
		var fixed : bool;
		
		inventory.UpdateLoot();
		inventory.GetAllItems(items);
		
		isSanitizing = true;
		
		fixed = RemoveItem('Horse Hair 1 Skellige', inventory.HasItem('DLC14 Skellige HorseSaddle')) || fixed;
		fixed = RemoveItem('Horse Hair Nilfgaardian', inventory.HasItem('DLC5 Nilfgaardian HorseSaddle')) || fixed;
		fixed = RemoveItem('Horse Hair 1 ep2', (inventory.HasItem('Toussaint saddle 4') || inventory.HasItem('Toussaint saddle 5') || inventory.HasItem('Toussaint saddle 6'))) || fixed;
		
		fixed = RemoveItem('Horse braided tail 1', (inventory.HasItem('Toussaint saddle 2') || inventory.HasItem('Toussaint saddle 3') || inventory.HasItem('Toussaint saddle 5'))) || fixed;
		fixed = RemoveItem('Horse braided tail 2', (inventory.HasItem('Toussaint saddle') || inventory.HasItem('Toussaint saddle 4') || inventory.HasItem('Toussaint saddle 6'))) || fixed;
		
		fixed = RemoveItem('Horse Hair 0', !inventory.HasItem('Devil Saddle')) || fixed;
		
		fixed = AddTailIfNeeded() || fixed;
		fixed = AddHairIfNeeded() || fixed;
		
		isSanitizing = false;

		if(fixed)
		{
			LogChannel(MOD_NAME, "Detected and fixed one or more issues with horse");
			LogHorse();
		}
	}
	
	function LogHorse()
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		inventory.GetAllItems(items);

		for(i = 0; i < items.Size(); i += 1)
		{
			LogChannel(MOD_NAME, (i+1) + "/" + items.Size() + " : " + inventory.GetItemName(items[i]));
		}
	}
}

//#endmod
