/* Initial goals */
!join_game(game_coordinator).

/* Plans */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(townsperson, Me)).
	
+player(Player)
	: .my_name(Me) & Player == Me
	<- -player(Player).
+player(Player)
	: true
	<- .print("I've learned that ", Player, " is playing the game.").