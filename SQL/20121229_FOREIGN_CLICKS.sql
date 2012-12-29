CREATE INDEX clicker
ON CLICKS (USER_ID);

CREATE INDEX clicked
ON CLICKS (ACTION);

ALTER TABLE `CLICKS` 
ADD FOREIGN KEY ( `USER_ID` ) 
REFERENCES `djakarta`.`USERS` (`ID` );

ALTER TABLE `CLICKS` 
ADD FOREIGN KEY ( `ACTION` ) 
REFERENCES `djakarta`.`ONGOING_ACTIONS` (`ID` );
