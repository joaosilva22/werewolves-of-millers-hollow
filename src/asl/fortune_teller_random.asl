
/* Rules */

is_a_werewolf(Player) :-
	.findall(Name, werewolf(Name), Werewolves)  & 
	.print("Werewolves = ", Werewolves) & 
	.member(Player, Werewolves).

is_a_townsperson(Player) :-
	.findall(Name, townsfolk(Name), Townsfolks) 
	& .print("Townsfolks = ", Townsfolks) 
	& .member(Player, Townsfolks). 

/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(fortune_teller, Me)).

/* Add other players to beliefs */
+everyone(Player)
	: .my_name(Player)
	<- .abolish(player(Player)).
	
+everyone(Player)
	: not .my_name(Player)
	<- 	+player(Player);
		.print("I've learned that ", Player, " is playing the game.").
	   
+townsperson(Player)
	: true
	<- .print("I've learned that ", Player, " is a townsperson.").
		   
+werewolf(Player)
	: true
	<- .print("I've learned that ", Player, " is a werewolf.").


/* Ask the coordinator for the true identity of a player */
+!find_true_personality(Day)
	: .findall(Name, player(Name), Players) & .length(Players,CntPlayers) & CntPlayers > 0
	<- .my_name(Me);
	   werewolves_of_millers_hollow.actions.random_player(Players, Player);
	   .print("Player = ", Player);
	   .send(game_coordinator,achieve,tell_personality(Player, Me)).

+!find_true_personality(Day)
	<- .print("I already know the true personality of everyone").	   
				   
/* Answer of the coordinator with the true identity of a Player */				   
+true_identity(Player, werewolf)
	<- .abolish(player(Player));
	   +werewolf(Player).
+true_identity(Player, townsperson)
	<- .abolish(player(Player));
	   +townsperson(Player).	
+true_identity(Player, fortune_teller)
	<- .abolish(player(Player));
	   +townsperson(Player).	
		  
/* vote on a player for murder */		  
+day(Day)
	: .findall(Name, werewolf(Name), Werewolves) & .length(Werewolves, CntWerewolves) & CntWerewolves > 0
	<- .my_name(Me);
	   werewolves_of_millers_hollow.actions.random_player(Werewolves, Werewolf);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Werewolf));
	   /* Necessary to interact with negotiating agents */
	   .findall(X, everyone(X), Players);
	   .send(Players, tell, vote_for(Day, Me, Werewolf, -1)).	  
+day(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   werewolves_of_millers_hollow.actions.random_player(Players, Player);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Player));
	   /* Necessary to interact with negotiating agents */
	   .findall(X, everyone(X), Xs);
	   .send(Xs, tell, vote_for(Day, Me, Player, -1)).
			  
		   
/* Remove eliminated player from database */
+dead(_, _ , Player, Role)
	: .my_name(Player)
	<- .print("I'm dead").
+dead(Day, Period ,Player, townsfolk)
	: is_a_townsperson(Player)
	<-  .print(Player, " has died.");
		.abolish(townsfolk(Player));
		.abolish(everyone(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).	
+dead(Day, Period ,Player, werewolf)
	: is_a_werewolf(Player)
	<- 	.print(Player, " has died.");
		.abolish(werewolf(Player));
		.abolish(everyone(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).
+dead(Day, Period, Player, _)
	<- 	.print(Player, " has died.");
		.abolish(player(Player));
		.abolish(everyone(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).  	