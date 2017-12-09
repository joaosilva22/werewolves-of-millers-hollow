/* Initial beliefs */
alive.

/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(fortune_teller, Me)).

/* Add other players to beliefs */
+player(Player)
	: true
	<- .print("I've learned that ", Player, " is playing the game.").
	   
+townsperson(Player)
	: true
	<- .print("I've learned that ", Player, " is a townsperson.").
		   
+werewolf(Player)
	: true
	<- .print("I've learned that ", Player, " is a werewolf.").


/* Ask the coordinator for the true identity of a player */
+!find_true_personality(Day)
	:alive
	<- .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator,tell,tell_personality(Player)).
				   
/* Answer of the coordinator with the true identity of a Player */				   
+!true_identity(Player, werewolf)
	:alive
	<- .abolish(player(Player));
	   +werewolf(Player).
+!true_identity(Player, townsperson)
	:alive
	<- .abolish(player(Player));
	   +townsperson(Player).	
		  
/* vote on a player for murder */		  
+day(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, werewolf(Name), Werewolves);
	   .count(Werewolves, CntWerewolves);
	   CntWerewolves > 0;
	   actions.random_player(Werewolves, Werewolf);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Werewolf));
	   /* Necessary to interact with negotiating agents */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, vote_for(Day, Me, Player, -1)).	  
+day(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Player));
	   /* Necessary to interact with negotiating agents */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, vote_for(Day, Me, Player, -1)).		  
		   
/* Remove eliminated player from database */
+dead(_, _ , Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(Day, Period ,Player, townsfolk)
	: alive & member(Player, towsnfolk)
	<-  .print(Player, " has died.");
		.abolish(townsfolk(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).	
+dead(Day, Period ,Player, werewolf)
	: alive & member(Player, werewolf)
	<- 	.print(Player, " has died.");
		.abolish(werewolf(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).

+dead(Day, Period, Player, _)
	:alive & member(Player, player)	 
	<- 	.print(Player, " has died.");
		.abolish(player(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).  	