/* Initial goals */
!join_game(game_coordinator).

/* Plan */
+!join_game(Coordinator)
	: .my_name(Me)
	<- .send(Coordinator, tell, role(fortune_teller, Me)).

/* Add other players to beliefs */
+everyone(Player)
	: .my_name(Player)
	<- .abolish(everyone(Player)).
	
/*
 * werewolf(Name, Flag, Prob)
 * 	- Name -> The name of the werewolf
 * 	- Flag = {true, false, null} ->  if true  it means that i am 100% that he is a werewolf
 * 								 ->  if false it means that i am 100% that he is not a werewolf
 * 								 ->  if null  it means that i am not sure of his identity
 *  - Prob -> Probability of Name is a werewolf
 * 
 * townsperson(Name, Flag, Prob)
 * 	- Name -> The name of the townsperson
 * 	- Flag = {true, false, null} ->  if true  it means that i am 100% that he is a townsperson
 * 								 ->  if false it means that i am 100% that he is not a townsperson
 * 								 ->  if null  it means that i am not sure of his identity
 *  - Prob -> Probability Name is a townsperson
 */	
 
+everyone(Player)
	: not .my_name(Player)
	<- 	+werewolf(Player,null,0.0);
		+townsperson(Player,null,0.0);
		.print("I've learned that ", Player, " is playing the game.").

/* adicionar caso nao haja mais players e ja sejam todos conhecidos */

/* Ask the coordinator for the true identity of a player */
+!find_true_personality(Day)
	: .findall(Prob, werewolf(_,null,Prob), Probabilities) & .length(Probabilities,Cnt) & Cnt > 0 & .findall(N, werewolf(N,null,0), P2) & .length(P2, P2Size) & not (P2Size == Cnt)
	<- .my_name(Me); 
	   .print("I already have some knowledge");
	   .max(Probabilities, HighestProb);
	   ?werewolf(Player,null,HighestProb);
	   .send(game_coordinator,achieve,tell_personality(Player, Me)).
+!find_true_personality(Day)
	: .findall(Prob, werewolf(_,null,Prob), Probabilities) & .length(Probabilities,Cnt) & Cnt > 0 & .findall(N, werewolf(N,null,0), P2) & .length(P2, P2Size) & P2Size == Cnt
	<- .my_name(Me); 
	   .print("begin");
	   werewolves_of_millers_hollow.actions.random_player(P2, Player);
	   .send(game_coordinator,achieve,tell_personality(Player, Me)).	   
+!find_true_personality(Day)
	<- .print("I already know the true personality of everyone").
					   
/* Answer of the coordinator with the true identity of a Player */				   
+true_identity(Player, werewolf)
	<- .abolish(werewolf(Player,_,_));
	   .abolish(townsperson(Player,_,_));
	   +werewolf(Player,true,1.0);
	   +townsperson(Player,false,0.0);
	   .my_name(Me);
	   update_beliefs_in_werewolves(Me, Player, 1.0);	
	   update_beliefs_in_townsfolk(Me, Player, 0.0);
	   add_player_thought(Me, "I know that ", Player, "is a werewolf").
+true_identity(Player, townsperson)
	<- .abolish(townsperson(Player,_,_));
	   .abolish(werewolf(Player,_,_));
	   +townsperson(Player,true, 1.0);
	   +werewolf(Player,false, 0.0);	
	   .my_name(Me);
	   update_beliefs_in_werewolves(Me, Player, 0.0);	
	   update_beliefs_in_townsfolk(Me, Player, 1.0);
	   add_player_thought(Me, "I know that ", Player, "is a townsperson").
+true_identity(Player, fortune_teller)
	<- .abolish(townsperson(Player,_,_));
	   .abolish(werewolf(Player,_,_));
	   +townsperson(Player,true, 1.0);
	   +werewolf(Player, false, 0.0);
	   .my_name(Me);
	   update_beliefs_in_werewolves(Me, Player, 0.0);	
	   update_beliefs_in_townsfolk(Me, Player, 1.0);
	   add_player_thought(Me, "I know that ", Player, "is a fortune_teller").	
		  
/* vote on a player for murder */		  
+day(Day)
	: .findall(Name, werewolf(Name,true,_), Names) & .length(Names, Cnt) & Cnt > 0
	<- .my_name(Me);
	   .nth(0,Names,Werewolf);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Werewolf));
	   /* Necessary to interact with negotiating agents */
	   .findall(X, everyone(X), Players);
	   .send(Players, tell, vote_for(Day, Me, Werewolf, -1)).	  
+day(Day)
	<- .my_name(Me);
	   .findall(Prob, werewolf(_,null, Prob), Probabilities);
	   .max(Probabilities, MaxProb);
	   ?werewolf(Player,null,MaxProb);
	   .send(game_coordinator, tell , voted_to_lynch(Day, Me, Player));
	   /* Necessary to interact with negotiating agents */
	   .findall(X, everyone(X), Xs);
	   .send(Xs, tell, vote_for(Day, Me, Player, -1)).
			  
/* When i am being accused of being a werewolf */

+voted_to_lynch(_, Accuser, Accused)
	: .my_name(Accused) 
	<- /* The accuser becomes more suspect */
	   ?townsperson(Accuser, Valid,_);
	   if(Valid == false | Valid == null)
	   {
		?werewolf(Accuser,Flag, Certainty);
		if(Certainty < 0.9)
		{
	   	  UpdatedCertainty = Certainty + 0.1;
	   	  .abolish(werewolf(Accuser,_,_));
	   	  +werewolf(Accuser,Flag ,UpdatedCertainty);   	
	   	  update_beliefs_in_werewolves(Accused, Accuser, UpdatedCertainty);
	   	}
	   }.
	   	   
/* When the player believes the accused is a townsperson */
+voted_to_lynch(_, Accuser, Accused)
	: (townsperson(Accused,null,Certainty) | townsperson(Accused,true,Certainty)) & Certainty >= 0.3
	<- /* The accuser becomes more suspect */
	   ?werewolf(Accuser,Flag ,OldCertainty);
	   	if(OldCertainty < 0.9)
		{
	     UpdatedCertainty = OldCertainty + 0.1;
	     .abolish(werewolf(Accuser,_ , _));
	     +werewolf(Accuser,Flag, UpdatedCertainty);
	     /* Add thought proccess to the gui */
	     .my_name(Me);
	     update_beliefs_in_werewolves(Me, Accuser, UpdatedCertainty);
	     add_player_thought(Me, Accuser, " has voted to lynch ", Accused, " but I think ", Accused, " is a townsperson. ", Accuser, " may be a werewolf.");
	   }.
/* When the player believes the accused is a werewolf */
+voted_to_lynch(_, Accuser, Accused)
	: (werewolf(Accused,null,Certainty) | werewolf(Accused,true,Certainty)) & Certainty >= 0.3
	<- /* The accuser becomes less suspect */
	   ?townsperson(Accuser,Flag ,OldCertainty);
	   if(OldCertainty < 0.9)
	   { 	
	   	UpdatedCertainty = OldCertainty + 0.1;
	   	.abolish(townsperson(Accuser, _,_));
	   	+townsperson(Accuser,Flag, UpdatedCertainty);
	  	/* Add thought proccess to the gui */
	   	.my_name(Me);
	   	update_beliefs_in_townsfolk(Me, Accuser, UpdatedCertainty);
	   	add_player_thought(Me, Accuser, " has voted to lynch ", Accused, " and I think ", Accused, " is a werewolf. ", Accuser, " may be a townsperson.");		   
		}.
/* Remove eliminated player from database */
+dead(_, _ , Player, Role)
	: .my_name(Player)
	<- .print("I'm dead").
+dead(Day, Period ,Player, werewolf)
	<- 	.print(Player, " has died.");
		.abolish(werewolf(Player,_,_));
		.abolish(townsfolk(Player,_,_));
		.abolish(everyone(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)). 
+dead(Day, Period ,Player, _)
	<-  .print(Player, " has died.");
		.abolish(townsfolk(Player,_,_));
		.abolish(werewolf(Player,_,_));
		.abolish(everyone(Player));
		.my_name(Me);
	   	.send(game_coordinator, tell, ready(Day, Period, Me)).	
	   	
/* Required for interoperability */
+vote_for_in_exchange(Day, Accuser, Accused, Promised)
	<- /* Reject the plan straight away */
	   .my_name(Me);
	   .send(Accuser, tell, reject_vote_for_in_exchange(Day, Me, Accused, Promised)).	   	 	