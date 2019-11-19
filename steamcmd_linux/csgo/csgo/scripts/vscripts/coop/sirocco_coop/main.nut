
wave <- 0;
PLAYER_COUNT <- 2;			// overridden by debugmode
PLAYERS_ALIVE <- 0;			// how many players are currently alive 

HARD_MODE <- false;

DEBUG <- false;

RESPAWN_ACTIVE <- false;
LASTSPAWN <- 0;
NEXTSPAWN <- 0;

EXTRACTION_COUNT <- 0;			// how many players are in extraction trigger 
EXTRACTION_SUCCESS <- false;	// bool to make sure end script only plays once

SND_DEPLOY_BOAT <- "coop_deploy.boat";
SND_VO_TEXT <- "Survival.BonusAward";
SND_MISSILE_LAUNCH <- "weapons/smokegrenade/sg_explode_distant.wav";
SND_COUNTDOWN_BEEP <- "UI.CounterBeep";




function Precache()
{
	self.PrecacheScriptSound( SND_DEPLOY_BOAT );
	self.PrecacheScriptSound( SND_VO_TEXT );
	self.PrecacheScriptSound( SND_MISSILE_LAUNCH );
	self.PrecacheScriptSound( SND_COUNTDOWN_BEEP );
}

function debugPrint( text )
{
	if ( DEBUG == false )
		return;

	printl("========DEBUG PRINT======== " + text );
}

function RoundInit()
{

	wave = 0;
	
	EXTRACTION_SUCCESS = false;
	
	HARD_MODE = false;
	
	RESPAWN_ACTIVE = false;

	SendToConsoleServer( "mp_coopmission_bot_difficulty_offset 2" );
	SendToConsoleServer( "bot_coop_idle_max_vision_distance 3000" );
	ScriptCoopSetBotQuotaAndRefreshSpawns( 0 );
	
	EntFire( "@cellblock_entdoor_state-toggle", "Trigger", "", 0 );		// toggle initial state of door indicator
	EntFire( "@skybox_island", "Enable", "", 0 );		// show skybox island visible from readyroom
	
	EnemyWaveSpawnsStop();		// stop wavespawning if previous attempt wiped on holdout
	
}

function HardModeToggle ( bool )
{

	HARD_MODE = bool;

	debugPrint ("Hard mode is currently: " + HARD_MODE);

}

function HardModeVO()		// play this line when player discovers hard mode button
{
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(9016)", 0 );
}

function OnPlayerDie()
{
	
	EntFire( "@radiovoice","RunScriptCode", "PlayVcd( ReturnRandom(9001,9002,9003,9004,9005,0) )", 0 );

}

function PlayerStatus( count )		// triggered from map via eventlisteners
{

	if (count == 3)		// default case, if its more than 2 or less than 0
	{
		debugPrint ("Players alive is in a funky state");
		PLAYERS_ALIVE = 1;
	}
	else
		{
			PLAYERS_ALIVE = count;
			debugPrint ("Players currently alive: " + PLAYERS_ALIVE);
		}

}


function CoopThink()
{
	local CurrentTime = Time();

	RespawnPlayerLoop();		// try respawning dead players, if allowed
	
	ExtractionTriggerCheck();	// looping check for extraction trigger

}


function DebugMode()
{
	DEBUG = true;
	PLAYER_COUNT = 1;
	EntFire( "@coopbutton_debugenable", "Trigger", "", 0 );
	ScriptPrintMessageCenterAll( "Playing in DEBUG mode" );
}


function HardMode()		// modified settings for hard mode
{
	SendToConsoleServer( "mp_coopmission_bot_difficulty_offset 5" );
	SendToConsoleServer( "bot_coop_idle_max_vision_distance 4000" );
	EntFire( "@healthshot_hard", "Kill", "", 0 );
	debugPrint ("Starting in HARD mode");
}

function OnPostSpawn()
{
	SendToConsoleServer( "healthshot_allow_use_at_full 0" );
	SendToConsoleServer( "weapon_reticle_knife_show 1" );
	SendToConsoleServer( "mp_freezetime 1" );
	SendToConsoleServer( "bot_difficulty 2" );
	SendToConsoleServer( "mp_buytime 0" );
	SendToConsoleServer( "mp_startmoney 0" );
}


function TestFunction()		// this function is triggered by relay.test, use for testing random stuff
{

//EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(312)", 1 );	// valeria VO test


//self.EmitSound( SND_COUNTDOWN_BEEP );

//SendToConsole( "setpos 2916.545654 598.396973 1932.453857;setang 8.469973 80.797722 0.000000" );

//HelipadExitOpen();

//FinaleShortcut();

EnemyWaveSpawns();

}


function HightlightLoot()
{

EntFire( "@coopscript", "RunScriptCode", "ToggleEntityOutlineHighlights(" + true + ")", 0 );

}

function ToggleEntityOutlineHighlights( bool )
{

ScriptCoopToggleEntityOutlineHighlights ( bool );

}

function PlayersInCellblockTrigger( amount )
{
	local IsWarmupPeriod = ScriptIsWarmupPeriod();

	if ( amount == PLAYER_COUNT && IsWarmupPeriod == false )
	{
	CellBlockAmbushStart();
	}
}

// =================================================================================
// === game flow ===================================================================
// =================================================================================

function PlayersInReadyRoomDeployTrigger( amount )		
{
	local IsWarmupPeriod = ScriptIsWarmupPeriod();

	if ( amount == PLAYER_COUNT && IsWarmupPeriod == false )
	{
	EntFire( "relay.mission_deploy", "Trigger", "", 0 );
	}
	else if ( amount < PLAYER_COUNT && IsWarmupPeriod == false )
	{
	EntFire( "relay.mission_deploy_abort", "Trigger", "", 0 );
	ReadyRoomDeploy( 5 )
	}

}

function ReadyRoomDeploy( input )
{
	switch ( input )
	{
		case 1: 
		{
		
		self.EmitSound( SND_COUNTDOWN_BEEP );
		
			if (HARD_MODE == true)
			{
				ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingHARDIn3" );
			}
			else
				{
					ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingIn3" );
				}

			break;
		}
		case 2:
		{
		
		self.EmitSound( SND_COUNTDOWN_BEEP );
		
			if (HARD_MODE == true)
			{
				ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingHARDIn2" );
			}
			else
				{
					ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingIn2" );
				}

			break;
		}
		case 3:
		{
		
		self.EmitSound( SND_COUNTDOWN_BEEP );
		
			if (HARD_MODE == true)
			{
				ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingHARDIn1" );
			}
			else
				{
					ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_DeployingIn1" );
				}

			break;
		}
		case 4:
		{
			ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_Deploying" );
			MissionStart();
			break;
		}
		case 5:
		{
			ScriptPrintMessageCenterAll( "#SFUIHUD_InfoPanel_Coop_WaitingDeploying" );

			break;
		}
	}
}



function ReadyRoomStart()		// triggered on map spawn, plays when both players are in ready room
{
local IsWarmupPeriod = ScriptIsWarmupPeriod();

	if (IsWarmupPeriod == false)
	{
		EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(1)", 3 );	// Felix - Hello Sunshine, I know you've missed me but we don't have time to catch up. bla bla briefing
	}
	
	EntFire( "@pfx_readyroom", "Start", "", 0 );

}

function MissionStart()
{

	if (HARD_MODE == true)		// hard mode settings
	{
	HardMode();
	}
	
	EntFire( "@pfx_readyroom", "Stop", "", 1 );		// stop readyroom particle fx

	self.EmitSound( SND_DEPLOY_BOAT );

	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(2)", 5 );	// Felix - My source says the samples are being held in the tunnels beneath the kasbah.  Get in there, take a sample, and get out before anyone knows we were here.
	
	EntFire( "@skybox_island", "Disable", "", 1 );		// hide skybox island visible from readyroom

	EntFire( "deploytrigger.trigger", "Disable", "", 0 );	// disable deploy zone trigger so you can't trigger it multiple times
	EntFire( "counter.mission_deploy", "Disable", "", 0 );	// disable deploy zone counter
	
	EntFire ( "@screenfade", "Fade", "", 0 );
	EntFire ( "@screenfade", "FadeReverse", "", 1.5 );
	EntFire( "teleport.deploy", "Enable", "", 1.1 );
	EntFire( "CT_*", "SetDisabled", "", 0 );
	EntFire( "CT_2", "SetEnabled", "", 0 );
	
	SpawnFirstEnemies(4);
}

function BeachCleared()		// when player presses button on beach, after clearing first wave
{

	EntFire( "gate_spark01", "SparkOnce", "", 1 );
	EntFire( "gate_spark01.snd", "PlaySound", "", 1 );
	EntFire( "gate_spark02", "SparkOnce", "", 1.5 );
	EntFire( "gate_spark02.snd", "PlaySound", "", 1.5 );
	EntFire( "gate_spark02", "SparkOnce", "", 2 );
	EntFire( "gate_spark02.snd", "PlaySound", "", 2 );
	EntFire( "@gate_stairs_open", "Trigger", "", 2 );

}

function DroneFlyBy()
{
	EntFire( "drone1-start", "Trigger", "", 0 );
	EntFire( "drone2-start", "Trigger", "", 0.2 );
	EntFire( "drone3-start", "Trigger", "", 0.3 );
	
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 8 )", 1 );
	
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(3)", 0 );	// Felix - Alright, there's the kasbah.  Secure the area and find a way into the underground tunnels.
}

function KasbahFenceGateOpen()	// when player opens gate to inner kasbah
{

	EntFire( "@relay.kasbah_fence_open", "Trigger", "", 1 );
	EntFire( "@trigger_innerkasbah_spawn", "Enable", "", 1 );		// triggers KasbahInnerEntered() when entered
	
}

function KasbahInnerEntered()	// when player enters kasbah
{

	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 4 )", 1 );
	
}

function FoundTunnelsVO()
{

	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(5)", 0 );	// Felix - There's the entrance!  We don't know what sort of opposition is down there, so stay alert.

}

function CheckpointGuardSpawn()	// when player enters underground tunnels
{

	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 2 )", 0 );

	EntFire( "@pfx_underground", "Start", "", 0 );
	
}

function CellBlockAmbushStart()		// triggered when players are in cellblock
{

EntFire( "@cellblock_doors_first", "Close", "", 0 );
EntFire( "@cellblock_doors_first", "Lock", "", 0.5 );
EntFire( "@cellblock_entdoor_state-toggle", "Trigger", "", 0 );

ToggleEntityOutlineHighlights( false );

EntFire( "@cellblock_playertrigger", "Disable", "", 0 );



EntFire ( "@franz","RunScriptCode", "PlayVcd(16)", 1 );	// Franz - Well hello… now this is a fascinating situation. bla bla totally not a baddie

EntFire( "@coopscript", "RunScriptCode", "CellBlockAmbush()", 30 );



}

function CellBlockAmbush()
{

	EntFire( "@relay.cell_lights_off", "Trigger", "", 0 );		// lights are fully off after 1 second
	
	EntFire ( "@franz","RunScriptCode", "PlayVcd(17)", 0.5 );	//Franz - Attention! Whomever brings me the head of these intruders will be granted their freedom.

	EntFire( "block1-relay.open", "Trigger", "", 1 );		// each block takes 1.5 sec to  open
	EntFire( "block2-relay.open", "Trigger", "", 3 );
	EntFire( "block3-relay.open", "Trigger", "", 5 );
	EntFire( "block4-relay.open", "Trigger", "", 7 );
	EntFire( "block5-relay.open", "Trigger", "", 9 );

	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 12 )", 10.5 );
	EntFire( "@cellblock_clipbrush", "Disable", "", 10.5 );

	EntFire( "@relay.warning_light.on", "Trigger", "", 11 );
	EntFire( "prisonalarm.snd", "PlaySound", "", 11 );

}


function CellBlockAmbushEnd()		// triggered when players have killed a bunch of dudes
{

EntFire ( "@franz","RunScriptCode", "PlayVcd(18)", 3 );	//Franz - Let's see who the lucky winnner is..

EntFire( "prisonalarm.snd", "FadeOut", "1", 1 );
EntFire( "@relay.warning_light.off", "Trigger", "", 3 );
EntFire( "@relay.cell_lights_on", "Trigger", "", 5 );

EntFire( "@coopscript", "RunScriptCode", "CellBlockReinforcementsCat()", 10 );
}

function CellBlockReinforcementsCat()	// triggered after knife fight
{
EntFire ( "@franz","RunScriptCode", "PlayVcd(19)", 0 );	//Franz - Hm. Impressive.  Your talents are wasted by serving Felix, you have so much more potentional.  If you survive, perhaps I can show you what you're really capable of.

EntFire( "@flash_cellblock", "Trigger", "", 12 );		// flashbang cellblock

EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 3 )", 14 );

EntFire( "@clip_underground_backtrack", "Disable", "", 0 );
}

function CellBlockReinforcements()	// triggered after catwalk guys are dead
{
EntFire( "@cellblock_doors_second", "Unlock", "", 3 );
EntFire( "@cellblock_doors_second", "Open", "", 4 );
EntFire( "@cellblock_exitdoor_state-toggle", "Trigger", "", 2 );
EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 3 )", 3 );
}

function MedicalAreaOpened()		// triggered when players have unlocked medical area with coop buttons
{

EntFire( "@meddoor_state-toggle", "Trigger", "", 0 );
EntFire( "@macguffin_enable", "Trigger", "", 0 );

EntFire( "@cellblock_doors_second", "Close", "", 0 );
EntFire( "@cellblock_doors_second", "Lock", "", 0 );

EntFire( "@clip_underground_backtrack", "Enable", "", 0 );

EntFire( "@prop_viruscase", "SetGlowEnabled", "", 1 );

ToggleEntityOutlineHighlights( false );
}

function MacGuffinFound()	// when player has found mcguffin, start breach charge ambush
{

	EntFire ( "@franz","RunScriptCode", "PlayVcd(20)", 1 );	//Franz - And so you've found what you were looking for.  But consider this: Why do you think Felix knows so much about this place?  Perhaps you don't have the whole story.  Perhaps I am not the demon he is making me out to be.  

	EntFire( "@coopscript", "RunScriptCode", "MedicalAreaBreach()", 19 );
	
}

function MedicalAreaBreach()
{
	EntFire( "@chainlinkdoor_postbreach", "Unlock", "", 0 );
	EntFire( "@chainlinkdoor_postbreach", "Open", "", 1 );
	
	EntFire( "@snd.prebreach_ready", "PlaySound", "", 2.5 );		// "In position" VO 
	
	EntFire( "breach1-relay.breach", "Trigger", "", 5 );
	EntFire( "@pfx_underground_breach1", "Start", "", 11 );
	
	EntFire( "breach2-relay.breach", "Trigger", "", 6 );		// these take 6 seconds to go off
	EntFire( "@pfx_underground_breach1", "Start", "", 12 );
	
	EntFire( "@breachwalls_clip", "Disable", "", 12 );
	
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 6 )", 11.5 );		// 1 heavy
}

function PlayersExitTunnels()	// when player exits tunnels
{
	
	EntFire( "drone4-start", "Trigger", "", 0 );
	EntFire( "drone5-start", "Trigger", "", 0.15 );

	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(8)", 3 );	//Felix - Glad you made it out of there in one piece! We have a helicopter standing by for extraction, get down to the coast and secure a landing zone!

	EntFire( "@trigger_falldamage", "Enable", "", 0 );
	EntFire( "@pfx_underground", "Stop", "", 8 );
	
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 5 )", 0 );
	
}

function RadarCleared()	// when player has cleared radar station exterior
{
	
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(9)", 1 );	//Felix - There's a helipad nearby, secure it and we'll get you out of there!
	
	EntFire( "@helipad_lights", "Trigger", "", 0 );
	EntFire( "@relay_radar_blinkydo", "Trigger", "", 0 );		// buncha repeating timers
	
	EntFire( "@pfx_radarconn", "Start", "", 0 );
	
	EntFire( "@radar_frontdoor", "SetGlowEnabled", "", 1 );
	EntFire( "@radar_frontdoor", "Unlock", "", 1.5 );
	
}

function RadarTunnelsEntered()	// when player has entered radio station stairs
{

	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 4 )", 1 );
	EntFire( "@trigger_falldamage", "Disable", "", 1 );
	EntFire( "@chainlinkdoor_radarconn", "Unlock", "", 1 );
	
}

function EnemyWaveSpawns()		// helipad fight
{

	EntFire( "@pfx_radarconn", "Stop", "", 0 );		// stop particle fx for connector

	SendToConsoleServer( "mp_randomspawn_los 1" );
	SendToConsoleServer( "mp_randomspawn_dist 2400" );
	SendToConsoleServer( "mp_use_respawn_waves 1" );
	SendToConsoleServer( "mp_respawnwavetime_t 4" ); 
	
	EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( false )", 1 );		// players should not respawn
	
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(10)", 1 );	//Felix - Great work! The helicopter has been dispatched, ETA one minute.

	
	EntFire ( "@franz","RunScriptCode", "PlayVcd(23)", 10 );	//Franz - Attention! Stop these intruders, or find yourself in the next round of experiments.
	
	EntFire( "@snd.finale_music", "PlaySound", "", 16 );		// music

	EntFire( "@coopscript", "RunScriptCode", "CoopSetBotQuotaAndRefreshSpawns( 4 )", 0.5 );
	EntFire( "@coopscript", "RunScriptCode", "CoopMissionSetNextRespawnIn( 6 )", 14 );
	
	EntFire( "@coopscript", "RunScriptCode", "HelipadMissileAttack()", 60 );

	EntFire( "@coopscript", "RunScriptCode", "EnemyWaveSpawnsStop()", 65 );		// stop wave respawning as helicopter flies in

	wave++;  // up the wave number manually

}

function FinaleShortcut()		// shortcut to finale fight
{

// setpos 6674.558105 5778.740723 480.093811;setang 3.717988 -76.385696 0.000000

	SendToConsole( "setpos 6674.558105 5778.740723 480.093811;setang 3.717988 -76.385696 0.000000" );

	wave = 11;

		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave06", "SetEnabled", "", 0 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_10", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
		
		EntFire( "@coopscript", "RunScriptCode", "HelipadExitOpen()", 1 );

}

function HelipadMissileAttack()
{
	EntFire( "@trigger_mollybox", "Disable", "", 0 );

	EntFire ( "@franz","RunScriptCode", "PlayVcd(24)", 0 );	//Franz - Maybe I’m not motivating you properly. This should help.

	EntFire( "@coopscript", "RunScriptCode", "MissileLaunchSound(" + 1 + ")", 3 );		// play launch sound
	EntFire( "missile1b-launch", "Trigger", "", 10 );
	EntFire( "@coopscript", "RunScriptCode", "MissileImpact(5)", 13 );		// spawn DZ zone on impact

	EntFire( "@coopscript", "RunScriptCode", "MissileLaunchSound(" + 1 + ")", 5 );		// play launch sound
	EntFire( "missile1-launch", "Trigger", "", 12 );
	EntFire( "@coopscript", "RunScriptCode", "MissileImpact(1)", 15 );		// spawn DZ zone on impact


	EntFire( "helicopter3.animated", "Enable", "", 1 );
	EntFire( "helicopter3.animated", "SetAnimation", "coop_flyby1", 1 );
	EntFire( "helisoundsync", "Trigger", "", 1 );
	EntFire( "helicopter3.animated", "Disable", "", 30 );

	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(11)", 11 );	//Felix - Incoming missile!
}

function HelipadExitOpenSimple()
{
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(12)", 8 );	//Felix - We’re re-routing the helicopter to a new landing zone. Follow the coast and get out of there!

	EntFire( "@rollup_door", "Open", "", 1 );
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 3 )", 1 );
}

function HelipadExitOpen()		// triggered when helipad fight is over
{

EntFire( "@trigger_mollybox", "Disable", "", 0 );

EntFire ( "@franz","RunScriptCode", "PlayVcd(24)", 0 );	//Franz - Maybe I’m not motivating you properly. This should help.

EntFire( "@coopscript", "RunScriptCode", "MissileLaunchSound(" + 1 + ")", 3 );		// play launch sound
EntFire( "missile1b-launch", "Trigger", "", 10 );
EntFire( "@coopscript", "RunScriptCode", "MissileImpact(5)", 13 );		// spawn DZ zone on impact

EntFire( "@coopscript", "RunScriptCode", "MissileLaunchSound(" + 1 + ")", 5 );		// play launch sound
EntFire( "missile1-launch", "Trigger", "", 12 );
EntFire( "@coopscript", "RunScriptCode", "MissileImpact(1)", 15 );		// spawn DZ zone on impact


EntFire( "helicopter3.animated", "Enable", "", 1 );
EntFire( "helicopter3.animated", "SetAnimation", "coop_flyby1", 1 );
EntFire( "helisoundsync", "Trigger", "", 1 );
EntFire( "helicopter3.animated", "Disable", "", 30 );

EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(11)", 11 );	//Felix - Incoming missile!

EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(12)", 24 );	//Felix - We’re re-routing the helicopter to a new landing zone. Follow the coast and get out of there!

EntFire( "@rollup_door", "Open", "", 13 );
EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 3 )", 13 );



}


function BeachFinaleEntered()
{

	EntFire( "helicopter3.animated", "Disable", "", 0 );		// disable prev heli
	EntFire( "helicopter2.animated", "Enable", "", 0 );		// hovering helicopter
//	EntFire( "helidust.timer", "Enable", "", 0 );		// hovering helicopter particle effects - triggered via map trigger instead
	EntFire( "@trigger.beach_helipfx_start", "Enable", "", 0 );		// helicopter particle fx trigger

	EntFire( "extractchopper.snd", "PlaySound", "", 0 );		// hovering helicopter sound

	EntFire( "missile2-launch", "Trigger", "", 0 );
	EntFire( "@coopscript", "RunScriptCode", "MissileImpact(2)", 3 );		// spawn DZ zone on impact

	EntFire( "missile6-launch", "Trigger", "", 2 );
	EntFire( "@coopscript", "RunScriptCode", "MissileLaunchSound(" + 6 + ")", 0 );		// play launch sound
	EntFire( "@coopscript", "RunScriptCode", "MissileImpact(6)", 5 );		// spawn DZ zone on impact
	
	EntFire( "trigger.extraction_actual", "Enable", "", 0 );	
	
	EntFire( "@trigger.beach_bunker_spawn", "Enable", "", 0 );		
	EntFire( "@trigger.beach_bunker_spawn_cancel", "Enable", "", 0 );		
	
	EntFire( "@trigger.missile3_launch", "Enable", "", 0 );		
	
	EntFire( "@trigger.beach_hill_spawn", "Enable", "", 0 );	
	EntFire( "@trigger.beach_hill_spawn_cancel", "Enable", "", 0 );	

	EntFire( "@trigger.missile4_launch", "Enable", "", 0 );		

	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 2 )", 0 );	
	
	DZoneBridge();		// create a zona de peligro by the bridge
	DZoneHeliCliff();	// create a kjempefarlig sone by the bridge
	
	EntFire( "@sound_beachbunker_alarm", "PlaySound", "", 2 );
	
}

function DZoneBridge()
{

		local Position = Entities.FindByName(null, "missile_bridge_dummy-end.position");
		local Vector = Position.GetCenter();
			
		debugPrint (Position);
		debugPrint (Vector);

		ScriptMissionCreateAndDetonateDangerZone( Vector, Vector );

}

function DZoneHeliCliff()
{

		local Position = Entities.FindByName(null, "missile_helicliff_dummy-end.position");
		local Vector = Position.GetCenter();
			
		debugPrint (Position);
		debugPrint (Vector);

		ScriptMissionCreateAndDetonateDangerZone( Vector, Vector );

}

function MissileLaunchSound( number )
{

	local name = "missile" + number + "-missile.mdl"
	local emitter = Entities.FindByName(null, name);

	emitter.EmitSound( SND_MISSILE_LAUNCH );

}

function MissileImpact( missile )
{
local Position = null;
local Vector = null;

local StartPosition = null;
local StartVector = null;
local EndPosition = null;
local EndVector = null;

	switch ( missile )
	{
		case 1: 
		{	
			StartPosition = Entities.FindByName(null, "missile1-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile1-impact.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 2:
		{
			StartPosition = Entities.FindByName(null, "missile2-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile2-impact.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 3:
		{
			StartPosition = Entities.FindByName(null, "missile3-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile3-end.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 4:
		{
			StartPosition = Entities.FindByName(null, "missile4-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile4-end.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 5:
		{
			StartPosition = Entities.FindByName(null, "missile1b-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile1b-impact.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 6:
		{
			StartPosition = Entities.FindByName(null, "missile6-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile6-impact.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
		case 7:
		{
			StartPosition = Entities.FindByName(null, "missile7-impact.position");
			StartVector = StartPosition.GetCenter();
			
			EndPosition = Entities.FindByName(null, "missile7-end.position");
			EndVector = EndPosition.GetCenter();
			
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			break;
		}
	}
	
			debugPrint (StartPosition);
			debugPrint (StartVector);
			debugPrint (EndPosition);
			debugPrint (EndVector);
			
			ScriptMissionCreateAndDetonateDangerZone( StartVector, EndVector );
	
}


function BeachBunkerSpawn()
{
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 5 )", 1 );

	EntFire ( "@franz","RunScriptCode", "PlayVcd(25)", 2 );	//Franz - Stop them!
}

function BeachHillSpawn()	
{
	EntFire( "@coopscript", "RunScriptCode", "SpawnNextWave( 6 )", 0 );
}

function VoExtractionNag()		// triggered from map 
{
EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(14)", 0 );	//Felix - Pick it up! You need get out of there, now!
}



function EnemyWaveSpawnsStop()		// called in roundinit as well
{
	SendToConsoleServer( "mp_randomspawn_los 0" );
	SendToConsoleServer( "mp_use_respawn_waves 2" );
	SendToConsoleServer( "mp_respawnwavetime_t 5" );
}


function ExtractionTriggerCount ( count )
{
EXTRACTION_COUNT = count;

debugPrint("Players in extraction trigger: " + EXTRACTION_COUNT)
}

function ExtractionTriggerCheck()
{
	if (EXTRACTION_COUNT == PLAYERS_ALIVE && EXTRACTION_COUNT > 0 && EXTRACTION_SUCCESS == false)
	{
	PlayerReachedHelicopter();
	}
}

function PlayerReachedHelicopter()		// game over
{
	EXTRACTION_SUCCESS = true;
	
	EntFire( "@relay.outrom_cam", "Trigger", "", 0 );
	EntFire( "relay.extract_nag_final", "CancelPending", "", 0 );
	
	EntFire ( "@screenfade_hold", "Fade", "", 3 );
	
//	SendToConsole( "cheer" );		// make player character play a cheer line
	
	EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(28)", 1 );	//Felix - Once you get home that sample is going to the lab straight away… time to find out what Kreigeld is up to.
	
	EntFire( "@game_over", "EndRound_CounterTerroristsWin", "2", 0 );	
	
	
}



// =================================================================================
// === game_coopmission_manager functions ( @coopmanager ) =========================
// =================================================================================

function OnMissionCompleted()
{

	
}

function OnRoundLostKilled()
{

	EntFire( "@radiovoice","RunScriptCode", "PlayVcd( ReturnRandom(9011,9012,9013,9015,0) )", 0 );
	
}

function OnRoundLostTime()
{

	EntFire( "@radiovoice","RunScriptCode", "PlayVcd( ReturnRandom(9006,9007,9008,9009,9010,0) )", 0 );
	
}

function OnRoundReset() 
{

	RoundInit();
}

function OnSpawnsReset()
{
	EntFire( "enemy.*", "SetDisabled", "", 0 );
	EntFire( "enemy.wave01", "SetEnabled", "", 0 );
	EntFire( "CT_*", "SetDisabled", "", 0 );
	EntFire( "CT_1", "SetEnabled", "", 0 );
}

function OnWaveCompleted()
{	

	if ( wave == 1 )		// beach cleared
	{
		debugPrint ("Wave 1 defeated, beach squad");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave02", "SetEnabled", "", 0 );
		
		EntFire( "beachbutton-button_enable", "Trigger", "", 1 );

		
		EntFire( "eventlisten.spot01", "Enable", "", 1 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_2", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
		
	}
	else if ( wave == 2 )		// kasbah exterior cleared
	{
		debugPrint ("Wave 2 defeated, kasbah exterior");
	
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave02_inner", "SetEnabled", "", 0 );

		EntFire( "spot01-relay.off", "Trigger", "", 2 );
		
		EntFire( "kasbahfencegatebutton-button_enable", "Trigger", "", 1 );
		
		EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(4)", 1 );	// Felix - You don't put this many guards around something that doesn't need defending.  The way in has to be around here somewhere.
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_3", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 3 )		// kasbah interior cleared
	{
		debugPrint ("Wave 3 defeated, kasbah courtyard");
	
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.checkpoint_guards", "SetEnabled", "", 0 );
		
		EntFire( "@chainlinkdoor_innerkasbah", "Unlock", "", 0 );
		EntFire( "@chainlinkdoor_innerkasbah", "SetGlowEnabled", "", 0 );
		
		EntFire( "@trigger.checkpoint_spawn", "Enable", "", 0 );
		
		EntFire( "@container_unlock", "Trigger", "", 0 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_4", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 4 )		// checkpoint guards cleared
	{
		debugPrint ("Wave 4 defeated, checkpoint guards");
	
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.cellblock", "SetEnabled", "", 0 );
		
		
		EntFire( "@checkpoint_button.func", "Unlock", "", 1 );
		EntFire( "@checkpoint_button.mdl", "SetGlowEnabled", "", 1 );
		
		EntFire( "@cellblock_playertrigger", "Enable", "", 0 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_5", "SetEnabled", "", 0 );
		
		EntFire ( "@radiovoice","RunScriptCode", "PlayVcd(6)", 2 );	// Felix - The tunnels are causing a lot of interference, I'm going to have to go dark until you're back out.
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );

	}
	else if ( wave == 5 )		// cellblock knifefight done
	{
		debugPrint ("Wave 5 defeated, knife fight");
	
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_6", "SetEnabled", "", 0 );
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.cellblock_postbrawl_cat", "SetEnabled", "", 0 );

		EntFire( "@coopscript", "RunScriptCode", "CellBlockAmbushEnd()", 1 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 6 )		// cellblock catwalk guards dead
	{
		debugPrint ("Wave 6 defeated, catwalk guards");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.cellblock_postbrawl", "SetEnabled", "", 0 );

		EntFire( "@coopscript", "RunScriptCode", "CellBlockReinforcements()", 1 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 7 )		// cellblock reinforcements cleared
	{
		debugPrint ("Wave 7 defeated, cellblock reinforcements");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.breachattack", "SetEnabled", "", 0 );
		EntFire( "@medical_doors_button_unlock", "Trigger", "", 1 );
		EntFire( "@steamburst_timer", "Enable", "", 1 );				// hint steam for climb route, disabled again via map trigger
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 8 )		// breach charge guys cleared
	{
		debugPrint ("Wave 8 defeated, breach attack");
	
		
		EntFire ( "@franz","RunScriptCode", "PlayVcd(21)", 1 );	//Franz - It's really not in your best interest to leave.  Stay.  Return the sample.  Join my experiments, and if you emerge victorious I will show you how the world truly works.  You could be so much more than Felix's catspaw.
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave03", "SetEnabled", "", 0 );

		EntFire( "@trigger_radarspawn", "Enable", "", 0 );
		
		EntFire( "@door_to_pipetunnels", "Unlock", "", 0 );
		EntFire( "@door_to_pipetunnels", "SetGlowEnabled", "", 0 );
		
		EntFire( "@clip_underground_backtrack", "Disable", "", 0 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_7", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 9 )		// radar station cleared
	{
		debugPrint ("Wave 9 defeated, radar squad");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave04", "SetEnabled", "", 0 );

		EntFire( "@trigger_radarstairs", "Enable", "", 0 );

		RadarCleared();
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_8", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
		
	}
	else if ( wave == 10 )
	{
		debugPrint ("Wave 10 defeated, radar underground squad");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave05", "SetEnabled", "", 0 );
		
		EntFire( "trigger.extraction", "Enable", "", 1 );
		EntFire( "@radartunnelexit_enable", "Trigger", "", 1 );
		EntFire( "@relay_radar_blinkydont", "Trigger", "", 0 );		// disable buncha repeating timers
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_9", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
	}
	else if ( wave == 11 )
	{
		debugPrint ("Wave 11 defeated, holdout fight");
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave06", "SetEnabled", "", 0 );
		
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_10", "SetEnabled", "", 0 );
		
		EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( true )", 1 );
		
		//EntFire( "@coopscript", "RunScriptCode", "HelipadExitOpen()", 1 );
		
		EntFire( "@coopscript", "RunScriptCode", "HelipadExitOpenSimple()", 1 );
		
	}
	else if ( wave == 12 )
	{
		debugPrint ("Wave 12 defeated, rollup door guys");
	
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_11", "SetEnabled", "", 0 );
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave07_init", "SetEnabled", "", 0 );
	
		EntFire( "@helipad_exitdoor", "Unlock", "", 0 );
		EntFire( "@helipad_exitdoor", "SetGlowEnabled", "", 0 );
		
	}
	else if ( wave == 13 )
	{
		debugPrint ("Wave 13 defeated, beach mini squad");
	
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_12", "SetEnabled", "", 0 );
	
		EntFire( "@trigger.beach_bunker_spawn_cancel", "Disable", "", 0 );
	
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave07", "SetEnabled", "", 0 );
	}
	else if ( wave == 14 )
	{
		debugPrint ("Wave 14 defeated, beach bunker squad");
	
		EntFire( "CT_*", "SetDisabled", "", 0 );
		EntFire( "CT_13", "SetEnabled", "", 0 );
	
		EntFire( "@trigger.beach_hill_spawn_cancel", "Disable", "", 0 );
		EntFire( "enemy.*", "SetDisabled", "", 0 );
		EntFire( "enemy.wave08", "SetEnabled", "", 0 );
	}
}

// =================================================================================
// === spawning functions ==========================================================
// =================================================================================

function SpawnFirstEnemies( amount )
{
	ScriptCoopMissionSpawnFirstEnemies( amount );	
	ScriptCoopResetRoundStartTime();
	wave++;
}

function SpawnNextWave( amount )
{
	ScriptCoopMissionSpawnNextWave( amount );
	wave++;
	
	EntFire( "@coopscript", "RunScriptCode", "RespawnPlayerState( false )", 1 );		// always turn off player spawning when spawning new enemies
}

function CoopSetBotQuotaAndRefreshSpawns( nQuota )
{
	ScriptCoopSetBotQuotaAndRefreshSpawns( nQuota );
}

function CoopMissionSetNextRespawnIn( flSeconds )
{
	ScriptCoopMissionSetNextRespawnIn( flSeconds, false );
}

function RespawnPlayerState( state )
{
	if (state == true)
	{
	debugPrint ("PLAYER RESPAWNING ACTIVE");
	RESPAWN_ACTIVE = true;
	
	ToggleEntityOutlineHighlights( true );		// highlight dropped guns
	}
	if (state == false)
	{
	debugPrint ("PLAYER RESPAWNING DISABLED");
	RESPAWN_ACTIVE = false;
	
	ToggleEntityOutlineHighlights( false );		// don't highlight dropped guns
	}
}

function RespawnPlayerLoop()
{
local time = Time();

	if (RESPAWN_ACTIVE == true && time > NEXTSPAWN)
	{
	LASTSPAWN = Time();
	NEXTSPAWN = LASTSPAWN + 1;
	debugPrint ("Respawning friendly player at " + LASTSPAWN + ", will try again at " + NEXTSPAWN + " sec");
	ScriptCoopMissionRespawnDeadPlayers();
	}
}