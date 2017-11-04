package werewolves_of_millers_hollow.agents;

import jade.core.Agent;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import werewolves_of_millers_hollow.behaviors.WaitForPlayers;
import werewolves_of_millers_hollow.util.IOUtils;

public class GameCoordinator extends Agent {
	
	@Override
	protected void setup() {
		IOUtils.log(this, "Ready.");
		
		DFAgentDescription dfd = new DFAgentDescription();
		dfd.setName(getAID());
		ServiceDescription sd = new ServiceDescription();
		sd.setType("coordinator");
		sd.setName("mafia");
		dfd.addServices(sd);
		
		try {
			DFService.register(this, dfd);
		} catch (FIPAException e) {
			e.printStackTrace();
		}
		
		addBehaviour(new WaitForPlayers());
	}
	
	@Override
	protected void takeDown() {
		try {
			DFService.deregister(this);
		} catch (FIPAException e) {
			e.printStackTrace();
		}
		
		IOUtils.log(this, "Terminating.");
	}
}
