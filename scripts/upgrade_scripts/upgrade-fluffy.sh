#!/bin/bash

##########################################
#   upgrade script from flufflys timer   #
##########################################

# change below to your csgo server root directory
SERVERDIR="/home/csgoserver/csgo/"

rm -r "${SERVERDIR}/sound/quake"
rm "${SERVERDIR}/sound/surftimer/*.mp3"
mv "${SERVERDIR}/sound/surftimer/pr/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/pr.mp3"
mv "${SERVERDIR}/sound/surftimer/top10/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/top10.mp3"
mv "${SERVERDIR}/sound/surftimer/wr/1/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/wr.mp3"

mv "${SERVERDIR}/cfg/sourcemod/surftimer" "${SERVERDIR}/cfg/sourcemod/surftimer-old"

rm -r "${SERVERDIR}/optional"

rm "${SERVERDIR}/addons/sourcemod/scripting/surftimer.smx"
rm "${SERVERDIR}/addons/sourcemod/scripting/ckSurf-telefinder.sp"
rm "${SERVERDIR}/addons/sourcemod/scripting/surftimer.smx"
rm -r "${SERVERDIR}/addons/sourcemod/scripting/surftimer"
rm "${SERVERDIR}/addons/sourcemod/scripting/include/SurfTimer.inc"

rm "${SERVERDIR}/addons/sourcemod/plugins/surftimer.smx"
rm "${SERVERDIR}/addons/sourcemod/plugins/discord_api.smx"

mv "${SERVERDIR}/addons/sourcemod/configs/surftimer" "${SERVERDIR}/addons/sourcemod/configs/surftimer-old"
