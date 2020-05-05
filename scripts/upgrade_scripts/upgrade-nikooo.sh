#!/bin/bash

##########################################
#   upgrade script from nikooo777 timer  #
##########################################

# change this to your csgo directory, if not running from "upgrade_scripts" folder
SERVERDIR="../.."

rm -rf "${SERVERDIR}/sound/quake"

mv "${SERVERDIR}/cfg/sourcemod/ckSurf" "${SERVERDIR}/cfg/sourcemod/ckSurf-old"

rm -f "${SERVERDIR}/addons/sourcemod/translations/ckSurf.phrases.txt"

rm -f "${SERVERDIR}/addons/sourcemod/scripting/include/ckSurf.inc"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/ckSurf-telefinder.sp"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/ckSurf.sp"
rm -rf "${SERVERDIR}/addons/sourcemod/scripting/ckSurf"

rm -f "${SERVERDIR}/addons/sourcemod/scripting/plugins/ckSurf.smx"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/plugins/disabled/ckSurf-telefinder.smx"
rm -f "${SERVERDIR}/addons/sourcemod/scripting/plugins/disabled/ckSurf-telefinder.smx"

mv "${SERVERDIR}/cfg/sourcemod/configs/ckSurf" "${SERVERDIR}/cfg/sourcemod/configs/ckSurf-old"
