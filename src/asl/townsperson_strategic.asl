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
	   .print("Adding player ", Player);
	   +townsperson(Player, 0.0);
	   +werewolf(Player, 0.0).

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
	   /* Select the player that his most likely a werewolf */
	   .findall(Certainty, werewolf(_, Certainty), Certainties);
	   .max(Certainties, MaxCertainty);
	   ?werewolf(Player, MaxCertainty);
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Player));
	   /* Tell everyone else who the player is voting for */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, voted_to_lynch(Day, Me, Player));
	   /* Necessary to interact with negotiating agents */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, vote_for(Day, Me, Player, -1)).

/*
 * How are the beliefs represented?
 * Beliefs are accompanied by a certainty factor that ranges from 0 to 1. For example, if an agent believes another to be a werewolf
 * then the belief werewolf(other, 0.5) would be in its belief base, meaning that the agent is reasonably sure that other is a werewolf.
 * 
 * When are the beliefs updated?
 * 1. When the players find out how the others have voted
 * 2. When the players wake up and find out who's been killed
 *  
 * (1) From the other players votes the players can determine
 *     + Who the other voter wants to see dead
 *     + If the voter wants to kill the player, then the player may suspect that the voter is a werewolf
 *     + If the voter wants to kill a player that the player thinks is a werewolf, then the player may suspect the voter is a townsperson
 *     + If the voter wants to kill a player that the player thinks is a townsperson, then the player may suspect the voter is a werewolf
 * The beliefs must be revised every time, and past information should be taken into account in future belief updates. If the player receives
 * contradicting information then their belief will stay the same (most likely).
 * 
 * (2) When the player finds out who's been killed he can determine:
 *     + If the player believes some players wanted the player who died dead, then the player may suspect that they are werewolves
 */
 
/* Update the beliefs from other players' votes */
/* TODO(jp): See (1) */

/* When the player is accused of being a werewolf */
+voted_to_lynch(_, Accuser, Accused)
	: .my_name(Accused)
	<- .findall(X, werewolf(X, _), Xs);
	   .print("I'me being accused of being a werewolf by ", Accuser, " Xs=", Xs);
	   /* The accuser becomes more suspect */
	   ?werewolf(Accuser, Certainty);
	   UpdatedCertainty = Certainty + 0.1;
	   .abolish(werewolf(Accuser, _));
	   +werewolf(Accuser, UpdatedCertainty).
	   
/* When the player believes the accused is a townsperson */
+voted_to_lynch(_, Accuser, Accused)
	: townsperson(Accused, Certainty) & Certainty >= 0.3
	<- /* The accuser becomes more suspect */
	   ?werewolf(Accuser, OldCertainty);
	   UpdatedCertainty = OldCertainty + 0.1;
	   .abolish(werewolf(Accuser, _));
	   +werewolf(Accuser, UpdatedCertainty);
	   /* Add thought proccess to the gui */
	   .my_name(Me);
	   add_player_thought(Me, Accuser, " has voted to lynch ", Accused, " but I think ", Accused, " is a townsperson. ", Accuser, " may be a werewolf.").
	   
/* When the player believes the accused is a werewolf */
+voted_to_lynch(_, Accuser, Accused)
	: werewolf(Accused, Certainty) & Certainty >= 0.3
	<- /* The accuser becomes less suspect */
	   ?townsperson(Accuser, OldCertainty);
	   UpdatedCertainty = OldCertainty + 0.1;
	   .abolish(townsperson(Accuser, _));
	   +townsperson(Accuser, UpdatedCertainty);
	   /* Add thought proccess to the gui */
	   .my_name(Me);
	   add_player_thought(Me, Accuser, " has voted to lynch ", Accused, " and I think ", Accused, " is a werewolf. ", Accuser, " may be a townsperson.").
	
/* Remove eliminated players from database and update beliefs */
/* TODO(jp): Update the beliefs; see (2) */
+dead(Day, Period, Player, Role)
	: .my_name(Player)
	<- .print("I'm ded").

/* When a werewolf has been eliminated from the game */
+dead(Day, Period, Player, werewolf)
	: not .my_name(Player)
	<- /* Update the number of living werewolves */
	   ?living_werewolves(Werewolves); 
	   -+living_werewolves(Werewolves-1);
	   /* Delete the player from the database */
	   /* TODO(jp): Abstract this away */
	   .print(Player, " has died");
	   .abolish(player(Player));
	   .abolish(werewolf(Player, _));
	   .abolish(townsperson(Player, _));
	   .abolish(voted_to_lynch(_, Player, _));
	   /* Players who have tried to kill the dead werewolf become less suspect */
	   .findall(Accuser, voted_to_lynch(_, Accuser, Player), Accusers);
	   werewolves_of_millers_hollow.actions.unique_elements(Accusers, UniqueAccusers);
	   .my_name(Me);
	   for (.member(X, UniqueAccusers)) {
	   	   /* Update the certainty factor */
	   	   ?townsperson(X, Certainty);
	   	   UpdatedCertainty = Certainty + 0.1;
	   	   .abolish(townsperson(X, _));
	   	   +townsperson(X, UpdatedCertainty);
	       /* Update the beliefs in the gui */
	       update_beliefs_in_townsfolk(Me, X, UpdatedCertainty);
	       /* Add thought proccess to the gui */
	       add_player_thought(Me, X, " has voted to lynch ", Player, " in the past and ", Player, " was a werewolf. ", X, " may be a townsperson.");
	   };
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
	   
/* When another player has been eliminated from the game */
+dead(Day, Period, Player, townsperson)
    : not .my_name(Player)
	<- /* Delete the player from the database */
	   /* TODO(jp): Abstract this away */
	   .print(Player, " has died");
	   .abolish(player(Player));
	   .abolish(werewolf(Player, _));
	   .abolish(townsperson(Player, _));
	   .abolish(voted_to_lynch(_, Player, _));
	   /* Players who have tried to kill the dead townsperson become more suspect */
	   .findall(Accuser, voted_to_lynch(_, Accuser, Player), Accusers);
	   werewolves_of_millers_hollow.actions.unique_elements(Accusers, UniqueAccusers);
	   .my_name(Me);
	   for (.member(X, UniqueAccusers)) {
	   	   /* Update the certainty factor */
	   	   ?werewolf(X, Certainty);
	   	   UpdatedCertainty = Certainty + 0.1;
	   	   .abolish(werewolf(X, _));
	   	   +werewolf(X, UpdatedCertainty);
	       /* Update the beliefs in the gui */
	       update_beliefs_in_werewolves(Me, X, UpdatedCertainty);
	       /* Add thought proccess to the gui */
	       add_player_thought(Me, X, " has voted to lynch ", Player, " in the past and ", Player, " was a townsperson. ", X, " may be a werewolf.");
	   };
	   .send(game_coordinator, tell, ready(Day, Period, Me)).