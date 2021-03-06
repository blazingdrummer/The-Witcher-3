//#mod NaturalTorchlight Custom torch class

class W3NaturalTorchlight extends W3UsableItem
{	
	var lightManager	: CNaturalLightManager;
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed( usedBy );
		
		lightManager = new CNaturalLightManager in this;
		lightManager.Initialize(this);
		
		lightManager.SetBrightness(180.0);
		lightManager.SetNear(0);
		lightManager.SetDistant(1);
		
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
		lightManager.OnUpdate(delta, id);
	}
	
	function Transition(optional delta : float, optional id : int)
	{	
		lightManager.OnTransition(delta, id);
	}
}

//#endmod