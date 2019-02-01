// This function is called from the map OnMapSpawn

function GameModeCheck ()
{
       // checks the game mode and type and the current match
       local nMode = ScriptGetGameMode();
       local nType = ScriptGetGameType();

       // type 0, mode 0 = casual
       // type 0, mode 1 = competitive
       // type 1, mode 0 = arms race
       // type 1, mode 1 = demolition
       // type 1, mode 2 = deathmatch
       // etc 

	   
	if (nMode == 2 && nType == 0)								// If we're running Wingman, enable blockers. Note: Each bombsite has its own relay: "wingman.asite.relay" / "wingman.bsite.relay"
	{
	  EntFire("wingman.bsite.relay", "trigger", 0, 0);
	  
	}

 }

 