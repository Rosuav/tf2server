// This function is called from the map OnMapSpawn

function GameModeCheck ()
{
       // checks the game mode and type and the current match
       local nMode = ScriptGetGameMode();
       local nType = ScriptGetGameType();
	   local nRounds = ScriptGetRoundsPlayed();

       // type 0, mode 0 = casual
       // type 0, mode 1 = competitive
       // type 1, mode 0 = arms race
       // type 1, mode 1 = demolition
       // type 1, mode 2 = deathmatch
       // etc 

	   
	if (nMode == 2 && nType == 0)								// If we're running Wingman, enable blockers. Note: Each bombsite has its own relay: "wingman.asite.relay" / "wingman.bsite.relay"
	{
	  EntFire("wingman.bsite.relay", "trigger", 0, 0);
	  EntFire("helicopter.template", "ForceSpawn", 0, 0);
	  EntFire("navblocker.2v2", "BlockNav", 0, 0);
	}
	else
	{
	  EntFire("navblocker.2v2", "UnblockNav", 0, 0);
	}

 }

// This variable is increased every time someone has a workplace related injury (outside of warmup)
 
vInjury <- 0;


function WorkplaceInjury ()
{

local bWarmUp = ScriptIsWarmupPeriod();

	if ( bWarmUp == false )
	{
	 vInjury  += 1
	}

}

// This function is run every map spawn (round restart etc.)

function WorkplaceInjuryDisplay ()
{

	if ( vInjury > 9 )
	{
	 EntFire ("texturetoggle.injury", "SetTextureIndex", 11, 0);
	}
	else if ( vInjury > 0 )
	{
	 EntFire ("texturetoggle.injury", "SetTextureIndex", vInjury, 0);
	}

}





