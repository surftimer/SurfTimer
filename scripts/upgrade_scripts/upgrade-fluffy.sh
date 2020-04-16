#!/bin/bash

##########################################
#   upgrade script from flufflys timer   #
##########################################

# change this setting to your install directory
SERVERDIR="/srv/csgo-server/csgo"

rm -rf "${SERVERDIR}/sound/quake"
rm "${SERVERDIR}/sound/surftimer/*.mp3"
mv "${SERVERDIR}/sound/surftimer/pr/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/pr.mp3"
mv "${SERVERDIR}/sound/surftimer/top10/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/top10.mp3"
mv "${SERVERDIR}/sound/surftimer/wr/valve_logo_music.mp3" "${SERVERDIR}/sound/surftimer/wr.mp3"

mv "${SERVERDIR}/cfg/sourcemod/surftimer/main.cfg" "${SERVERDIR}/cfg/sourcemod/surftimer/main.cfg.backup"
mv "${SERVERDIR}/cfg/sourcemod/surftimer/map_types/surf_.cfg" "${SERVERDIR}/cfg/sourcemod/surftimer/surf.cfg.backup"
rm -rf "${SERVERDIR}/cfg/sourcemod/surftimer/map_types/"
rm "${SERVERDIR}/cfg/sourcemod/surftimer/*_.cfg"
wget https://raw.githubusercontent.com/olokos/Surftimer-olokos/master/cfg/sourcemod/surftimer/main.cfg -P "${SERVERDIR}/cfg/sourcemod/surftimer/"
