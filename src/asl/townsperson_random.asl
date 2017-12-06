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
+player(Player) : not .my_name(Player).
	
/* Wake up */
+day(Day)
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player)).
	
/* Remove eliminated player from database */
+dead(Player, _)
	: alive & .my_name(Player)
	<- -alive.
+dead(Player, werewolf)
	: alive
	<- ?living_werewolves(Werewolves); 
	   -+living_werewolves(Werewolves-1);
	   .abolish(player(Player)).
+dead(Player, _)
	: alive
	<- .abolish(player(Player)).