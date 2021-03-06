SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";




CREATE TABLE IF NOT EXISTS `CLICKS` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) DEFAULT NULL,
  `ACTION` int(11) DEFAULT NULL,
  `TYPE` varchar(15) DEFAULT NULL,
  `TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `GAMES` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) DEFAULT NULL,
  `MISSION_ID` varchar(3) DEFAULT NULL,
  `DANGER` int(11) DEFAULT NULL,
  `ACTIVE` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `GAMES_STATUS` (
  `GAME_ID` int(11) NOT NULL DEFAULT '0',
  `OBJECT_CODE` varchar(4) NOT NULL DEFAULT '',
  `ACTIVE` int(11) DEFAULT NULL,
  `STATUS` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`GAME_ID`,`OBJECT_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `ONGOING_ACTIONS` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `GAME_ID` int(11) DEFAULT NULL,
  `OBJECT_CODE` varchar(4) DEFAULT NULL,
  `ACTION` varchar(30) DEFAULT NULL,
  `ACTIVE` int(11) DEFAULT NULL,
  `CLICKS` int(11) DEFAULT NULL,
  `OBJECT_STATUS` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `STORIES` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `GAME_ID` int(11) DEFAULT NULL,
  `CONTENT` text,
  `TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OBJECT_CODE` varchar(4) DEFAULT NULL,
  `ACTION` varchar(30) DEFAULT NULL,
  `OBJECT_NAME` varchar(255) DEFAULT NULL,
  `PARENT_ACTION` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `TEST_GRAPH` (
  `ID` int(11) NOT NULL,
  `START` int(11) DEFAULT NULL,
  `ELEMENT` varchar(4) DEFAULT NULL,
  `ACTION` varchar(60) DEFAULT NULL,
  `FINISH` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `TEST_STATUS` (
  `ID` int(11) NOT NULL,
  `STATUS_ID` int(11) DEFAULT NULL,
  `OBJECT_CODE` varchar(4) DEFAULT NULL,
  `OBJECT_TYPE` varchar(10) DEFAULT NULL,
  `ACTIVE` int(11) DEFAULT NULL,
  `STATUS` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



CREATE TABLE IF NOT EXISTS `USERS` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACEBOOK_ID` int(11) DEFAULT NULL,
  `LAST_ACTION_DONE` datetime DEFAULT NULL,
  `LAST_SUPPORT_DONE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `SCORE` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

