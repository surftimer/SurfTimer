/* Updrade for upgrading from flufflys SurfTimer to our z4lab-surftimer */

/* Fixing timer crash after upgrading to our timer */ 

/* Prestrafe Message */
ALTER TABLE `ck_playeroptions2` 
ADD COLUMN `prestrafe` INT(11) NOT NULL DEFAULT '0' AFTER `module5s`;
/* CP Messages */
ALTER TABLE `ck_playeroptions2` 
ADD COLUMN `cpmessages` INT(11) NOT NULL DEFAULT '1' AFTER `prestrafe`;
/* WRCP Messages */
ALTER TABLE `ck_playeroptions2` 
ADD COLUMN `wrcpmessages` INT(11) NOT NULL DEFAULT '1' AFTER `cpmessages`;

/* Record Type */
ALTER TABLE `ck_announcements`
ADD COLUMN `mode` INT(11) NOT NULL DEFAULT 0 AFTER `mapname`;
/* Bonus/Stage Number */
ALTER TABLE `ck_announcements`
ADD COLUMN `group` INT(12) NOT NULL DEFAULT 0 AFTER `time`;