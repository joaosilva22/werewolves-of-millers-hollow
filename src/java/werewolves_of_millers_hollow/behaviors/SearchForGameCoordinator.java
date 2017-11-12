package werewolves_of_millers_hollow.behaviors;

import jade.core.Agent;
import jade.core.behaviours.TickerBehaviour;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import werewolves_of_millers_hollow.agents.Player;
import werewolves_of_millers_hollow.util.IOUtils;

public class SearchForGameCoordinator extends TickerBehaviour {
	private DFAgentDescription template;
	
	public SearchForGameCoordinator(Agent agent, long period, DFAgentDescription template) {
		super(agent, period);
		this.template = template;
	}
	
	@Override
	protected void onTick() {
		// TODO Auto-generated method stub
		IOUtils.log(myAgent, "Looking for the Game Coordinator...");
		try {
			DFAgentDescription[] result = DFService.search(myAgent, template);
			// TODO: What if there is more than one coordinator?
			if (result.length > 0) {
				((Player)myAgent).setCoordinator(result[0].getName());
				IOUtils.log(myAgent, "Found the Game Coordinator.");
				stop();
			} else {
				IOUtils.log(myAgent, "Could not find the Game Coordinator.");
			}
		} catch (FIPAException e) {
			e.printStackTrace();
		}
	}
}
