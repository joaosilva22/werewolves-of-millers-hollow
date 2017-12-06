package env;

import java.util.ArrayList;
import java.util.HashMap;

public class PlayerData {
	private HashMap<String, Float> beliefsInTownsfolk;
	private HashMap<String, Float> beliefsInWerewolves;
	private String name;
	private boolean alive;
	private ArrayList<String> thoughts;
	
	public PlayerData(String n) {
		beliefsInTownsfolk = new HashMap<>();
		beliefsInWerewolves = new HashMap<>();
		name = n;
		alive = true;
		thoughts = new ArrayList<>();
	}
	
	public void addBeliefInTownsperson(String townsperson, float certainty) {
		beliefsInTownsfolk.put(townsperson, certainty);
	}
	
	public void addBeliefInWerewolf(String werewolf, float certainty) {
		beliefsInWerewolves.put(werewolf, certainty);
	}
	
	@Override
	public boolean equals(Object obj) {
		return name.equals(((PlayerData) obj).getName());
	}
	
	public HashMap<String, Float> getBeliefsInTownsfolk() {
		return beliefsInTownsfolk;
	}
	
	public HashMap<String, Float> getBeliefsInWerewolves() {
		return beliefsInWerewolves;
	}
	
	public String getName() {
		return name;
	}
	
	public void setAlive(boolean a) {
		alive = a;
	}
	
	public boolean isAlive() {
		return alive;
	}
	
	public void addThought(String thought) {
		thoughts.add(thought);
	}
	
	public ArrayList<String> getThoughts() {
		return thoughts;
	}
}
