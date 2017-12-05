package env;


import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

public class TownView extends JFrame {
	private JTextArea textArea;
	private JTextArea playerList;
	
	public TownView() {
		super("Werewolves of Miller's Hollow");
		setPreferredSize(new Dimension(800, 600));
		getContentPane().setLayout(new GridLayout(1, 2));
		
		JPanel left = new JPanel();
		left.setLayout(new BorderLayout());
		getContentPane().add(left);
		
		JLabel playerListLabel = new JLabel("Players living");
		left.add(playerListLabel, BorderLayout.PAGE_START);
		
		playerList = new JTextArea();
	    playerList.setLineWrap(true);
	    left.add(new JScrollPane(playerList), BorderLayout.CENTER);
		
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
	
	public void updatePlayers(ArrayList<PlayerData> players) {
		playerList.setText("");
		for (PlayerData playerData : players) {
			playerList.append(playerData.getName() + "\n");
		}
	}
}
