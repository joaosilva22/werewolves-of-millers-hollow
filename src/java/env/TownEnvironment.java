package env;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.List;

import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.Environment;

public class TownEnvironment extends Environment {
	private TownModel model;
	
	@Override
	public void init(String[] args) {
		model = new TownModel(this);
		model.setView(new TownView(model));
	}

	@Override
	public boolean executeAction(String agName, Structure act) {
		boolean result = false;
		switch (act.getFunctor()) {
		case "print_env": {
			StringBuilder sb = new StringBuilder();
			for (Term term : act.getTerms()) {
				sb.append(term.toString().replace("\"", ""));
			}
			String message = sb.toString();
			result = model.addMessage(message);
		} break;
		case "add_player": {
			String name = act.getTerm(0).toString();
			String role = act.getTerm(1).toString();
			result = model.addPlayer(name, role);
		} break;
		case "remove_player": {
			String name = act.getTerm(0).toString();
			result = model.removePlayer(name);
		} break;
		case "update_beliefs_in_werewolves": {
			String name = act.getTerm(0).toString();
			String werewolf = act.getTerm(1).toString();
			float certainty = Float.parseFloat(act.getTerm(2).toString());
			model.getPlayerData(name).addBeliefInWerewolf(werewolf, certainty);
			result = model.updateBeliefs();
		} break;
		case "update_beliefs_in_townsfolk": {
			String name = act.getTerm(0).toString();
			String townsperson = act.getTerm(1).toString();
			float certainty = Float.parseFloat(act.getTerm(2).toString());
			model.getPlayerData(name).addBeliefInTownsperson(townsperson, certainty);
			result = model.updateBeliefs();
		} break;
		case "add_player_thought": {
			String name = act.getTerm(0).toString();
			StringBuilder sb = new StringBuilder();
			int termCnt = 0;
			for (Term term : act.getTerms()) {
				if (termCnt > 0) {
					sb.append(term.toString());
				}
				termCnt++;
			}
			String thought = sb.toString().replace("\"", "");
			result = model.addPlayerThought(name, thought);
		} break;
		case "end_game": {
			String winner = act.getTerm(0).toString();
			int rounds = Integer.parseInt(act.getTerm(1).toString());
			GameStatistics stats = model.getLatestGameStatistics();
			stats.rounds = rounds;
			if (winner.equals("\"werewolves\"")) {
				stats.winner = GameStatistics.Team.Werewolves;
			} else {
				stats.winner = GameStatistics.Team.Townsfolk;
			}
			result = true;
		} break;
		}
		return result;
	}
	
	public void run() {
		clearPercepts();
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		StringBuilder sb = new StringBuilder();
		sb.append("create_agents(");
		sb.append(model.getNumberOfRandomTownsfolk());
		sb.append(",");
		sb.append(model.getNumberOfTownsfolk());
		sb.append(",");
		sb.append(model.getNumberOfRandomWerewolves());
		sb.append(",");
		sb.append(model.getNumberOfWerewolves());
		sb.append(")");
		String literal = sb.toString();
		System.out.println("Restarting...");
		model.clear();
		model.createGameStatistics();
		GameStatistics stats = model.getLatestGameStatistics();
		stats.random_townsfolk = model.getNumberOfRandomTownsfolk();
		stats.strategic_townsfolk = model.getNumberOfTownsfolk();
		stats.random_werewolves = model.getNumberOfRandomWerewolves();
		stats.strategic_werewolves = model.getNumberOfWerewolves();
		addPercept(Literal.parseLiteral(literal));
	}
}
