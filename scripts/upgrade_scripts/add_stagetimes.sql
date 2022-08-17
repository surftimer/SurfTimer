--ADD STAGETIMES TO CK_CHECKPOINTS
CREATE TABLE IF NOT EXISTS ck_ccp (steamid VARCHAR(32), name VARCHAR(32), mapname VARCHAR(32), cp INT NOT NULL DEFAULT '0', time decimal(12, 6) NOT NULL DEFAULT '-1.000000', attempts INT NOT NULL DEFAULT '0', PRIMARY KEY(steamid, mapname, cp)) DEFAULT CHARSET=utf8mb4;