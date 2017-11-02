# v2.1 (Latest)
* Added default titles which can be edited via `addons/sourcemod/config/surftimer/default_titles.txt`
* Added new ConVar `ck_enforce_default_titles` which sets whether to enforce default titles on players
* Added default titles whitelist which will whitelist players from being forced to use their default title `addons/sourcemod/config/surftimer/default_titles_whitelist.txt`
* Fixed tele to start zones not working on Bonuses
* Fixed `sm_repeat`
* Fixed `sm_goback`
* Added custom skill groups which can be edited via `addons/sourcemod/configs/surftimer/skillgroups.cfg`
* Zone display now respects the `ck_zone_drawstyle` ConVar
* Prespeed is now controlled on a per zone basis, you can edit it in the zones options on the second page
* Added Target Name to the zones menu allowing zoners to change what players target name will be when entering/leaving a zone
* Added mapsettings menu `sm_mapsettings` `sm_ms`
* Updated colours include (thanks 2called-chaos)
* Zoner commands now respects `ck_zoner_flag`
* Added ConVar `ck_vip_flag`
* Added native `surftimer_IsClientVip`
* Speed limiting no longer checks for players that are in checkpoint, end or misc zones
* Removed bonus tiers
* `ck_mapsettings` has been dropped with it's columns moved to `ck_maptier`
* Added ConVar to enable WRCP points `ck_wrcp_points` 

###### Changes by aveniccii (thanks)
* Fixed spacing between stage completion message
* Changed / Fixed various message colours and formatting
* Removed unnecessary convars
* Added titles to all config files
* Moved hard coded convars from the timer into map type configs
* Added clear readme description to the map_types folder
* Updated DHooks(2.0.4 -> 2.1.1)
* Updated Cleaner
* Added colons to 'Stage' in side-hud and center-hud
* Added 'Time:' prefix before timer in center hud
* Changed IN_DUCK AND IN_JUMP to +D/+J
* Added +L/+R for +left and +right inputs
* Added colours to speed and time in the center hud when spectating
* Removed various references to the KP community
* Removed the remaning console print messages
* Added better tickrate management

## v2.01

* Added the ability to "hook" trigger_multiples made by the mapper as zones `sm_hookzone`
* Added the ability to set targetnames on clients when entering/leaving zones (No command yet, has to be done manually in the database)
* Bonus zones can now overlap normal map zones
* Added module system for centre and side hud
* Added new options to the options menu and removed useless ckSurf options
* Added "momentum" speed gradient which changes the speed colour to <span style="color: #66bbff;">blue</span> if gaining speed, <span style="color: #ff7d7d;">red</span> if losing speed and <span style="color: #a300ff">purple</span> if at max velocity
* Added centre speed display
* Added the ability to change speed between XY, XYZ, Z
* Added strafe sync
* Fixed exploit with WRCPs
* Added player info option to the profile menu which shows total time spent on server, total connections etc
* Added `sm_startpos` and `sm_resertstartpos` which allows players to set a custom restart position inside the start zone
* Added backwards style
* Fixed `sm_maptop` and `sm_mrank` when trying to use them on `surf_me`
* Removed 4 bhop limit as it's not needed with the 1 jump limit
* Added new saveloc system, now uses ids `sm_saveloc` `sm_tele #id` `sm_savelocs` `sm_loclist`
* Touching the start zone in practice mode no longer automatically teleports you to your saveloc
* `sm_rr` and `sm_latest` now displays a menu of the recently broken records
* Showzones now shows all corners and incldues stage zones
* `sm_help` menu has been revamped and will now automatically add any command with `[surftimer]` in the description
* Timeleft chat messages now show the next map at the 60 seconds, 30 seconds, 15 seconds and -3 seconds intervals
* Added `sm_bug` which sends a bug report to discord, must set `ck_report_discord` first
* Added `sm_calladmin` which sends a call admin request to discord, must set `ck_calladmin_discord` first
* Added server wide & discord record announcements, must set `ck_announce_records`, `ck_server_id` and `ck_announce_records_discord` first
* Paint has been removed, use <a href="https://forums.alliedmods.net/showthread.php?t=300382&highlight=paint">this</a> instead, does the same thing but better
* When a client is teleporting to a zone, the timer will now check if there is a teleport destination inside of the zone, if one is found the client is telpeorted to the info_teleport_destination instead of the centre of the zone
* Clients timers are now automatically re-enabled when using `!r`
* Added `cm_cpr [@rank/mapname/player] [player]`
* Ranks have been changed `sm_ranks`
* Fixed a issue with custom titles when trying to use `{blue}` or `{orange}` next to another colour
* Purple is no longer a restricted colour
* Added new admin command to reload the current map `sm_rm`
* `sm_nc` will now automatically disable your timer
* The following cvars are now set by default `sv_ladder_scale_speed 1` `sv_friction 5.2` `sv_staminamax 0`
* Zones now **VISUALLY** have a width of 1 unit (previously 5 units)
* Zones amplitude has been set to 0 (stops the zones from "shaking")
* Zones will now auto reload when deleting one
* Zoners no longer have to `!showzones` when creating/editing zones
* Footsteps and gun shots from other players are now silent
* Players will now recieve credits when completing a map if using <a href="https://forums.alliedmods.net/showthread.php?t=276677"> Zephyrus' Store</a>

Note: Some additions/changes are probably missing from this changelog, this is just what I remember, will continue to update if I remember what else I changed