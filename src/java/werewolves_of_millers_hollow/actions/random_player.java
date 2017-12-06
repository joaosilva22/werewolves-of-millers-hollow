package werewolves_of_millers_hollow.actions;

import java.util.ArrayList;
import java.util.Random;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class random_player extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		ListTerm players = (ListTerm)args[0];
		Random rand = new Random();
		int index = rand.nextInt(players.size());
		Term player = players.get(index);
		return un.unifies(player, args[1]);
	}
	
}
