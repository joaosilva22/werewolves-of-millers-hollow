package env;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TownModel {
	private ArrayList<String> messages;
	private List<PlayerData> players;
	private TownView view;
	private TownEnvironment env;
	private int numberOfTownsfolk;
	private int numberOfWerewolves;
	private int numberOfRandomTownsfolk;
	private int numberOfRandomWerewolves;
	
	public TownModel(TownEnvironment e) {
		messages = new ArrayList<>();
		players = Collections.synchronizedList(new ArrayList<PlayerData>());
		env = e;
		numberOfTownsfolk = 6;
		numberOfWerewolves = 2;
	}
	
	public boolean addMessage(String message) {
		messages.add(message);
		view.printMessage(message);
		return true;
	}
	
	public boolean addPlayer(String name, String role) {
		players.add(new PlayerData(name, role));
		view.updatePlayers(players);
		return true;
	}
	
	public PlayerData getPlayerData(String name) {
		int idx = players.indexOf(new PlayerData(name, ""));
		return players.get(idx);
	}
	
	public boolean removePlayer(String name) {
		int idx = players.indexOf(new PlayerData(name, ""));
		players.get(idx).setAlive(false);
		view.updatePlayers(players);
		view.updateBeliefs(players);
		return true;
	}
	
	public void setView(TownView v) {
		view = v;		
		view.pack();
        view.setVisible(true);
	}
	
	public boolean updateBeliefs() {
		view.updateBeliefs(players);
		return true;
	}
	
	public boolean addPlayerThought(String name, String thought) {
		int idx = players.indexOf(new PlayerData(name, ""));
		players.get(idx).addThought(thought);
		view.updateBeliefs(players);
		return true;
	}
	
	public void setNumberOfWerewolves(int n) {
		numberOfWerewolves = n;
	}
	
	public int getNumberOfWerewolves() {
		return numberOfWerewolves;
	}
	
	public void setNumberOfTownsfolk(int n) {
		numberOfTownsfolk = n;
	}
	
	public int getNumberOfTownsfolk() {
		return numberOfTownsfolk;
	}
	
	public int getNumberOfRandomTownsfolk() {
		return numberOfRandomTownsfolk;
	}
	
	public void setNumberOfRandomTownsfolk(int n) {
		numberOfRandomTownsfolk = n;
	}
	
	public int getNumberOfRandomWerewolves() {
		return numberOfRandomWerewolves;
	}
	
	public void setNumberOfRandomWerewolves(int n) {
		numberOfRandomWerewolves = n;
	}
	
	public void run() {
		env.run();
	}
	
	public void clear() {
		messages.clear();
		players.clear();
		view.clear();
	}
}
