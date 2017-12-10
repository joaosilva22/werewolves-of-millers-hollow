package lib;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class max_utility extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		System.out.println("LIST=" + args[0]);
		ListTerm list = (ListTerm) args[0];
		Term result = list.get(0);
		float max = -1000.0f;
		for (Term term : list) {
			float val = Float.parseFloat(term.toString());
			
			if (val > max) {
				max = val;
				result = term;
			}
		}
		return un.unifies(result, args[1]);
	}

}
