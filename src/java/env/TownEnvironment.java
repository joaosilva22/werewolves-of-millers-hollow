package env;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.Environment;

public class TownEnvironment extends Environment {
	private TownModel model;
	
	@Override
	public void init(String[] args) {
		model = new TownModel();
		model.setView(new TownView());
	}

	@Override
	public boolean executeAction(String agName, Structure act) {
		boolean result = false;
		switch (act.getFunctor()) {
		case "print_env":
			StringBuilder sb = new StringBuilder();
			for (Term term : act.getTerms()) {
				sb.append(term.toString().replace("\"", ""));
			}
			String message = sb.toString();
			result = model.addMessage(message);
			break;
		case "add_player":
			String name = act.getTerm(0).toString();
			result = model.addPlayer(name);
			break;
		case "remove_player":
			// TODO(jp): Remove the player
			break;
		}
		return result;
	}
}
