package env;

import java.util.ArrayList;

public class TownModel {
	private ArrayList<String> messages;
	private ArrayList<PlayerData> players;
	private TownView view;
	
	public TownModel() {
		messages = new ArrayList<>();
		players = new ArrayList<>();
	}
	
	public boolean addMessage(String message) {
		messages.add(message);
		view.printMessage(message);
		return true;
	}
	
	public boolean addPlayer(String name) {
		players.add(new PlayerData(name));
		view.updatePlayers(players);
		return true;
	}
	
	public PlayerData getPlayerData(String name) {
		int idx = players.indexOf(new PlayerData(name));
		return players.get(idx);
	}
	
	public boolean removePlayer(String name) {
		int idx = players.indexOf(new PlayerData(name));
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
		int idx = players.indexOf(new PlayerData(name));
		players.get(idx).addThought(thought);
		view.updateBeliefs(players);
		return true;
	}
}
