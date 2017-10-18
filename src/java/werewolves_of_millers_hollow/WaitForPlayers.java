package werewolves_of_millers_hollow;

import java.util.ArrayList;

import jade.core.AID;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;

public class WaitForPlayers extends CyclicBehaviour {
	private ArrayList<AID> players;
	
	public WaitForPlayers() {
		players = new ArrayList<AID>();
	}

	@Override
	public void action() {
		MessageTemplate mt = MessageTemplate.MatchPerformative(ACLMessage.PROPOSE);
		ACLMessage msg = myAgent.receive(mt);
		if (msg != null) {
			// TODO: Check if the player is in the game already
			players.add(msg.getSender());
			System.out.println("A new player has joined the game (" + players.size() + "/8).");
			ACLMessage reply = msg.createReply();
			reply.setPerformative(ACLMessage.ACCEPT_PROPOSAL);
			myAgent.send(reply);
		} else {
			block();
		}
	}
}
