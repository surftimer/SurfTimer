#!/bin/bash

##########################################
#   upgrade script from nikooo777 timer  #
##########################################

# change below to your csgo server root directory
SERVERDIR="/home/csgoserver/csgo/"

rm -r "${SERVERDIR}/sound/quake"

mv "${SERVERDIR}/cfg/sourcemod/ckSurf" "${SERVERDIR}/cfg/sourcemod/ckSurf-old"

rm "${SERVERDIR}/addons/sourcemod/translations/ckSurf.phrases.txt"

rm "${SERVERDIR}/addons/sourcemod/scripting/include/ckSurf.inc"
rm "${SERVERDIR}/addons/sourcemod/scripting/ckSurf-telefinder.sp"
rm "${SERVERDIR}/addons/sourcemod/scripting/ckSurf.sp"
rm -r "${SERVERDIR}/addons/sourcemod/scripting/ckSurf"

rm "${SERVERDIR}/addons/sourcemod/plugins/ckSurf.smx"
rm "${SERVERDIR}/addons/sourcemod/plugins/disabled/ckSurf-telefinder.smx"
rm "${SERVERDIR}/addons/sourcemod/plugins/disabled/ckSurf-telefinder.smx"

mv "${SERVERDIR}/cfg/sourcemod/configs/ckSurf" "${SERVERDIR}/cfg/sourcemod/configs/ckSurf-old"
