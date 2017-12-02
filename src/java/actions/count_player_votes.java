package actions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class count_player_votes extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		ListTerm votes = (ListTerm)args[0];
		Map<Term, Integer> cntVotes = new HashMap<>();
		for (int i = 0; i < votes.size(); ++i) {
			Term vote = votes.get(i);
			Integer voteCnt = cntVotes.get(vote);
			if (voteCnt == null) {
				voteCnt = 0;
			}
			voteCnt++;
			cntVotes.put(vote, voteCnt);
		}		
		int max = 0;
		ArrayList<Term> mostVotedPlayers = new ArrayList<>();
		for (Map.Entry<Term, Integer> entry : cntVotes.entrySet()) {
			Term player = entry.getKey();
			int voteCnt = entry.getValue();
			if (voteCnt > max) {
				mostVotedPlayers.clear();
				mostVotedPlayers.add(player);
				max = voteCnt;
			}
			else if (voteCnt == max) {
				mostVotedPlayers.add(player);
			}
		}
		return un.unifies(ASSyntax.createList(mostVotedPlayers), args[1]) && 
				un.unifies(ASSyntax.createNumber(max), args[2]);
	}
	
}
