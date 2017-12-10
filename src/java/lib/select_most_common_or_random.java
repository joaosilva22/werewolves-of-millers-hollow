package lib;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;

public class select_most_common_or_random extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		ListTerm list = (ListTerm) args[0];
		Map<String, Integer> map = new HashMap<>();
		for (Term term : list) {
			String termStr = term.toString();
			Integer count = map.get(termStr);
			if (count == null) {
				count = 0;
			}
			map.put(termStr, count + 1);
		}
		List<String> mostCommonOptions = new ArrayList<>();
		int max = Integer.MIN_VALUE;
		for (Map.Entry<String, Integer> entry : map.entrySet()) {
			String term = entry.getKey();
			int frequency = entry.getValue();
			if (frequency > max) {
				mostCommonOptions.clear();
				mostCommonOptions.add(term);
				max = frequency;
			} else if (frequency == max) {
				mostCommonOptions.add(term);
			}
		}
		Random rand = new Random();
		String mostCommon = mostCommonOptions.get(rand.nextInt(mostCommonOptions.size()));
		return un.unifies(ASSyntax.parseTerm(mostCommon), args[1]);
	}

}
