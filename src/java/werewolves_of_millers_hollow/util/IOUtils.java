package werewolves_of_millers_hollow.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import jade.core.Agent;

public class IOUtils {
	private static final String LOG_PATH = "./logs/";
	private static String logFileName = null;
	
	private IOUtils() {}
	
	public static String getLogFileName() {
        if (logFileName == null) {
            new File(LOG_PATH).mkdir();
            logFileName = LOG_PATH + getCurrentTimeStamp() + ".log";
            File logFile = new File(logFileName);
            try {
                logFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
        return logFileName;
	}
	
	private static String getCurrentTimeStamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS"));
	}
	
	public static void log(Agent agent, String message) {
        String timestampedMessage = "[" + getCurrentTimeStamp() +  "] " + agent.getName() + ": " + message;
        System.out.println(timestampedMessage);

        String log = IOUtils.getLogFileName();
        if (log != null) {
            try(PrintWriter out = new PrintWriter(new FileOutputStream(log, true))) {
                out.println(timestampedMessage);
            } catch (FileNotFoundException e) { }
        }
	}
}
