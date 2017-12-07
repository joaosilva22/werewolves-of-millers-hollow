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

+day(Day)
	:true.

/* Ask the coordinator for the true identity of a player */
+!find_true_personality(Day)
	:true
	<- .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator,tell,tell_personality(Player)).
				   
/* Answer of the coordinator with the true identity of a Player */				   
+!true_identity(Player, werewolf)
	:true
	<- -player(Player);
	   +werewolf(Player).
+!true_identity(Player, townsperson)
	:true
	<- -player(Player);
	   +townsperson(Player).	
		  
/* vote on a player for murder */		  
		  
/* not implemented on project yet */		  
+!vote(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, werewolf(Name), Werewolves);
	   .count(Werewolves, CntWerewolves);
	   CntWerewolves > 0;
	   actions.random_player(Werewolves, Werewolf);
	   .send(game_coordinator, tell , voted_to_murder(Werewolf, Day, Me)).	  
+!vote(Day)
	:true
	<- .my_name(Me);
	   .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator, tell , voted_to_murder(Werewolf, Day, Me)).		  
		   
/* Remove eliminated player from database */


/* change to abolish */
+dead(_ , Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(_ ,Player, townsfolk)
	:alive
	<- -townsfolk(Player).	
+dead(_ ,Player, werewolf)
	: alive
	<- -werewolf(Player).
+dead(_,Player, _)
	: alive
	<- -player(Player).