package werewolves_of_millers_hollow;

import jade.core.Agent;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;

public class GameCoordinator extends Agent {
	
	@Override
	protected void setup() {
		System.out.println("Hello! GameCoordinator " + getAID().getName() + " is ready.");
		
		// Register the service in the yellow pages
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
		// Deregister the service
		try {
			DFService.deregister(this);
		} catch (FIPAException e) {
			e.printStackTrace();
		}
		
		System.out.println("GameCoordinator " + getAID().getName() + " terminating.");
	}
}
