#!/bin/bash

##########################################
#   upgrade script from flufflys timer   #
##########################################

# change this to your csgo directory, if not running from "upgrade_scripts" folder
SERVERDIR="../.."

rm -rf "${SERVERDIR}/sound/quake"
rm -f "${SERVERDIR}/sound/surftimer/*.mp3"
mv "${SERVERDIR}/sound/surftimer/pr/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/pr.mp3"
mv "${SERVERDIR}/sound/surftimer/top10/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/top10.mp3"
mv "${SERVERDIR}/sound/surftimer/wr/1/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/wr.mp3"

mv "${SERVERDIR}/cfg/sourcemod/surftimer" "${SERVERDIR}/cfg/sourcemod/surftimer-old"

rm -rf "${SERVERDIR}/optional"

rm -f "${SERVERDIR}/addons/sourcemod/scripting/surftimer.smx"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/ckSurf-telefinder.sp"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/surftimer.smx"
rm -rf "${SERVERDIR}/addons/sourcemod/scripting/surftimer"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/include/SurfTimer.inc"

rm -f "${SERVERDIR}/addons/sourcemod/plugins/surftimer.smx"
rm -f "${SERVERDIR}/addons/sourcemod/plugins/discord_api.smx"

mv "${SERVERDIR}/addons/sourcemod/configs/surftimer" "${SERVERDIR}/addons/sourcemod/configs/surftimer-old"
