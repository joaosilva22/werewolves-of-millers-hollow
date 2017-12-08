package env;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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
	private ArrayList<GameStatistics> statistics;
	
	public TownModel(TownEnvironment e) {
		messages = new ArrayList<>();
		players = Collections.synchronizedList(new ArrayList<PlayerData>());
		env = e;
		numberOfTownsfolk = 6;
		numberOfWerewolves = 2;
		statistics = new ArrayList<>();
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
	
	public void createGameStatistics() {
		statistics.add(new GameStatistics());
	}
	
	public GameStatistics getLatestGameStatistics() {
		if (statistics.isEmpty()) return null;
		return statistics.get(statistics.size() - 1);
	}
	
	public List<GameStatistics> getSessionGameStatistics() {
		return statistics;
	}
	
	public void clear() {
		messages.clear();
		players.clear();
		view.clear();
	}
	
	public void writeStats(GameStatistics stats) {
		String dirpath = "stats/";
		new File(dirpath).mkdir();
		
		String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS"));
		String filepath = "stats/" + timestamp + ".xls";
		
		File file = new File(filepath);
		if(file.exists())
		{
			Writer output = null;
			try {
				output = new BufferedWriter(new FileWriter(filepath, true));
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String row_values = stats.winner +"\t"+ stats.rounds +"\t"+ stats.random_townsfolk +"\t"+ stats.strategic_townsfolk +"\t"+ stats.random_werewolves +"\t"+ stats.strategic_werewolves; 
			try {
				output.append(row_values);
				output.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		else
		{
			PrintWriter writer = null;
			try {
				writer = new PrintWriter(file);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String column_names= "Winner\tRounds\tRandom_townsfolk\tStrategic_townsfolk\tRandom_werewolves\tStrategic_werewolves";
			writer.println(column_names);
			String row_values = stats.winner +"\t"+ stats.rounds +"\t"+ stats.random_townsfolk +"\t"+ stats.strategic_townsfolk +"\t"+ stats.random_werewolves +"\t"+ stats.strategic_werewolves; 
			writer.println(row_values);
			writer.close();
		}
	}
	
	public String writeStats() {
		String dirpath = "stats/";
		new File(dirpath).mkdir();
		
		String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS"));
		String filepath = "stats/" + timestamp + ".xls";
		
		File file = new File(filepath);
		
		PrintWriter writer = null;
		try {
			writer = new PrintWriter(file);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String column_names= "Winner\tRounds\tRandom_townsfolk\tStrategic_townsfolk\tRandom_werewolves\tStrategic_werewolves";
		writer.println(column_names);
		for (GameStatistics stat : statistics) {
			String row_values = stat.winner +"\t"+ stat.rounds +"\t"+ stat.random_townsfolk +"\t"+ stat.strategic_townsfolk +"\t"+ stat.random_werewolves +"\t"+ stat.strategic_werewolves;
			writer.println(row_values);
		}
		writer.close();
		
		return file.getAbsolutePath();
	}
	
	public void newSession() {
		statistics.clear();
	}
}
