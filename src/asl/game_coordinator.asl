/* Initial beliefs */
required_players(8).

/* Rules */
enough_players :- 
	required_players(MinPlayer) &
	.count(role(townsperson, _), CntTownsfolk) &
	.count(role(werewolf, _), CntWerewolves) &
	CntPlayer = CntTownsfolk + CntWerewolves &
	CntPlayer >= MinPlayer.
	
all_werewolves_voted(Day) :-
	.count(role(werewolf, _), CntWerewolves) &
	.count(vote(_, Day, _), CntVotes) &
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
	   !start_turn(1).
+!setup_game
	: not enough_players
	<- .print("Not enough players have joined").
+!setup_game
	: setup
	<- .print("Game has already begun.").
	
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
	<- .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, day(Day)).
+!start_turn(_)
	: true
	<- .print("Reached day number 5.").

/* Receive werewolf votes */
+vote(Werewolf, Day, Player)
	: all_werewolves_voted(Day) 
	<- .print("Werewolf ", Werewolf, " voted. Day=", Day, " Player=", Player);
	   .print("All werewolves have voted.");
	   .findall(Name, role(_, Name), Players);
	   !get_highest_voted_player(Day, Players, 0, VotedPlayer).
+vote(Werewolf, Day, Player)
	: not all_werewolves_voted(Day)
	<- .print("Werewolf ", Werewolf, " voted. Day=", Day, " Player=", Player).
	   
/* Get the player with highest number of votes */
+!get_highest_voted_player(Day, [], CntVotes, VotedPlayer)
	: true
	<- .print("The player with the most votes is ", VotedPlayer, " with ", CntVotes, " votes.");
	   !kill_player(Day, VotedPlayer). 
+!get_highest_voted_player(Day, [Player|T], CntMax, PlayerMax)
	: true
	<- .findall(Player, vote(_, Day, Player), Votes);
	   .length(Votes, CntPlayer);
	   if (CntPlayer >= CntMax) 
	   {
	       !get_highest_voted_player(Day, T, CntPlayer, Player);	
	   }
	   else 
	   {
	   	   !get_highest_voted_player(Day, T, CntMax, PlayerMax);
	   }.

/* Eliminate a player from the game */
+!kill_player(Day, Player)
	: true
	<- -role(Role, Player);
	   !inform_of_dead_player(Day, Player, Role).
	   
/* Inform players that someone has been eliminated */
+!inform_of_dead_player(Day, Name, Role)
	: true
	<- .findall(Player, role(_, Player), Players);
	   .send(Players, tell, dead(Player, Role))
	   !start_turn(Day + 1).