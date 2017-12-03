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
	.count(voted_to_murder(_, Day, _), CntVotes) &
	CntWerewolves == CntVotes.

/* Initial goals */
!setup_game.

/* Plans */
+role(Role, Player)
	: true
	<- .print("Player ", Player, " (", Role ,") has joined the game.");
	   !setup_game.

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

/* Begins the turn */
+!start_turn(Day)
	: Day < 5
	<- 	!wake_up_fortune_teller(Day);
		!wake_up_werewolves(Day).
+!start_turn(_)
	<- .print("Reached day number 5.").

/* Wake up fortune teller */
+!wake_up_fortune_teller(Day)
	<- .print("The fortune teller wakes up...");
	   .send(fortune_teller, tell, find_true_personality(Day)).	
	
/* Wake up werewolves */
+!wake_up_werewolves(Day)
	<- .print("The werewolves wake up...");
	   .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, day(Day)).

/* Receive votes from werewolves */
+voted_to_murder(Werewolf, Day, Player)
	: all_werewolves_voted(Day) 
	<- .print("All werewolves have voted.");
	   .findall(Vote, voted_to_murder(_, Day, Vote), Votes);
	   actions.count_player_votes(Votes, MostVotedPlayers, MostVotedCnt);
	   .length(MostVotedPlayers, CntMostVotedPlayers);
	   if (CntMostVotedPlayers > 1) 
	   {
	       .print("Thats a tie! Players=", MostVotedPlayers, " VoteCnt=", MostVotedCnt);
	       !start_turn(Day + 1);
	   } 
	   else 
	   {
	   	   .nth(0, MostVotedPlayers, DeadPlayer);
	   	   .print(DeadPlayer, " has been murdered.");
	   	   !eliminate_player(Day, DeadPlayer);
	   }.

/* Eliminate a player from the game */
+!eliminate_player(Day, DeadPlayer)
	: true
	<- ?role(Role, DeadPlayer);
	   -role(_, DeadPlayer);
	   !inform_of_dead_player(Day, DeadPlayer, Role).
	   
/* Inform players that someone has been eliminated */
+!inform_of_dead_player(Day, DeadPlayer, Role)
	: true
	<- .findall(Player, role(_, Player), Players);
	   .send(Players, tell, dead(DeadPlayer, Role));
	   !start_turn(Day + 1).
	   
/* Wake up townsfolk */
+!wake_up_townsfolfk(Day)
	<- .findall(Player, role(townsperson, Player), Townsfolk);
	   .send(Townsfolk, tell, day(Day)).
	   
/* Tell to the fortune_teller the true personality of a Player */
+tell_personality(Player)
	:true
	<- ?role(Role, Player);
	   .send(fortune_teller, tell, true_identity(Player, Role)).	  
	  	   