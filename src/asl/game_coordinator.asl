/* Initial beliefs */
required_players(8).
day(1).

/* Rules */
enough_players :- 
	required_players(MinPlayer) &
	.count(role(townsperson, _), CntTownsfolk) &
	.count(role(werewolf, _), CntWerewolves) &
	CntPlayer = CntTownsfolk + CntWerewolves &
	CntPlayer >= MinPlayer.
	
all_werewolves_voted :-
	day(Day) &
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
	   !start_turn.
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
+!start_turn
	: day(Day) & Day < 5
	<- ?day(Day);
	   .findall(Name, role(werewolf, Name), Werewolves);
	   .send(Werewolves, tell, day(Day)).
+!start_turn
	: true
	<- .print("Reached day number 5.").

/* Receive werewolf vote */
+vote(Werewolf, Day, Player)
	: all_werewolves_voted
	<- .print("Werewolf ", Werewolf, " voted. Day=", Day, " Player=", Player);
	   .print("All werewolves have voted.");
	   -+day(Day + 1);
	   !start_turn.
+vote(Werewolf, Day, Player)
	: not all_werewolves_voted
	<- .print("Werewolf ", Werewolf, " voted. Day=", Day, " Player=", Player).
	
/* Count the votes for a player */
+!count_votes(Day, Player, CntVotes)
	: true
	<- .findall(Player, vote(_, Day, Player), Votes);
	   .length(Votes, CntVotes).