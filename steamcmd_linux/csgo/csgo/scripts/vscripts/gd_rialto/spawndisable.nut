// This function is called from the map OnMapSpawn
function DisableSpawns()
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

	   
	if (nType != 4)
	{
	  EntFire("spawnpoint.guardian", "SetDisabled", "", 0, null);
	}
  
 }

 
 
 