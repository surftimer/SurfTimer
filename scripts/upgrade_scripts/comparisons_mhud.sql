--ADD TOP/Groups Comparisons to MinimalHUD
ALTER TABLE ck_playeroptions2 DROP COLUMN comapreWR;
ALTER TABLE ck_playeroptions2 RENAME COLUMN comparePB TO comparetype;