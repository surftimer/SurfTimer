-- =====THIS SECTION IS NOT NECESSARY IT IS OPTIONAL=====

--SHOW TIMELEFT IN SIDEHUD BY DEFAULT FOR NEW PLAYERS
--ALTER TABLE ck_playeroptions2 MODIFY module1s int(11) NOT NULL DEFAULT '5';
--ALTER TABLE ck_playeroptions2 MODIFY module2s int(11) NOT NULL DEFAULT '1';

--SET THE DEFAULT VALUES TO USERES ALREADY CREATED
--UPDATE ck_playeroptions2 SET module1s = '5',module2s = '1';

-- =====THIS SECTION IS REQUIRED=====

--ADD TIMELEFT
ALTER TABLE ck_playeroptions2 ADD showtime int(11) NOT NULL DEFAULT '1';