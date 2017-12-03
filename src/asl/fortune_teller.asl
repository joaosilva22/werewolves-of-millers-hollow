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
+find_true_personality(Day)
	:true
	<- .findall(Name, player(Name), Players);
	   actions.random_player(Players, Player);
	   .send(game_coordinator,tell,tell_personality(Player)).
				   
/* Answer of the coordinator with the true identity of a Player */				   
+true_identity(Player, werewolf)
	:true
	<- -player(Player);
	   +werewolf(Player).

+true_identity(Player, townsperson)
	:true
	<- -player(Player);
	   +townsperson(Player).	
		   
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