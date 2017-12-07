/* Initial beliefs */
living_werewolves(2).

/* Initial goals */
!join_game(game_coordinator).

/* Plans */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(townsperson, Me)).
	
/*
 * Game setup
 */
	
/* Add other players to player database */
+player(Player)
	: not .my_name(Player)
	<- /* Add initial beliefs about the other players */
	   .print("Adding player ", Player).

/* Don't add himself to player database */
+player(Player) 
	: .my_name(Player)
	<- .abolish(player(Player)).
	
/*
 * Game loop
 */
	
/* Wake up */
+day(Day)
	<- .my_name(Me);
	   /* Select a random player */
	   .findall(Name, player(Name), Players);
	   werewolves_of_millers_hollow.actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player));
	   /* Tell everyone else who the player is voting for */
	   .send(Players, tell, voted_to_lynch(Day, Me, Player)).

/* Remove eliminated players from database */

/* When a werewolf has been eliminated from the game */
+dead(Day, Period, Player, werewolf)
	: not .my_name(Player)
	<- /* Update the number of living werewolves */
	   ?living_werewolves(Werewolves); 
	   -+living_werewolves(Werewolves-1);
	   /* Delete the player from the database */
	   .print(Player, " has died");
	   .abolish(player(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
	   
/* When another player has been eliminated from the game */
+dead(Day, Period, Player, townsperson)
    : not .my_name(Player)
	<- /* Delete the player from the database */
	   .print(Player, " has died");
	   .abolish(player(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).