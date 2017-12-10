package lib;

import java.util.Random;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Term;

public class random_name extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		String names[] = { "kellie", "gregory", "melynda", "joshua", "george", "jose", "david", "elida", "martha" };
		String surnames[] = { "gibson", "barber", "harding", "pinheiro", "camden", "gregory", "moran", "gustafson", "smith" };
		Random rand = new Random();
		String fullname = names[rand.nextInt(names.length)] + "_" + surnames[rand.nextInt(surnames.length)];
		return un.unifies(ASSyntax.createString(fullname), args[0]);
	}
}
