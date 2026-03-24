# MPF_Joust
MPF-0.80.0 code for Adrian's Joust head to head pinball machine.
It is set up for displaying the score and direcions to start a game on an external monitor as well as on the segment displays.
A few known issues/improvments needed:
  - Commas on displays do not work
  - Production build will run into an issue with the balls not launching in the launcher when multiball is started. It runs fine with "mpf both" started instead of the production build
  - Player 2 can operate the carousel game selection. This needs to be removed so only player 1 can do it.
  - If the tunnel multiball timer runs out and there are more than 2 balls on the playfield for head 2 head and 1 ball on the playfield for single player, then when the balls drain they will count against the player.
