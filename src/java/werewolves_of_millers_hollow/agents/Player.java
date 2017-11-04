package werewolves_of_millers_hollow.agents;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.core.behaviours.TickerBehaviour;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import werewolves_of_millers_hollow.behaviors.SearchForGameCoordinator;
import werewolves_of_millers_hollow.util.IOUtils;

public class Player extends Agent {
	private AID coordinator;

	@Override
	protected void setup() {
		IOUtils.log(this, "Ready.");
		
		DFAgentDescription template = new DFAgentDescription();
		ServiceDescription sd = new ServiceDescription(); 
		// TODO: The service type should be in a contract class
		sd.setType("coordinator");
		template.addServices(sd);
		
		try {
			DFAgentDescription[] result = DFService.search(this, template);
			// TODO: What if there is more than one coordinator?
			if (result.length > 0) {
				coordinator = result[0].getName();
				IOUtils.log(this, "Found the Game Coordinator.");
			} else {
				IOUtils.log(this, "Could not find the Game Coordinator.");
			}
		} catch (FIPAException e) {
			e.printStackTrace();
		}
		if (coordinator == null) {
			addBehaviour(new SearchForGameCoordinator(this, 10000, template));
		}
		
		addBehaviour(new TestBehaviour());
	}

	@Override
	protected void takeDown() {
		IOUtils.log(this, "Terminating.");
	}
	
	// TODO: Eliminate this
	private class TestBehaviour extends CyclicBehaviour {
		private int step = 0;
		private MessageTemplate mt;
		
		@Override
		public void action() {
			switch (step) {
			case 0: {
				if (coordinator != null) {
					IOUtils.log(myAgent, "Requesting to join the game.");
					ACLMessage msg = new ACLMessage(ACLMessage.PROPOSE);
					msg.addReceiver(coordinator);
					myAgent.send(msg);
					mt = MessageTemplate.and(
							MessageTemplate.MatchPerformative(ACLMessage.ACCEPT_PROPOSAL), 
							MessageTemplate.MatchInReplyTo(msg.getReplyWith()));
					step = 1;
				}
			} break;
			case 1: {
				ACLMessage reply = myAgent.receive(mt);
				if (reply != null) {
					IOUtils.log(myAgent, "I have joined the game.");
				} else {
					block();
				}
			} break;
			}
		}
	}
	
	public void setCoordinator(AID coordinator) {
		this.coordinator = coordinator;
	}
}
