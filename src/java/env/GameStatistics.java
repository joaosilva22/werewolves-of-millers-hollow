package env;

public class GameStatistics {
	// Game Statistics:
	// Who won
	// In how many rounds
	// How many players of each type
	
	// Session statistcs:
	// Number of games the townsfolk won
	// NUmber of games the werewolves won
	// Average number of rounds
	public enum Team { Townsfolk, Werewolves };
	
	public Team winner;
	public int rounds;
	
	public int random_townsfolk;
	public int strategic_townsfolk;
	public int negotiator_townsfolk;
	
	public int random_werewolves;
	public int strategic_werewolves;
	public int negotiator_werewolves;
}
