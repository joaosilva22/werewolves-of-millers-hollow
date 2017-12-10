/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(werewolf, Me)).
	
/*
 * Game setup
 */

/* Add other werewolves to beliefs */
+werewolf(Player)
	<- .print("I've learned that ", Player, " is also a werewolf.").	
	
/* Add other players to beliefs */
+player(Player)
	<- .print("I've learned that ", Player, " is playing the game.").
	
/*
 * Game loop
 */
	
/* Wake up during the night */
+night(Day)
	<- .my_name(Me);
	   .print(Me, " wakes up.");
	   .findall(Name, player(Name), Players);
	   werewolves_of_millers_hollow.actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_eliminate(Day, Me, Player)).
	   
/* Wake up in the morning */
+day(Day)
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   werewolves_of_millers_hollow.actions.random_player(Players, Player);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player));
	   /* Tell everyone else who the player is voting for */
	   .send(Players, tell, voted_to_lynch(Day, Me, Player));
	   /* Necessary to interact with negotiating agents */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, vote_for(Day, Me, Player, -1));
	   .findall(Werewolf, werewolf(Werewolf), Werewolves);
	   .send(Werewolves, tell, vote_for(Day, Me, Player, -1)).
	   
/* Remove eliminated player from database */
+dead(Day, Period, Player, werewolf)
	<- .abolish(werewolf(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
+dead(Day, Period, Player, _)
	<- .abolish(player(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
	   
/* Required for interoperability */
+vote_for_in_exchange(Day, Accuser, Accused, Promised)
	<- /* Reject the plan straight away */
	   .my_name(Me);
	   .send(Accuser, tell, reject_vote_for_in_exchange(Day, Me, Accused, Promised)).