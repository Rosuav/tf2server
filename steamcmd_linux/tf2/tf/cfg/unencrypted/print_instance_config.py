#!/usr/bin/env python3

import os
import sys
import getopt
import re, socket

iInstanceNum = -1
sHostName = ''
sFQDN = socket.getfqdn()
sClusterRegex = re.match(".*\.([a-z]+-[0-9]+)..*", sFQDN) if sFQDN else None
sClusterNode = sClusterRegex.group(1) if sClusterRegex else None
iRegion = -1

opts, args = getopt.getopt( sys.argv[1:], '', [ "num=", "host=", "region=", "node=" ] )
for o, a in opts:
    if o in ('--num'):
        iInstanceNum = int(a)
    elif o in ('--host'):
        sHostName = a
    elif o in ('--region'):
        iRegion = int(a)
    elif o in ('--node'):
        sClusterNode = a
    else:
        assert 'Unhandled option ' + o

if iInstanceNum < 0:
    raise Exception('Missing or invalid --num')
if len(sHostName) <= 0:
    raise Exception('Missing or invalid --host')

tf_mm_trusted = 1 # code=0, srcdsd=1
maxplayers = 24
tf_mm_servermode = 0  # code default=0
sStartServerCmd = 'randommap'
sv_minrate = 10000 #code=3500, srcds web=10000
tf_mm_strict = 0 #code=0
sv_vote_issue_nextlevel_allowed = 1 #code=1
sv_vote_issue_changelevel_allowed = 0 #code=0
sv_vote_issue_changelevel_allowed_mvm = 0 #code=0
sv_vote_issue_extendlevel_allowed = 1 #code=1
sv_tags = "valve"
sLocation = ''
mp_stalemate_enable = 0
mp_stalemate_meleeonly = 0
servercfgfile = None
hostname = None
mapcyclefile = None

# Set to true if we can't handle our parameters, throwing an error is bad for the way our clusters work.
misconfigured = False

# Map the cluster numbers used by the cluster system to the ones
# used historically on TF.
dictClusterRegionTable = {
     1: { 'location': 'Washington'   }, # US West
     2: { 'location': 'Virginia'     }, # US East
     3: { 'location': 'Frankfurt'    }, # Europe
     5: { 'location': 'Singapore'    }, # Singapore
     6: { 'location': 'Dubai'        }, # Middle East
     8: { 'location': 'Stockholm'    }, # Europe
     7: { 'location': 'Sydney'       }, # Australia
     9: { 'location': 'Vienna'       }, # Europe
    10: { 'location': 'Brazil'       }, # South America
    11: { 'location': 'Johannesburg' }, # South Africa
    14: { 'location': 'Chile'        }, # Chile
    15: { 'location': 'Peru'         }, # Peru
    16: { 'location': 'Mumbai'       }, # India
    19: { 'location': 'Tokyo'        }, # Japan (region code is 'Asia' as we lack anything more specific)
    21: { 'location': 'Madrid'       }, # Europe
    22: { 'location': 'LA'           }, # US SouthWest
    23: { 'location': 'Atlanta'      }, # US SouthEast
    24: { 'location': 'Hong Kong'    }, # Hong Kong (region code 'Asia')
    26: { 'location': 'Chennai'      }, # Chennai, India
    27: { 'location': 'Chicago'      }, # Chicago, Illinois
    28: { 'location': 'Warsaw'       }, # Warsaw, Poland
}
dictClusterData = dictClusterRegionTable.get( iRegion, None )
if dictClusterData:
    sLocation = dictClusterData['location']

#
# Set proportions of server types here.
#
# At the time of this writing, we have
# two classes of server hardware: 24-instance and 36-instance
#
modes = [
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
    'matchmaking',
]


mode = modes[ ( iInstanceNum - 1 ) % len(modes) ]

if sLocation and sClusterNode:
    sFormattedServerName = '%s %s/%s #%d' % ( sLocation, sClusterNode, sHostName, iInstanceNum )
elif sLocation:
    sFormattedServerName = '%s %s #%d' % ( sLocation, sHostName, iInstanceNum )
elif sClusterNode:
    sFormattedServerName = '%s %s #%d' % ( sClusterNode, sHostName, iInstanceNum )
else:
    sFormattedServerName = '%s #%d' % ( sHostName, iInstanceNum )

if mode == 'eventmix':
    hostname = 'Valve Halloween Mix Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_halloween.txt'
    servercfgfile = 'server_limited_rounds.cfg'
    sv_tags += ',eventmix'
elif mode == 'event247':
    hostname = 'Valve Halloween 2015 Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_halloween_event_247.txt'
    servercfgfile = 'server_247_rounds.cfg'
    sv_vote_issue_nextlevel_allowed = 0
    sv_vote_issue_extendlevel_allowed = 0
    sv_tags += ',event247'
elif mode == 'payload':
    hostname = 'Valve Payload Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_payload.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'payloadrace':
    hostname = 'Valve Payload Race Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_payloadrace.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'ctf':
    hostname = 'Valve CTF Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_ctf.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'misc':
    hostname = 'Valve Alternative Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_misc.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'koth':
    hostname = 'Valve KOTH Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_koth.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'attackdefense':
    hostname = 'Valve Attack / Defense Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_attackdefense.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'cp':
    hostname = 'Valve Control Points Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_cp.txt'
    servercfgfile = 'server_limited_time.cfg'
elif mode == 'beta_asteroid':
    hostname = 'Valve Beta Server - Asteroid 24/7 (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_beta_asteroid.txt'
    servercfgfile = 'server_247_rounds.cfg'
elif mode == 'beta_cactus_canyon':
    hostname = 'Valve Beta Server - Cactus Canyon 24/7 (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_beta_cactus_canyon.txt'
    servercfgfile = 'server_247_rounds.cfg'
elif mode == 'mannpower':
    hostname = 'Valve Mannpower Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_mannpower.txt'
    servercfgfile = 'server_247_mannpower.cfg'
elif mode == 'bootcamp':
    hostname = 'Valve MvM Boot Camp Server (%s)' % sFormattedServerName
    #servercfgfile = 'server_mvm.cfg'
    maxplayers = 32
    tf_mm_servermode = 1
    tf_mm_strict = 1
    sv_vote_issue_nextlevel_allowed = 0
    sv_vote_issue_extendlevel_allowed = 0
    sv_vote_issue_changelevel_allowed_mvm = 1
    sv_minrate = 30000
    sv_vote_issue_kick_spectators_mvm = 1
    sv_vote_issue_kick_min_connect_time_mvm = 180
    sStartServerCmd = 'map mvm_mannworks'
    mp_allowspectators = 1
    tf_mm_trusted = 0
elif mode == 'mannup':
    hostname = 'Valve MvM Mann Up Server (%s)' % sFormattedServerName
    servercfgfile = "server_mvm.cfg"
    maxplayers = 32
    tf_mm_servermode = 1
    tf_mm_strict = 1
    tf_mm_trusted = 1
    sv_vote_issue_nextlevel_allowed = 0
    sv_vote_issue_extendlevel_allowed = 0
    sv_minrate = 30000
    sv_vote_issue_kick_spectators_mvm = 1
    sv_vote_issue_kick_min_connect_time_mvm = 180
    sStartServerCmd = 'map mvm_mannworks'
    mp_allowspectators = 1
elif mode == 'featured_maps':
    hostname = 'Valve Tough Break Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_featured_maps.txt'
    servercfgfile = 'server_limited_time.cfg'
    sv_tags += ',featured'
elif mode == 'community_update':
    hostname = 'Valve Invasion Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_invasion_maps.txt'
    servercfgfile = 'server_limited_time.cfg'
    sv_tags += ',community_update'
elif mode == 'passtime':
    hostname = 'Valve Beta Server - PASS Time 24/7 (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_quickplay_passtime.txt'
    servercfgfile = 'server_limited_time.cfg'
    mp_stalemate_enable = 1
    mp_stalemate_meleeonly = 1
elif mode == 'matchmaking':
    hostname = 'Valve Matchmaking Server (%s)' % sFormattedServerName
    servercfgfile = 'server_competitive.cfg'
    tf_mm_servermode = 1
    tf_mm_strict = 1
    # All matchmaking servers are strict, so should just have maxplayers 32 to support all modes
    maxplayers = 32
else:
    sys.stderr.write("Don't recognize mode %s\n" % (mode))
    misconfigured = True

if hostname == None:
    sys.stderr.write("Mode %s doesn't configure a hostname.\n" % (mode))
    misconfigured = True

# If we ended up misconfigured, override the normal fun
if misconfigured:
    hostname = 'Valve Maintenance Server (%s)' % sFormattedServerName
    mapcyclefile = 'mapcycle_ladder.txt'
    print('sv_password stairs')
    servercfgfile = 'server_limited_rounds.cfg'
    sv_tags += ',rip'

print('hostname "%s"' % hostname)
if servercfgfile:
    print('servercfgfile "%s"' % servercfgfile)
if mapcyclefile:
    print('mapcyclefile "%s"' % mapcyclefile)
print('')
print('maxplayers %d' % maxplayers)
print('sv_minrate %d' % sv_minrate)
print('')
print('tf_mm_servermode %d' % tf_mm_servermode)
print('tf_mm_strict %d' % tf_mm_strict)
print('tf_mm_trusted %d' % tf_mm_trusted)
print('')
print('')
print('mp_stalemate_enable %d' % mp_stalemate_enable)
print('mp_stalemate_meleeonly %d' % mp_stalemate_meleeonly)
print('')
print('sv_vote_issue_nextlevel_allowed %d' % sv_vote_issue_nextlevel_allowed)
print('sv_vote_issue_extendlevel_allowed %d' % sv_vote_issue_extendlevel_allowed)
print('sv_vote_issue_changelevel_allowed %d' % sv_vote_issue_changelevel_allowed)
print('sv_vote_issue_changelevel_allowed_mvm %d' % sv_vote_issue_changelevel_allowed_mvm)
print('')
print('sv_tags "%s"' % sv_tags)
print('log on')

# Always print whatever command starts the server last
print('')
print(sStartServerCmd)
