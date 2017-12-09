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
	:true
	<- .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator,tell,tell_personality(Player)).
				   
/* Answer of the coordinator with the true identity of a Player */				   
+!true_identity(Player, werewolf)
	:true
	<- .abolish(player(Player));
	   +werewolf(Player).
+!true_identity(Player, townsperson)
	:true
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
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Werewolf)).	  
+day(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Player)).		  
		   
/* Remove eliminated player from database */
+dead(_, _ , Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(Day, Period ,Player, townsfolk)
	:alive
	<-  .print(Player, " has died.");
		.abolish(townsfolk(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).	
+dead(Day, Period ,Player, werewolf)
	: alive
	<- 	.print(Player, " has died.");
		.abolish(werewolf(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).