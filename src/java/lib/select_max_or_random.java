package lib;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class select_max_or_random extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		ListTerm list = (ListTerm) args[0];
		List<String> choices = new ArrayList<>();
		float max = -1.0f;
		for (Term term : list) {
			String split[] = term.toString().replace("[", "").replace("]", "").split(",");
			String name = split[0];
			float val = Float.parseFloat(split[1]);
			if (val > max) {
				choices.clear();
				choices.add(name);
				max = val;
			} else if (val == max) {
				choices.add(name);
			}
		}
		Random rand = new Random();
		String choice = choices.get(rand.nextInt(choices.size()));
		return un.unifies(ASSyntax.parseTerm(choice), args[1]);
	}
	
}
