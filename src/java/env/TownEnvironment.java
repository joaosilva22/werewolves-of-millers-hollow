package env;
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
		}
		return result;
	}
	
	public void run() {
		StringBuilder sb = new StringBuilder();
		sb.append("create_agents(");
		sb.append(model.getNumberOfTownsfolk());
		sb.append(",");
		sb.append(model.getNumberOfWerewolves());
		sb.append(")");
		String literal = sb.toString();
		addPercept(Literal.parseLiteral(literal));
	}
}
