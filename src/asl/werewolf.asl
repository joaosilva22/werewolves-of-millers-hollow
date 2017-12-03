/* Initial beliefs */
alive.

/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(werewolf, Me)).

/* Add other werewolves to beliefs */
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
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_murder(Me,Day, Player));
	   .print("sended vote").
	   
/* Remove eliminated player from database */
+dead(Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(Player, werewolf)
	: alive
	<- -werewolf(Player).
+dead(Player, _)
	: alive
	<- -player(Player).