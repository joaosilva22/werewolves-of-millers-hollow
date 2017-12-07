package env;


import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowEvent;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTextArea;
import javax.swing.KeyStroke;
import javax.swing.border.EmptyBorder;

public class TownView extends JFrame {
	private JTextArea textArea;
	private JTextArea taPlayerList;
	private JPanel pnlBeliefCards;
	private JComboBox<String> cbBeliefCards;
	private final TownModel model;
	
	public TownView(TownModel m) {
		super("Werewolves of Miller's Hollow");
		setPreferredSize(new Dimension(800, 600));
		getContentPane().setLayout(new GridLayout(1, 2));
		
		/* Get the town model */
		model = m;
		
		/* Menu bar */
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);
		
		JMenu menu = new JMenu("Game");
		menu.setMnemonic(KeyEvent.VK_G);
		menuBar.add(menu);
		
		JMenuItem run = new JMenuItem("Run", KeyEvent.VK_R);
		run.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_R, KeyEvent.CTRL_DOWN_MASK));
		run.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				if (e.getActionCommand().equals("Run")) {
					model.run();
				}
			}
		});
		menu.add(run);
		
		JMenuItem settings = new JMenuItem("Settings", KeyEvent.VK_S);
		settings.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_S, KeyEvent.CTRL_DOWN_MASK));
		settings.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				if (arg0.getActionCommand().equals("Settings")) {
					final JFrame settingsWindow = new JFrame();
					settingsWindow.setSize(new Dimension(350, 150));
					settingsWindow.setResizable(false);
			        settingsWindow.setTitle("Settings");
			        settingsWindow.setVisible(true);
			        
			        JPanel content = new JPanel();
			        content.setLayout(new GridLayout(3, 2));
			        settingsWindow.setContentPane(content);			       

			        JLabel townsfolk = new JLabel("Number of townsfolk");
			        settingsWindow.getContentPane().add(townsfolk);
			        final JSpinner townsfolkCount = new JSpinner();
			        settingsWindow.getContentPane().add(townsfolkCount);
			        
			        JLabel werewolves = new JLabel("Number of werewolves");
			        settingsWindow.getContentPane().add(werewolves);
			        final JSpinner werewolvesCount = new JSpinner();
			        settingsWindow.getContentPane().add(werewolvesCount);
			        
			        JButton cancel = new JButton("Cancel");
			        cancel.addActionListener(new ActionListener() {
						@Override
						public void actionPerformed(ActionEvent arg0) {
							if (arg0.getActionCommand().equals("Cancel")) {
								settingsWindow.dispatchEvent(new WindowEvent(settingsWindow, WindowEvent.WINDOW_CLOSING));
							}
						}
			        });
			        settingsWindow.getContentPane().add(cancel);
			        
			        JButton save = new JButton("Save");
			        save.addActionListener(new ActionListener() {
						@Override
						public void actionPerformed(ActionEvent e) {
							if (e.getActionCommand().equals("Save")) {
								model.setNumberOfTownsfolk((int)(townsfolkCount.getValue()));
								model.setNumberOfWerewolves((int)(werewolvesCount.getValue()));
								settingsWindow.dispatchEvent(new WindowEvent(settingsWindow, WindowEvent.WINDOW_CLOSING));
							}
						}
			        });
			        settingsWindow.getContentPane().add(save);
				}
			}
		});
		menu.add(settings);
		
		/* Left panel */
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
		
	    /* Right panel */
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
	
	public void updateBeliefs(List<PlayerData> players) {
		pnlBeliefCards.removeAll();		
		
		synchronized(players) {
			for (PlayerData playerData : players) {
				boolean found = false;
				String name = playerData.getName();
				for (int i = 0; i < cbBeliefCards.getItemCount(); ++i) {
					if (cbBeliefCards.getItemAt(i).equals(name)) {
						found = true;
						break;
					}
				}
				if (!found) cbBeliefCards.addItem(name);
					
				JPanel pnlOuter = new JPanel(new GridLayout(2, 1));
				pnlBeliefCards.add(pnlOuter, name);
				
				JPanel pnlBelief = new JPanel(new GridLayout(1, 2));
				pnlOuter.add(pnlBelief, playerData.getName());
				
				JPanel pnlLeft = new JPanel(new BorderLayout());
				pnlBelief.add(new JScrollPane(pnlLeft));
				
				JLabel lblTownsfolk = new JLabel("Townsfolk");
				pnlLeft.add(lblTownsfolk, BorderLayout.PAGE_START);
				
				JTextArea taTownsfolk = new JTextArea();
				pnlLeft.add(taTownsfolk, BorderLayout.CENTER);
				
				for (Map.Entry<String, Float> beliefs : playerData.getBeliefsInTownsfolk().entrySet()) {
					taTownsfolk.append(beliefs.getKey() + ": " + beliefs.getValue() + "\n");
				}
				
				JPanel pnlRight = new JPanel(new BorderLayout());
				pnlBelief.add(new JScrollPane(pnlRight));
				
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
	
	public void updatePlayers(List<PlayerData> players) {
		taPlayerList.setText("");
		for (PlayerData playerData : players) {
			String name = playerData.getName();
			String role = playerData.getRole();
			if (playerData.isAlive()) {
				taPlayerList.append(name);
				if (!role.equals("townsperson")) {
					taPlayerList.append(" (" + role + ")\n");
				} else {
					taPlayerList.append("\n");
				}
			}
		}
		repaint();
	}
}
