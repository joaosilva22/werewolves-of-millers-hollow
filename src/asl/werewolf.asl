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
	<- .print("I've learned that ", Player, " is also a werewolf.").	
	
/* Add other players to beliefs */
+player(Player)
	<- .print("I've learned that ", Player, " is playing the game.").
	
/* Wake up during the night */
+night(Day)
	<- .my_name(Me);
	   .print(Me, " wakes up.");
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_eliminate(Day, Me, Player)).
	   
/* Wake up in the morning */
+day(Day)
	<- .my_name(Me);
	   .print(Me, " wakes up.");
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player));
	   /* Tell everyone else who the player is voting for */
	   .send(Players, tell, voted_to_lynch(Day, Me, Player)).
	   
/* Remove eliminated player from database */
+dead(Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(Player, werewolf)
	: alive
	<- .abolish(werewolf(Player)).
+dead(Player, _)
	: alive
	<- .abolish(player(Player)).