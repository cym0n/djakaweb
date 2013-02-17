CREATE INDEX playing_game
ON ONGOING_ACTIONS (GAME_ID);

ALTER TABLE `ONGOING_ACTIONS` 
ADD FOREIGN KEY ( `GAME_ID` ) 
REFERENCES `djakarta`.`GAMES` (`ID` );