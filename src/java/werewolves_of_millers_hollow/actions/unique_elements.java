package werewolves_of_millers_hollow.actions;

import java.util.HashSet;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class unique_elements extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		ListTerm list = (ListTerm)args[0];
		HashSet<Term> set = new HashSet<>();
		for (Term element : list) {
			set.add(element);
		}
		ListTerm result = ASSyntax.createList(set);
		return un.unifies(result, args[1]);
	}

}
