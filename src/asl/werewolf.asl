/* Initial beliefs */
alive.

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
	: .my_name(Player)
	<- .abolish(werewolf(Player)).

+werewolf(Player)
	<- .print("I've learned that ", Player, " is also a werewolf.").	
	
/* Add townsperson to beliefs */
+player(Player)
	<- 	+townsperson(Player, 0.0);
		.my_name(Me);
		update_beliefs_in_townsfolk(Me, Player, 0.0);
		.print("I've learned that ", Player, " is playing the game.").
	
/*
 * Game loop
 */
	
/* Wake up during the night*/
+night(Day)
	<- .my_name(Me);
	   .print(Me, " wakes up.");
	   .findall(Probability, townsperson(_, Probability), Probabilities);
	   .max(Probabilities, Prob);
	   ?townsperson(Player, Prob);
	   .send(game_coordinator, tell, voted_to_eliminate(Day, Me, Player)).
	   
/* Wake up in the morning */
+day(Day)
	<- .my_name(Me);
	   .findall(Probability, townsperson(_, Probability), Probabilities);
	   .max(Probabilities, Prob);
	   ?townsperson(Player, Prob);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player));
	   /* Tell everyone else who the player is voting for */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, voted_to_lynch(Day, Me, Player)).
	   
/* Update probabilities of eliminate a werewolf*/	
    
/* I am being accused  */    
+voted_to_lynch(_,Accuser, Accused)
	: my_name(Accused)
	<- ?townsperson(Accuser, Probability);
		UpdatedProbability = Probability + 0.1;
		-+townsperson(Accuser, UpdatedProbability);
		/* Add thought proccess to the gui */
	   .my_name(Me);
	   update_beliefs_in_townsfolk(Me, Accuser, UpdatedProbability);
	   add_player_thought(Me, Accuser, " has voted to lynch ", Accused, "so it is possible that he knows that he is a werewolf").

/* A werewolf as been accused */		
+voted_to_lynch(_, Accuser, Accused)
	: werewolf(Accused)
	<- ?townsperson(Accuser, Probability);
		UpdatedProbability = Probability + 0.2;
		-+townsperson(Accuser, UpdatedProbability);
		/* Add thought proccess to the gui */
		.my_name(Me);
	   	update_beliefs_in_townsfolk(Me, Accuser, UpdatedProbability);
	   	add_player_thought(Me, Accuser, " has voted to lynch me, so it is possible that he knows that I am a werewolf").	
				   
/* a townsperson accuse another one */				   
+voted_to_lynch(_, Accuser, Accused)
	: townsperson(Accused,AccusedProb) & townsperson(Accuser,AccuserProb) & AccusedProb > 0 & AccuserProb > 0
	<- ?townsperson(Accuser, Probability);
		UpdatedProbability = Probability - 0.1;
		-+townsperson(Accuser, UpdatedProbability);
		?townsperson(Accused, Prob);
		NewProbability = Prob - 0.1;
		-+townsperson(Accused, NewProbability);
		/* Add thought proccess to the gui */
		.my_name(Me);	
		update_beliefs_in_townsfolk(Me, Accuser, UpdatedProbability);
		update_beliefs_in_townsfolk(Me, Accused, NewProbability);
		add_player_thought(Me, Accuser, " has voted to lynch ", Accused, "so it is possible that he believes that ", Accused ," is a werewolf, so i should let him believe that").			   
				   
/* Remove eliminated player from database */
+dead(Day, Period, Player, Role)
	: alive & .my_name(Player)
	<- -alive.
+dead(Day, Period, Player, werewolf)
	: alive
	<- .abolish(werewolf(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
+dead(Day, Period, Player, townsperson)
	: alive
	<- .abolish(townsperson(Player, _));
	   .abolish(player(Player));
	   .my_name(Me);
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
