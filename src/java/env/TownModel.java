package env;

import java.util.ArrayList;

public class TownModel {
	private TownView view;
	
	private ArrayList<PlayerData> players;
	private ArrayList<String> messages;
	
	public TownModel() {
		messages = new ArrayList<>();
		players = new ArrayList<>();
	}
	
	public void setView(TownView v) {
		view = v;		
		view.pack();
        view.setVisible(true);
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
}
