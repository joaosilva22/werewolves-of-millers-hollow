package werewolves_of_millers_hollow.behaviors;

import java.util.ArrayList;

import jade.core.AID;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import werewolves_of_millers_hollow.util.IOUtils;

public class WaitForPlayers extends CyclicBehaviour {
	private static final int MIN_PLAYERS = 8;
	
	private ArrayList<AID> players;
	private enum State { NotEnoughPlayers, ReadyToStart }
	private State state;
	
	public WaitForPlayers() {
		players = new ArrayList<AID>();
		state = State.NotEnoughPlayers;
	}

	@Override
	public void action() {
		switch (state) {
		case NotEnoughPlayers: {
			MessageTemplate mt = MessageTemplate.MatchPerformative(ACLMessage.PROPOSE);
			ACLMessage msg = myAgent.receive(mt);
			if (msg != null) {
				ACLMessage reply = msg.createReply();
				if (!players.contains(msg.getSender())) {
					players.add(msg.getSender());
					IOUtils.log(myAgent, "A new player has joined the game (" + players.size() + " of " + MIN_PLAYERS + " required).");
					reply.setPerformative(ACLMessage.ACCEPT_PROPOSAL);
					if (players.size() >= MIN_PLAYERS) {
						IOUtils.log(myAgent, "Enough players have joined the game, waiting for any other players to join...");
						state = State.ReadyToStart;
					}
				} else {
					IOUtils.log(myAgent, "Player " + msg.getSender().getName() + " tried to join the game, but is already in.");
					reply.setPerformative(ACLMessage.REJECT_PROPOSAL);
				}
				myAgent.send(reply);
			} else {
				block();
			}
		} break;
		case ReadyToStart: {
			// TODO: Wait for other players for 30 seconds, then begin the game
			long end = System.currentTimeMillis() + 30000;
			while (System.currentTimeMillis() < end) {
				MessageTemplate mt = MessageTemplate.MatchPerformative(ACLMessage.PROPOSE);
				ACLMessage msg = myAgent.receive(mt);
				if (msg != null) {
					
				} else {
					block();
				}
			}
			IOUtils.log(myAgent, "Starting the game...");
		} break;
		}
	}
}
