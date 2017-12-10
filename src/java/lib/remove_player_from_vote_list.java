package lib;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class remove_player_from_vote_list extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		String player = args[0].toString();
		ListTerm votes = (ListTerm)args[1];
		for (Term vote : votes) {
			String parts[] = vote.toString().replace("[", "").replaceAll("]", "").split(",");
			String accuser = parts[0];
			String accused = parts[1];
			if (accuser.equals(player) || accused.equals(player)) {
				votes.remove(vote);
			}
		}
		return un.unifies(votes, args[2]);
	}
	
}
