/* Initial beliefs */
alive.
living_werewolves(2).

/* Initial goals */
!join_game(game_coordinator).

/* Plans */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(townsperson, Me)).
	
/* Add other players to the database */
+player(Player)
	: true
	<- .print("I've learned that ", Player, " is playing the game.").
	
/* Remove eliminated player from database */
+dead(Player, _)
	: alive & .my_name(Player)
	<- -alive.
+dead(Player, werewolf)
	: alive
	<- ?living_werewolves(Werewolves); 
	   -+living_werewolves(Werewolves-1);
	   -player(Player).
+dead(Player, _)
	: alive
	<- -player(Player).