CREATE TABLE IF NOT EXISTS `renzu_muffler` (
  `plate` varchar(64) NOT NULL DEFAULT '',
  `muffler` longtext NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;