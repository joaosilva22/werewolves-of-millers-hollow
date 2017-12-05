/* Initial beliefs */
required_players(8).

/* Rules */
enough_players :- 
	required_players(MinPlayer) &
	.count(role(townsperson, _), CntTownsfolk) &
	.count(role(werewolf, _), CntWerewolves) &
	CntPlayer = CntTownsfolk + CntWerewolves  + 1 &
	CntPlayer >= MinPlayer.
	
all_werewolves_voted(Day) :-
	.count(role(werewolf, _), CntWerewolves) &
	.count(voted_to_eliminate(Day, _, _), CntVotes) &
	CntWerewolves == CntVotes.
	
everyone_has_voted(Day) :-
	.count(role(_, _), CntPlayers) &
	.count(voted_to_lynch(Day, _, _), CntVotes) &
	CntPlayers == CntVotes.
	
townsfolk_have_won :-
	.count(role(werewolf, _), CntWerewolves) &
	/* print_env(CntWerewolves, " werewolves are still alive.") & */
	CntWerewolves == 0.
	
werewolves_have_won :-
	.count(role(werewolf, _), CntWerewolves) &
	.count(role(_, _), CntPlayers) &
	/* print_env((CntPlayers-CntWerewolves), " players are still alive.") & */
	(CntPlayers-CntWerewolves) == 0.

/* Initial goals */
!setup_game.

/* Plans */
+role(Role, Player)
	<- add_player(Player);
	   .print("Player ", Player, " (", Role ,") has joined the game.");	
	   !setup_game.

/*
 * Game setup
 */

/* Do the initial setup and start the game */
+!setup_game
	: enough_players & not setup
	<- +setup
	   ?required_players(MinPlayer);
	   .count(role(_, _), CntPlayer);
	   .print("(", CntPlayer, "/", MinPlayer, ") have joined. Starting the game.");
	   .findall([Role, Name], role(Role, Name), Players);
	   !inform_townsfolk(Players);
	   !inform_werewolves(Players);
	   !inform_fortune_teller(Players)
	   !start_turn(1).
+!setup_game
	: not enough_players
	<- .print("Not enough players have joined").
+!setup_game
	: setup
	<- .print("Game has already begun.").
	
/* Tell fortune_teller about the other players */
+!inform_fortune_teller([])
	<- true.
+!inform_fortune_teller([[_,Player]|T])
	: setup
	<- .send(fortune_teller, tell, player(Player));
	   !inform_fortune_teller(T).
	
/* Tell townsfolk about the other players */
+!inform_townsfolk([])
	<- true.
+!inform_townsfolk([[_,Player]|T])
	: setup
	<- .findall(Name, role(townsperson, Name), Townsfolk);
	   .send(Townsfolk, tell, player(Player));
	   !inform_townsfolk(T).

/* Inform werewolves about the other players */
+!inform_werewolves([])
	<- true.
+!inform_werewolves([[werewolf, Player]|T])
	: setup
	<- .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, werewolf(Player));
	   !inform_werewolves(T).
+!inform_werewolves([[_, Player]|T])
	: setup
	<- .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, player(Player));
	   !inform_werewolves(T).
	   
/*
 * Game loop
 */

/* Begins the turn */
+!start_turn(Day)
	<- !wake_up_werewolves(Day).

/* Wake up fortune teller */
+!wake_up_fortune_teller(Day)
	<- print_env("The fortune teller wakes up...");
	   .send(fortune_teller, tell, find_true_personality(Day)).	
	
/* Before waking up the werewolves, check if there are any still alive */
+!wake_up_werewolves(Day)
	: townsfolk_have_won
	<- print_env("The townsfolk have won in ", Day, " days.").
	
/* Before waking up the werewolves, check if there is any townsfolk left alive */
+!wake_up_werewolves(Day)
	: werewolves_have_won
	<- print_env("The werewolves have won in ", Day, " days.").
	
/* Wake up the werewolves */
+!wake_up_werewolves(Day)
    : not townsfolk_have_won & not werewolves_have_won
	<- print_env("It is the night of day ", Day, ". The werewolves wake up...");
	   .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, night(Day)).

/* When all the werewolves have voted, someone is killed */
+voted_to_eliminate(Day, Werewolf, Player)
	: all_werewolves_voted(Day) 
	<- print_env("All werewolves have voted.");
	   .findall(Vote, voted_to_eliminate(Day, _, Vote), Votes);
	   werewolves_of_millers_hollow.actions.count_player_votes(Votes, MostVotedPlayers, MostVotedCnt);
	   .length(MostVotedPlayers, CntMostVotedPlayers);
	   if (CntMostVotedPlayers > 1) 
	   {
	   	   /* The werewolves could not reach an agreement, so nobody dies */
	       print_env("The werewolves were not able to agree on a victim. Nobody dies tonight.");
	       !wake_up_town(Day);
	   }
	   else 
	   {
	   	   /* Eliminate the player from the game */	
	   	   .nth(0, MostVotedPlayers, DeadPlayer);
	   	   ?role(Role, DeadPlayer);
	   	   .abolish(role(_, DeadPlayer));
	   	   !wake_up_town(Day, DeadPlayer, Role);
	   }.
	   
/* Wake up the town */
+!wake_up_town(Day)
	<- print_env("It is the morning of day ", Day, ". The people of the town wake up.");
	   .findall(Player, role(_, Player), Players);
	   .send(Players, tell, day(Day)).
	   
/* Before waking up the town, check if there is any townsfolk still alive */
+!wake_up_town(Day, _, _)
	: werewolves_have_won
	<- print_env("The wereolves have won in ", Day, " days.").

/* Wake up the town when somebody was killed during the night */
+!wake_up_town(Day, Player, Role)
	<- print_env("It is the morning of day ", Day, ".") 
	   print_env("The people of the town wake up, just to find that something terrible happened during the night!");
	   print_env(Player, " was found dead with bite marks.");
	   print_env("Upon further inspection of the body, it was discovered that they were a ", Role, ".");
	   /* Tell others about the death of the player */
	   .findall(Other, role(_, Other), Others);
	   .send(Others, tell, dead(Player, Role));
	   /* Wake everyone up */
	   .send(Others, tell, day(Day)).
	   
/* When everyone in the town has voted, someone is lynched */
+voted_to_lynch(Day, Accuser, Player)
	: everyone_has_voted(Day)
	<- print_env("The town has finished deliberating.");
	   .findall(Vote, voted_to_lynch(Day, _, Vote), Votes);
	   werewolves_of_millers_hollow.actions.count_player_votes(Votes, MostVotedPlayers, MostVotedCnt);
	   .length(MostVotedPlayers, CntMostVotedPlayers);
	   if (CntMostVotedPlayers > 1) 
	   {
	   	   /* The town could not reach an agreement, so nobody dies */
	       print_env("The town could not reach an agreement, so nobody was lynched.");
	   } 
	   else 
	   {
	   	   /* Eliminate the player from the game */	
	   	   .nth(0, MostVotedPlayers, DeadPlayer);
	   	   ?role(Role, DeadPlayer);
	   	   .abolish(role(_, DeadPlayer));
	   	   /* Tell others about the death of the player */
	   	   print_env(DeadPlayer, " was lynched.");
	   	   print_env("After inspecting the body it was determined that they were a ", Role, ".");
	   	   .findall(Other, role(_, Other), Others);
	   	   .send(Others, tell, dead(DeadPlayer, Role));
	   };
	   /* Send the town to sleep */
	   print_env("The town goes to sleep, hoping for the best.")
	   !start_turn(Day + 1).
	   
/* Tell to the fortune_teller the true personality of a Player */
+tell_personality(Player)
	:true
	<- ?role(Role, Player);
	   .send(fortune_teller, tell, true_identity(Player, Role)).
