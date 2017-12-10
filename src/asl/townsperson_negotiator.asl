/* Rules */
finished_negotiations(Day) :-
	.count(utility(Day, _, _, _, _), CntNegotiations) &
	.count(player(_), CntPlayers) &
	//.findall(Name, utility(Day, _, Name, _, _), Names) &
	//.print("(CntNegotiations -1)=", CntNegotiations - 1, " CntPlayers=", CntPlayers, " Names=", Names) &
	(CntNegotiations - 1) == CntPlayers.

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
	<- /* The accuser becomes more suspect */
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
	<- /* Delete the player from the database */
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
	   /* Remove votes for player eliminated after updating the beliefs */
	   //.abolish(voted_to_lynch(_, _, Player));
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
	   /* Remove votes for player eliminated after updating the beliefs */
	   //.abolish(voted_to_lynch(_, _, Player));
	   .send(game_coordinator, tell, ready(Day, Period, Me)).
	   
/* When does negotiation happen?
 * During the day, when all the town is awake
 * 
 * How are negotiation strategies chosen?
 * The strategy chosen is based on the certainty that the other player is a werewolf
 * The higher the certainty, the stronger the negotiation tactic
 * 
 * When does the negotiation stop?
 * Once a negotiation attempt has been successful the agent will withdraw from the
 * negotiation table and drop all ongoing negotiations 
 * (including the ones he has started himself)
 * - OR -
 * When an agent has received negotiation attempts from all the other agents and finished
 * the negotiation they have started themselves. The decision to take is based on the 
 * utility score of taking each possibility.
 * 
 * What are the types of negotiation?
 * 1. Appeal to authority
 * 2. Promise of future reward
 * 
 * (1). A player can tell other players about it's level of belief that another player
 * is a werewolf. It's up to other players to believe him or not.
 * 
 * (2) A player can ask another to vote for someone the player thinks is a werewolf by
 * making a promise to the other that the player will return the favor.
 *     + The other player may choose to believe the proposer or not depending on how
 *       much they trust them
 *     + The proposer may choose not to hold their part of the promise, resulting in
 *       a hit to their reputation
 *     + Trustworthiness depends on whether or not the parties believe they are in the same
 *       team, i.e. they're both werewolves or townsfolk 
 * The steps of this interaction are:
 *     + The proposer sends a message to (all?) other players asking them to vote for 
 *       player X
 *     + The players who choose to accept the proposal send a message telling the proposer
 *       who they want them to vote for in return in the next round
 *     + The proposer looks at his options and takes the one that aligns the most
 *       with its own goals
 *     + Next turn the proposer must choose between keeping or breaking their promise
 *     + Depending on that choice, the proposee updates their beliefs about the proposer
 */
 
 /* Wake up */
+day(Day)
	<- !negotiate(Day).
	   
/* Begin a negotiation */
+!negotiate(Day)
	: .random(R) & R > 0.5 & Day > 1
	<- !promise_of_future_reward(Day).

+!negotiate(Day)
	/* TODO(jp): Precondition to choose this plan over the others */
	<- !appeal_to_authority(Day).
	
/*
 * Appeal to authority
 */
	
/* Start an appeal to authority */ 
+!appeal_to_authority(Day)
	<- .my_name(Me);
	   /* Select the player that is most likely a werewolf */
	   .findall([Werewolf, Certainty], werewolf(Werewolf, Certainty), Certainties);
	   lib.select_max_or_random(Certainties, Player);
	   ?townsperson(Player, MaxCertainty);
	   /* Ask other players to vote for someone */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, vote_for(Day, Me, Player, MaxCertainty));
	   /* Estimate the utility of its own plan */
	   Utility = MaxCertainty;
	   +utility(Day, own_decision, Me, Player, Utility);
	   !decide(Day).
	   
/* Stub for non-negotiating agents */
+vote_for(Day, Accuser, Accused, -1)
	<- +utility(Day, stub, Accuser, Accused, -100.0);
	   !decide(Day).
	   
/* When receiving a request to vote for someone */
+vote_for(Day, Accuser, Accused, AccuserCertainty)
	: /* If the player is not the accuser or being accused */
	  not .my_name(Accused) & not .my_name(Accuser) &
	  /* And the accuser is trustworthy */
	  werewolf(Accuser, Distrust) & Distrust <= 0.3 &
	  /* And the accused is untrustworthy */
	  townsfolk(Accused, Trust) & Trust < AccuserCertainty
	<- /* Estimate the utility of this plan */
	   Utility = (Distrust + AccuserCertainty) / 2;
	   +utility(Day, appeal_to_authority, Accuser, Accused, Utility);
	   /* Make a decision */
	   !decide(Day).

/* When receiving a request to vote that is not good */
+vote_for(Day, Accuser, Accused, AccuserCertainty)
	<- +utility(Day, appeal_to_authority, Accuser, Accused, -1.0);
	   !decide(Day).
	   
/*
 * Promise of future reward
 * To avoid locks, if a player is already enagaged in a promise negotiation then it
 * cannot start a promise negotiation himself or accept any promises coming from other
 * agents. 
 */
 
/* Start a promise of future reward */
+!promise_of_future_reward(Day)
	: not engaged_in_promise_negotiation(Day)
	<- .my_name(Me);
	   /* Agent becomes engaged in its own promise negotiation */
	   +engaged_in_promise_negotiation(Day)
	   /* Select the player that is most likely a werewolf */
	   .findall([Werewolf, Certainty], werewolf(Werewolf, Certainty), Certainties);
	   lib.select_max_or_random(Certainties, Player);
	   /* Select the player that is trying the hardest to eliminate another */
	   .findall([Accuser, Accused], voted_to_lynch(_, Accuser, Accused), Votes);
	   lib.remove_player_from_vote_list(Me, Votes, FilteredVotes);
	   lib.select_most_common_or_random(FilteredVotes, [Accuser, Accused]);
	   .print("I'm promising ", Accuser, " that I will vote for ", Accused, " if he votes for ", Player, " (Votes=", Votes, ")");
	   /* Send the request to the target player */
	   .send(Accuser, tell, vote_for_in_exchange(Day, Me, Player, Accused));
	   /* Store my own request
	   +vote_for_in_exchange(Day, Me, Player, Accused); */
	   /* Send an empty vote_for request to the others */
	   .findall(Name, player(Name), Others);
	   for (.member(Other, Others)) {
	       if (not Other == Accuser) {
	       	   .send(Other, tell, vote_for(Day, Me, Accused, -1));
	       }
	   }.
	   
/* If the player is already engaged in a promise negotiation */
+!promise_of_future_reward(Day)
	: engaged_in_promise_negotiation(Day)
	/* Fall back to appeal to authority */
	<- !appeal_to_authority(Day).
	
/* When receiving a promise of future reward */
+vote_for_in_exchange(Day, Accuser, Accused, Promised)
	: /* If the player is not the accuser or being accused */
	  not .my_name(Accused) & not .my_name(Accuser) & werewolf(Promised, _) &
	  /* And the accuser is trustworthy */
	  werewolf(Accuser, Distrust) & Distrust <= 0.3 &
	  /* And the accused is untrustworthy */
	  townsperson(Accused, Trust) & Trust <= 0.3 &
	  /* If I'm not engaged in a promise negotiation */
	  not engaged_in_promise_negotiation(Day)
	<- /* Agent becomes engaged in a promise negotiation */
	   +engaged_in_promise_negotiation(Day);
	   /* Calculate the utility of the plan */
	   ?werewolf(Promised, PromisedDistrust);
	   Utility = Distrust + PromisedDistrust;
	   .print("Utility of accepting the promise proposal=", Utility);
	   +utility(Day, promise_of_future_reward, Accuser, Accused, Utility);
	   !decide(Day).
	   /* TODO(jp): Remember that the accuser has promised to vote for Promised */
	
/* When receiving a vote_for_in_exchange from itself do nothing 
+vote_for_in_exchange(Day, Accuser, Accused, Promised) 
	: .my_name(Accuser). */
	
/* When receiving a request to vote that is not good */
+vote_for_in_exchange(Day, Accuser, Accused, Promised)
	<- +utility(Day, promise_of_future_reward, Accuser, Accused, -1.0);
	   /* Reject the plan straight away */
	   .my_name(Me);
	   .send(Accuser, tell, reject_vote_for_in_exchange(Day, Me, Accused, Promised));
	   !decide(Day).
	   
/* When the promise was accepted */
+accept_vote_for_in_exchange(Day, Partner, Accused, Promised)
	<- .print(Partner, " has accepted my proposal");
	   /* Calculate the utility of this plan */
	   ?werewolf(Accused, UtilityAccused);
	   ?werewolf(Promised, UtilityPromised);
	   .print("UtilityAccused=", UtilityAccused, " UtilityPromised=", UtilityPromised);
	   Utility = UtilityAccused + UtilityPromised;
	   .my_name(Me);
	   +utility(Day, own_decision, Me, Accused, Utility);
	   !decide(Day).
	   
/* When the promise was rejected */
+reject_vote_for_in_exchange(Day, Partner, Accused, Promised)
	<- .print(Partner, " has refused my proposal");
	   /* Calculate the utility of this plan */
	   ?werewolf(Accused, Utility);
	   .my_name(Me);
	   +utility(Day, own_decision, Me, Accused, Utility);
	   !decide(Day).

/* Make a decision */
+!decide(Day) : not finished_negotiations(Day).
+!decide(Day) : finished_negotiations(Day) & decided(Day).
+!decide(Day)
	: finished_negotiations(Day) & not decided(Day)
	<- +decided(Day);
	   .my_name(Me);
	   /* Select the plan with the most utility */
	   .findall(Utility, utility(Day, _, _, _, Utility), Utilities);
	   lib.max_utility(Utilities, MaxUtility);
	   ?utility(Day, Type, Accuser, Accused, MaxUtility);
	   /* If the type is a promise of future reward, then accept the promise */
	   if (Type == promise_of_future_reward) {
	   	   .print("I'm accepting ", Accuser, "'s proposal");
	       ?vote_for_in_exchange(Day, Accuser, Accused, Promised);
	       .send(Accuser, tell, accept_vote_for_in_exchange(Day, Me, Accused, Promised));
	       add_player_thought(Me, Accuser, " has promised me that he will vote for ", Promised, " next round if I vote for ", Accused, " now. I'm accepting his proposal.");
	   };
	   if (Type == appeal_to_authority) {
	   	   add_player_thought(Me, Accuser, " has told me that ", Accused, " is a werewolf. I believe him.");
	   };
	   if (Type == own_decision) {
	   	   .print("I've decided to vote for ", Accused);
	   	   add_player_thought(Me, "I've decided to vote for ", Accused, ".");
	   };
	   /* Vote to lynch the player */
	   .send(game_coordinator, tell, voted_to_lynch(Day, Me, Accused));
	   /* Tell everyone else who the player is voting for */
	   .findall(Name, player(Name), Players);
	   .send(Players, tell, voted_to_lynch(Day, Me, Accused));
	   /* TODO(jp): Reject pending proposals */
	   .findall(O, vote_for_in_exchange(Day, O, _, _), Os);
	   for (.member(Other, Os)) {
	       if (not Other == Accuser) {
	       	   .print("Rejecting proposal of ", Other);
	           ?vote_for_in_exchange(Day, Other, Acc, Pro);
	           .send(Other, tell, reject_vote_for_in_exchange(Day, Me, Acc, Pro));
	       }	
	   }.
