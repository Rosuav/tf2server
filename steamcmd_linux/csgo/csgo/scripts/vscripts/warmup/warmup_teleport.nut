ARENA1_SCRIPT <- Entities.FindByName(null, "arena1-script");
ARENA1_TSPAWN <- Entities.FindByName(null, "arena1-tspawn");
ARENA1_CTSPAWN <- Entities.FindByName(null, "arena1-ctspawn");

ARENA2_SCRIPT <- Entities.FindByName(null, "arena2-script");
ARENA2_TSPAWN <- Entities.FindByName(null, "arena2-tspawn");
ARENA2_CTSPAWN <- Entities.FindByName(null, "arena2-ctspawn");

ARENA3_SCRIPT <- Entities.FindByName(null, "arena3-script");
ARENA3_TSPAWN <- Entities.FindByName(null, "arena3-tspawn");
ARENA3_CTSPAWN <- Entities.FindByName(null, "arena3-ctspawn");

ARENA4_SCRIPT <- Entities.FindByName(null, "arena4-script");
ARENA4_TSPAWN <- Entities.FindByName(null, "arena4-tspawn");
ARENA4_CTSPAWN <- Entities.FindByName(null, "arena4-ctspawn");

ARENA5_SCRIPT <- Entities.FindByName(null, "arena5-script");
ARENA5_TSPAWN <- Entities.FindByName(null, "arena5-tspawn");
ARENA5_CTSPAWN <- Entities.FindByName(null, "arena5-ctspawn");

TSPAWN_BUSY <- false;
CTSPAWN_BUSY <- false;

SND_SPAWN <- "Player.Respawn";

WARMUP <- ScriptIsWarmupPeriod();

GAMEMODE <- ScriptGetGameMode();
GAMETYPE <- ScriptGetGameType();

COMPMATCH <- false;		// competitive mode
WINGMAN <- false;	// wingman mode

PLAYERLIST_T <- [];	// list of Ts currently not in an arena
PLAYERLIST_CT <- [];	// list of CTs currently not in an arena


// type 0, mode 0 = casual
// type 0, mode 1 = competitive
// type 0, mode 2 = wingman

function Precache()
{
	self.PrecacheScriptSound( SND_SPAWN );
}

function OnPostSpawn()
{
	if (GAMEMODE == 2 && GAMETYPE == 0)		// check if we're running wingman
	{
		WINGMAN = true;
	}
	
	if (GAMEMODE == 1 && GAMETYPE == 0)		// check if we're running comp
	{
		COMPMATCH = true;
	}
	
	if (WARMUP == true && WINGMAN == true || WARMUP == true && COMPMATCH == true)		// enable spawntriggers if we're running the right modes
	{
		EntFireByHandle( self ,"Enable", "", 0.03, null, null );
		SendToConsoleServer( "sv_disable_radar 2" );
	}
	

}



function CheckListT()
{
	
	foreach (index, item in PLAYERLIST_T)  
	{
		if (item.IsValid())
		{
		local MovePlayer = PlayerMoveT(item);	// move the player
		
			if (MovePlayer)
			{
			item.EmitSound(SND_SPAWN);
			PLAYERLIST_T.remove(index);		// remove the player from the list
			}
			else if (!MovePlayer)
				{
				printl ("MovePlayerT failed, leaving player in list");
				}
		}
		else
			{
			PLAYERLIST_T.remove(index);		// remove the player from the list
			}
	}
	
}


function CheckListCT()
{
	
	foreach (index, item in PLAYERLIST_CT)  
	{
		if (item.IsValid())
		{
		local MovePlayer = PlayerMoveCT(item);	// move the player
		
			if (MovePlayer)
			{
			item.EmitSound(SND_SPAWN);
			PLAYERLIST_CT.remove(index);		// remove the player from the list
			}
			else if (!MovePlayer)
				{
				printl ("MovePlayerCT failed, leaving player in list");
				}
		}
		else
			{
			PLAYERLIST_CT.remove(index);		// remove the player from the list
			}
	}
	
}

function PlayerSpawnedT()	// called by trigger in spawn, add each activator to a list, then move them to an arena
{
	local player = activator;
	
	PLAYERLIST_T.push(player);
	
	CheckListT();	// check list and move whoever

}


function PlayerMoveT( player )
{

		
			if (ARENA1_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN == true)
			{
				ARENA1_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN = false;
				ARENA1_SCRIPT.GetScriptScope().PLAYER_T = player;
				player.SetOrigin( ARENA1_TSPAWN.GetOrigin() );
				player.SetAngles( 0, ARENA1_TSPAWN.GetAngles().y, 0 );
				return true;
			}
			else if (ARENA2_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN == true)
			{
				ARENA2_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN = false;
				ARENA2_SCRIPT.GetScriptScope().PLAYER_T = player;
				player.SetOrigin( ARENA2_TSPAWN.GetOrigin() );
				player.SetAngles( 0, ARENA2_TSPAWN.GetAngles().y, 0 );
				return true;
			}
			else if (ARENA3_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN == true && WINGMAN == false)
			{
				ARENA3_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN = false;
				ARENA3_SCRIPT.GetScriptScope().PLAYER_T = player;
				player.SetOrigin( ARENA3_TSPAWN.GetOrigin() );
				player.SetAngles( 0, ARENA3_TSPAWN.GetAngles().y, 0 );
				return true;
			}
			else if (ARENA4_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN == true && WINGMAN == false)
			{
				ARENA4_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN = false;
				ARENA4_SCRIPT.GetScriptScope().PLAYER_T = player;
				player.SetOrigin( ARENA4_TSPAWN.GetOrigin() );
				player.SetAngles( 0, ARENA4_TSPAWN.GetAngles().y, 0 );
				return true;
			}
			else if (ARENA5_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN == true && WINGMAN == false)
			{
				ARENA5_SCRIPT.GetScriptScope().AVAILABLE_TSPAWN = false;
				ARENA5_SCRIPT.GetScriptScope().PLAYER_T = player;
				player.SetOrigin( ARENA5_TSPAWN.GetOrigin() );
				player.SetAngles( 0, ARENA5_TSPAWN.GetAngles().y, 0 );
				return true;
			}
			else
			{
				EntFire ( "!self","RunScriptCode", "CheckListT()", 0.25 );		// queue up a re-check of list
				return false;	// move failed
			}
			
}


function PlayerSpawnedCT()	// called by trigger in spawn, add each activator to a list, then move them to an arena
{
	local player = activator;
	
	PLAYERLIST_CT.push(player);
	
	CheckListCT();	// check list and move whoever
	
}



function PlayerMoveCT( player )
{


		if (ARENA1_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN == true)
		{
			ARENA1_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN = false;
			ARENA1_SCRIPT.GetScriptScope().PLAYER_CT = player;
			player.SetOrigin( ARENA1_CTSPAWN.GetOrigin() );
			player.SetAngles( 0, ARENA1_CTSPAWN.GetAngles().y, 0 );
			return true;
		}
		else if (ARENA2_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN == true)
		{
			ARENA2_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN = false;
			ARENA2_SCRIPT.GetScriptScope().PLAYER_CT = player;
			player.SetOrigin( ARENA2_CTSPAWN.GetOrigin() );
			player.SetAngles( 0, ARENA2_CTSPAWN.GetAngles().y, 0 );
			return true;
		}
		else if (ARENA3_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN == true && WINGMAN == false)
		{
			ARENA3_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN = false;
			ARENA3_SCRIPT.GetScriptScope().PLAYER_CT = player;
			player.SetOrigin( ARENA3_CTSPAWN.GetOrigin() );
			player.SetAngles( 0, ARENA3_CTSPAWN.GetAngles().y, 0 );
			return true;
		}
		else if (ARENA4_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN == true && WINGMAN == false)
		{
			ARENA4_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN = false;
			ARENA4_SCRIPT.GetScriptScope().PLAYER_CT = player;
			player.SetOrigin( ARENA4_CTSPAWN.GetOrigin() );
			player.SetAngles( 0, ARENA4_CTSPAWN.GetAngles().y, 0 );
			return true;
		}
		else if (ARENA5_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN == true && WINGMAN == false)
		{
			ARENA5_SCRIPT.GetScriptScope().AVAILABLE_CTSPAWN = false;
			ARENA5_SCRIPT.GetScriptScope().PLAYER_CT = player;
			player.SetOrigin( ARENA5_CTSPAWN.GetOrigin() );
			player.SetAngles( 0, ARENA5_CTSPAWN.GetAngles().y, 0 );
			return true;
		}
		else
		{
			EntFire ( "!self","RunScriptCode", "CheckListCT()", 0.25 );		// queue up a re-check of list
			return false;	// move failed
		}
		

}
