package env;


import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.util.ArrayList;
import java.util.Map;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

public class TownView extends JFrame {
	private JTextArea textArea;
	private JTextArea taPlayerList;
	private JPanel pnlBeliefCards;
	private JComboBox<String> cbBeliefCards;
	
	public TownView() {
		super("Werewolves of Miller's Hollow");
		setPreferredSize(new Dimension(800, 600));
		getContentPane().setLayout(new GridLayout(1, 2));
		
		JPanel pnlLeft = new JPanel();
		pnlLeft.setLayout(new GridLayout(2,1));
		getContentPane().add(pnlLeft);
		
		JPanel pnlPlayers = new JPanel();
		pnlPlayers.setLayout(new BorderLayout());
		pnlLeft.add(pnlPlayers);
		
		JLabel lblPlayerList = new JLabel("Players alive");
		pnlPlayers.add(lblPlayerList, BorderLayout.PAGE_START);
		
		taPlayerList = new JTextArea();
	    taPlayerList.setLineWrap(true);
	    pnlPlayers.add(new JScrollPane(taPlayerList), BorderLayout.CENTER);
	    
	    JPanel pnlBeliefs = new JPanel();
	    pnlBeliefs.setLayout(new BorderLayout());
	    pnlLeft.add(pnlBeliefs);
	    
	    JLabel lblBeliefs = new JLabel("Beliefs");
	    pnlBeliefs.add(lblBeliefs, BorderLayout.PAGE_START);
	    
	    pnlBeliefCards = new JPanel();
	    pnlBeliefCards.setLayout(new CardLayout());
	    
	    JPanel pnlCbBeliefCards = new JPanel();
	    String comboBoxItems[] = new String[0];
	    cbBeliefCards = new JComboBox<>(comboBoxItems);
	    cbBeliefCards.addItemListener(new ItemListener() {
			@Override
			public void itemStateChanged(ItemEvent arg0) {
				CardLayout cl = (CardLayout)(pnlBeliefCards.getLayout());
				cl.show(pnlBeliefCards, (String)arg0.getItem());
			}
	    });
	    pnlCbBeliefCards.add(cbBeliefCards);
	    
	    pnlBeliefs.add(pnlCbBeliefCards, BorderLayout.PAGE_END);
	    pnlBeliefs.add(pnlBeliefCards, BorderLayout.CENTER);
		
		JPanel right = new JPanel();
		right.setLayout(new BorderLayout());
		getContentPane().add(right);
				
		JLabel label = new JLabel("Story");
        right.add(label, BorderLayout.PAGE_START);
        
        textArea = new JTextArea();
        textArea.setLineWrap(true);
        JScrollPane scroll = new JScrollPane(textArea);
        right.add(scroll, BorderLayout.CENTER);
	}
	
	public void printMessage(String text) {
		textArea.append(text + "\n");
		repaint();
	}
	
	public void updateBeliefs(ArrayList<PlayerData> players) {
		cbBeliefCards.removeAllItems();
		pnlBeliefCards.removeAll();		
		
		for (PlayerData playerData : players) {
			boolean found = false;
			String name = playerData.getName();
			for (int i = 0; i < cbBeliefCards.getItemCount(); ++i) {
				if (cbBeliefCards.getItemAt(i).equals(name)) {
					found = true;
					break;
				}
			}
			if (!found) { 
				cbBeliefCards.addItem(name);
				
				JPanel pnlOuter = new JPanel(new GridLayout(2, 1));
				pnlBeliefCards.add(pnlOuter, name);
				
				JPanel pnlBelief = new JPanel(new GridLayout(1, 2));
				pnlOuter.add(pnlBelief, playerData.getName());
				
				JPanel pnlLeft = new JPanel(new BorderLayout());
				pnlBelief.add(pnlLeft);
				
				JLabel lblTownsfolk = new JLabel("Townsfolk");
				pnlLeft.add(lblTownsfolk, BorderLayout.PAGE_START);
				
				JTextArea taTownsfolk = new JTextArea();
				pnlLeft.add(taTownsfolk, BorderLayout.CENTER);
				
				for (Map.Entry<String, Float> beliefs : playerData.getBeliefsInTownsfolk().entrySet()) {
					taTownsfolk.append(beliefs.getKey() + ": " + beliefs.getValue() + "\n");
					
				}
				
				JPanel pnlRight = new JPanel(new BorderLayout());
				pnlBelief.add(pnlRight);
				
				JLabel lblWerewolves = new JLabel("Werewolves");
				pnlRight.add(lblWerewolves, BorderLayout.PAGE_START);
				
				JTextArea taWerewolves = new JTextArea();
				pnlRight.add(taWerewolves, BorderLayout.CENTER);
				
				for (Map.Entry<String, Float> beliefs : playerData.getBeliefsInWerewolves().entrySet()) {
					taWerewolves.append(beliefs.getKey() + ": " + beliefs.getValue() + "\n");
				}
				
				JPanel pnlDown = new JPanel(new BorderLayout());
				pnlOuter.add(pnlDown);
				
				JLabel lblThoughts = new JLabel("Thoughts");
				pnlDown.add(lblThoughts, BorderLayout.PAGE_START);
				
				JTextArea taThoughts = new JTextArea();
				taThoughts.setLineWrap(true);
				pnlDown.add(new JScrollPane(taThoughts), BorderLayout.CENTER);
				
				ArrayList<String> thoughts = playerData.getThoughts();
				for (String thought : thoughts) {
					taThoughts.append(thought + "\n");
				}
			}
		}
		repaint();
	}
	
	public void updatePlayers(ArrayList<PlayerData> players) {
		taPlayerList.setText("");
		for (PlayerData playerData : players) {
			if (playerData.isAlive()) {
				taPlayerList.append(playerData.getName() + "\n");
			}
		}
		repaint();
	}
}
