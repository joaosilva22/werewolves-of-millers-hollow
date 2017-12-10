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
import java.awt.event.KeyListener;
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
import javax.swing.JOptionPane;
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
					settingsWindow.setSize(new Dimension(350, 300));
					settingsWindow.setResizable(false);
			        settingsWindow.setTitle("Settings");
			        settingsWindow.setVisible(true);
			        
			        JPanel content = new JPanel();
			        content.setLayout(new GridLayout(10, 2));
			        settingsWindow.setContentPane(content);
			        
			        JLabel randomTownsfolk = new JLabel("Random townsfolk");
			        settingsWindow.getContentPane().add(randomTownsfolk);
			        final JSpinner randomTownsfolkCount = new JSpinner();
			        randomTownsfolkCount.setValue((int)model.getNumberOfRandomTownsfolk());
			        settingsWindow.getContentPane().add(randomTownsfolkCount);

			        JLabel townsfolk = new JLabel("Strategic townsfolk");
			        settingsWindow.getContentPane().add(townsfolk);
			        final JSpinner townsfolkCount = new JSpinner();
			        townsfolkCount.setValue((int)model.getNumberOfTownsfolk());
			        settingsWindow.getContentPane().add(townsfolkCount);
			        
			        JLabel negotiatiorTownsfolk = new JLabel("Negotiator townsfolk");
			        settingsWindow.getContentPane().add(negotiatiorTownsfolk);
			        final JSpinner negotiatiorTownsfolkCount = new JSpinner();
			        negotiatiorTownsfolkCount.setValue((int)model.getNumberOfNegotiatorTownsfolk());
			        settingsWindow.getContentPane().add(negotiatiorTownsfolkCount);
			        
			        JLabel randomWerewolves = new JLabel("Random werewolves");
			        settingsWindow.getContentPane().add(randomWerewolves);
			        final JSpinner randomWerewolvesCount = new JSpinner();
			        randomWerewolvesCount.setValue((int)model.getNumberOfRandomWerewolves());
			        settingsWindow.getContentPane().add(randomWerewolvesCount);
			        
			        JLabel werewolves = new JLabel("Strategic werewolves");
			        settingsWindow.getContentPane().add(werewolves);
			        final JSpinner werewolvesCount = new JSpinner();
			        werewolvesCount.setValue((int)model.getNumberOfWerewolves());
			        settingsWindow.getContentPane().add(werewolvesCount);
			        
			        JLabel negotiatorWerewolves = new JLabel("Negotiator werewolves");
			        settingsWindow.getContentPane().add(negotiatorWerewolves);
			        final JSpinner negotiatorWerewolvesCount = new JSpinner();
			        negotiatorWerewolvesCount.setValue((int)model.getNumberOfNegotiatorWerewolves());
			        settingsWindow.getContentPane().add(negotiatorWerewolvesCount);
			        
			        JLabel randomFortuneTellers = new JLabel("Random fortune tellers");
			        settingsWindow.getContentPane().add(randomFortuneTellers);
			        final JSpinner randomFortuneTellersCount = new JSpinner();
			        randomFortuneTellersCount.setValue((int)model.getNumberOfRandomFortuneTellers());
			        settingsWindow.getContentPane().add(randomFortuneTellersCount);

			        JLabel strategicFortuneTellers = new JLabel("Strategic fortune tellers");
			        settingsWindow.getContentPane().add(strategicFortuneTellers);
			        final JSpinner strategicFortuneTellersCount = new JSpinner();
			        strategicFortuneTellersCount.setValue((int)model.getNumberOfStrategicFortuneTellers());
			        settingsWindow.getContentPane().add(strategicFortuneTellersCount);
			        
			        JLabel numberOfGames = new JLabel("Number of games");
			        settingsWindow.getContentPane().add(numberOfGames);
			        final JSpinner numberOfGamesCount = new JSpinner();
			        numberOfGamesCount.setValue((int)model.getGamesToPlay());
			        settingsWindow.getContentPane().add(numberOfGamesCount);
			        
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
			        settingsWindow.getRootPane().setDefaultButton(save);
			        save.addActionListener(new ActionListener() {
						@Override
						public void actionPerformed(ActionEvent e) {
							if (e.getActionCommand().equals("Save")) {
								model.setNumberOfRandomTownsfolk((int)randomTownsfolkCount.getValue());
								model.setNumberOfTownsfolk((int)(townsfolkCount.getValue()));
								model.setNumberOfNegotiatorTownsfolk((int)negotiatiorTownsfolkCount.getValue());
								model.setNumberOfRandomWerewolves((int)randomWerewolvesCount.getValue());
								model.setNumberOfWerewolves((int)(werewolvesCount.getValue()));
								model.setNumberOfNegotiatorWerewolves((int)negotiatorWerewolvesCount.getValue());
								model.setNumberOfRandomFortuneTellers((int)randomFortuneTellersCount.getValue());
								model.setNumberOfStrategicFortuneTellers((int)strategicFortuneTellersCount.getValue());
								model.setGamesToPlay((int)numberOfGamesCount.getValue());
								settingsWindow.dispatchEvent(new WindowEvent(settingsWindow, WindowEvent.WINDOW_CLOSING));
							}
						}
			        });
			        settingsWindow.getContentPane().add(save);
				}
			}
		});
		menu.add(settings);
		
		JMenu stats = new JMenu("Stats");
		stats.setMnemonic(KeyEvent.VK_T);
		menuBar.add(stats);
		
		JMenuItem lastGame = new JMenuItem("Last Game", KeyEvent.VK_L);
		lastGame.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_L, KeyEvent.CTRL_DOWN_MASK));
		lastGame.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				final JFrame statsWindow = new JFrame();
				statsWindow.setSize(new Dimension(350, 150));
				statsWindow.setResizable(false);
		        statsWindow.setTitle("Stats");
		        statsWindow.setVisible(true);
		        
		        JPanel content = new JPanel();
		        content.setLayout(new GridLayout(6, 2));
		        statsWindow.setContentPane(content);
		        
		        GameStatistics stats = model.getLatestGameStatistics();
		        
		        if (stats == null) return;
		        
		        content.add(new JLabel("Winner"));
		        content.add(new JLabel(stats.winner.toString()));
		        
		        content.add(new JLabel("Number of Rounds"));
		        content.add(new JLabel(Integer.toString(stats.rounds)));
		        
		        content.add(new JLabel("Random townsfolk"));
		        content.add(new JLabel(Integer.toString(stats.random_townsfolk)));
		        
		        content.add(new JLabel("Strategic townsfolk"));
		        content.add(new JLabel(Integer.toString(stats.strategic_townsfolk)));
		        
		        content.add(new JLabel("Random werewolves"));
		        content.add(new JLabel(Integer.toString(stats.random_werewolves)));
		        
		        content.add(new JLabel("Strategic werewolves"));
		        content.add(new JLabel(Integer.toString(stats.strategic_werewolves)));
			}
		});
		stats.add(lastGame);
		
		JMenuItem export = new JMenuItem("Export Session", KeyEvent.VK_E);
		export.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_E, KeyEvent.CTRL_DOWN_MASK));
		export.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				if (arg0.getActionCommand().equals("Export Session")) {
					String path = model.writeStats();
					JOptionPane.showMessageDialog(null, "Statistics exported to " + path);
				}
			}
		});
		stats.add(export);
		
		JMenuItem newSession = new JMenuItem("New Session", KeyEvent.VK_N);
		newSession.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N, KeyEvent.CTRL_DOWN_MASK));
		newSession.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				model.newSession();
				JOptionPane.showMessageDialog(null, "Started new session");
			}
		});
		stats.add(newSession);
		
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
	
	public void clear() {
		textArea.setText("");
		taPlayerList.setText("");
		pnlBeliefCards.removeAll();
		cbBeliefCards.removeAllItems();
	}
}
