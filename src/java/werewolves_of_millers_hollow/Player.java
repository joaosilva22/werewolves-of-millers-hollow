package werewolves_of_millers_hollow;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import jade.lang.acl.ACLMessage;

public class Player extends Agent {
	private AID coordinator;

	@Override
	protected void setup() {
		System.out.println("Hello! Player " + getAID().getName() + " is ready.");
		
		// TODO: This should probably be a ticker behavior
		DFAgentDescription template = new DFAgentDescription();
		ServiceDescription sd = new ServiceDescription(); 
		// TODO: The service type should be in a contract class
		sd.setType("coordinator");
		template.addServices(sd);
		try {
			DFAgentDescription[] result = DFService.search(this, template);
			// TODO: What if there is more than one coordinator?
			coordinator = result[0].getName();
		} catch (FIPAException e) {
			e.printStackTrace();
		}
		
		addBehaviour(new TestBehaviour());
	}

	@Override
	protected void takeDown() {
		System.out.println("Player " + getAID().getName() + " terminating.");
	}
	
	// TODO: Eliminate this
	private class TestBehaviour extends CyclicBehaviour {

		@Override
		public void action() {
			ACLMessage msg = new ACLMessage(ACLMessage.PROPOSE);
			msg.addReceiver(coordinator);
			myAgent.send(msg);
		}
	}
}
