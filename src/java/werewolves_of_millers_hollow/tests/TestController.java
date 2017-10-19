package werewolves_of_millers_hollow.tests;

import jade.core.Agent;
import jade.wrapper.AgentController;
import jade.wrapper.ContainerController;
import jade.wrapper.StaleProxyException;
import werewolves_of_millers_hollow.agents.GameCoordinator;
import werewolves_of_millers_hollow.agents.Player;
import werewolves_of_millers_hollow.util.IOUtils;

public class TestController extends Agent {
	
	@Override
	protected void setup() {
		IOUtils.log(getAID(), "Ready.");
		
		Object[] args = getArguments();
		if (args.length != 1) {
			IOUtils.log(getAID(), "Please provide the number of players.");
			doDelete();
		} else {
			int players = Integer.parseInt(args[0].toString());
			
			try {
				ContainerController cc = getContainerController();
				AgentController ac = cc.createNewAgent("Coordinator", GameCoordinator.class.getName(), null);
				ac.start();
			} catch (StaleProxyException e) {
				IOUtils.log(getAID(), e.getMessage());
				doDelete();
			}
			
			for (int i = 0; i < players; i++) {
				try {
					ContainerController cc = getContainerController();
					AgentController ac = cc.createNewAgent("P" + (i+1), Player.class.getName(), null);
					ac.start();
				} catch (StaleProxyException e) {
					IOUtils.log(getAID(), e.getMessage());
					doDelete();
				}
			}
			
			IOUtils.log(getAID(), "Job done.");
			doDelete();
		}
	}

	@Override
	protected void takeDown() {
		IOUtils.log(getAID(), "Terminating.");
	}
}
