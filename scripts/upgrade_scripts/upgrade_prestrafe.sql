ALTER TABLE ck_bonus ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_bonus ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_bonus ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

ALTER TABLE ck_playertimes ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_playertimes ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_playertimes ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

ALTER TABLE ck_wrcps ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_wrcps ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
ALTER TABLE ck_wrcps ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

ALTER TABLE ck_playeroptions2 ADD tips int(11) DEFAULT 1 NOT NULL;