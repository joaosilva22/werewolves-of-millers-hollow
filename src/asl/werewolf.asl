/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(werewolf, Me)).

/* Add other werewolves to beliefs */	
+werewolf(Player)
	: .my_name(Me) & Player == Me
	<- -werewolf(Player).
+werewolf(Player)
	: true
	<- .print("I've learned that ", Player, " is also a werewolf.").	
	
/* Add other players to beliefs */
+player(Player)
	: true
	<- .print("I've learned that ", Player, " is playing the game.").
	
+day(Day)
	: true
	<- -day(Day);
	   .my_name(Me);
	   .print("It is the night of day number ", Day);
	   .send(game_coordinator, tell, vote(Me, Day, player1)).