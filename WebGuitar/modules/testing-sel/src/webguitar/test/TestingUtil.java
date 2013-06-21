package webguitar.test;

import java.lang.reflect.Constructor;
import java.io.File;
import org.apache.commons.io.FilenameUtils;


public class TestingUtil {
	
	private boolean canVerify;
	private File expectedOutputDirectory;
	
	
	private String website;
	private String fileName;
	
	
	private boolean isolatePhases;
	
	
	private String curDirName = "./current";
	
	private String tcDirName = curDirName + "/TC";
	
	private String outputFile;
	private String inputFile;
		
	private String pluginName = "edu.umd.cs.guitar.ripper.WebPluginInfo";
	
	private String profile = "firefoxV6";
		
	
	public TestingUtil(String expectedDir, String website, String fileName, boolean isolate){
		
		File dir = new File(expectedDir);
		
		canVerify = dir.isDirectory();
		
		expectedOutputDirectory = dir;
		
		this.website = website;
		this.fileName = fileName;
		isolatePhases = isolate;
		
		
		File dirCur = new File(curDirName);
		
		if(!dirCur.isDirectory())
			dirCur.mkdir();
			
		File dirTC = new File(tcDirName);
		if(!dirTC.isDirectory())
			dirTC.mkdir();
			
		
		
		outputFile = curDirName + "/" + fileName;
		
		inputFile = isolatePhases ? FilenameUtils.removeExtension(getExpectedFile(fileName, "GUI").getAbsolutePath()) : fileName;
		
		
	}
	
	
	
	

	private boolean hasRunWebRipper = false;
	
	public void runWebRipper(int width, int depth){
		
		String widthStr = width < 1 ? "1" : Integer.toString(width);
		String depthStr = depth < 1 ? "1" : Integer.toString(depth);
		
		String[] args = {pluginName,"--website-url", website, "-w", widthStr, "-d", depthStr, "-g", outputFile+".GUI", "-l",outputFile +"_ph1.log" , "-b", "Firefox", "-p", profile};
		
		try {
		edu.umd.cs.guitar.ripper.Launcher.main(args);
		} catch (java.lang.Exception e){
			e.printStackTrace();
		}
		hasRunWebRipper = true;
		
	}
	
	
	public boolean verifyWebRipper(){
		
		if(!canVerify){
			System.err.println("ERROR: Cannot verify WebRipper. No expected output!");
			return false;
		}
			
		
		if(hasRunWebRipper){
			File expected = getExpectedFile(fileName, "GUI");
			File current = new File(curDirName + "/" + fileName+".GUI");

			//use https://code.google.com/p/java-diff-utils/ for diff API
			
			
			//inspect differences and ignore minor things such as different file names (if that comes up)
			
		}
		
		System.err.println("ERROR: WebRipper has not been run!");
		return false;
		
	}
	
	
	public void runGuiToEfg(){
		
		String[] args= {"-p", "EFGConverter", "-g", inputFile+".GUI", "-e", outputFile+".EFG", "-l", outputFile+"_p2.log"};
		
		edu.umd.cs.guitar.graph.GUIStructure2GraphConverter.main(args);
				
	}
	
	
	
	public void runTCGenerator(int maxTC){
		
		String maxTCstr = maxTC < 1 ? "3" : Integer.toString(maxTC); 
		
		String[] args = {"-p", "SequenceLengthCoverage", "-e",  inputFile + ".EFG", "-l", outputFile+"_p3.log", "-m", maxTCstr};
		
		edu.umd.cs.guitar.testcase.TestCaseGenerator.main(args);
		
	}
	
	
	public void runWebReplayer(){
		
		File tcDir = new File(tcDirName);
		
		
		if(tcDir.isDirectory()){
			
			for( File f : tcDir.listFiles()){
				
				String testcase = f.getName();
				String testcaseName = FilenameUtils.removeExtension(testcase);
				
				String[] args = {pluginName,"--website-url", website,"-t", testcase, "-g", testcaseName, "-d", "1000", "-g", inputFile+".GUI", "-e", inputFile+".EFG", "--dir", tcDirName, "-s", outputFile+".STA", "-l",outputFile +"_ph3.log" };
				//MADE A CHANGE IN NewGReplayerConfiguration to support parameter for the STA file
				try {
				edu.umd.cs.guitar.replayer.Launcher.main(args);
				} catch (java.lang.Exception e){
					e.printStackTrace();
				}
						
			}
			
			
		}
		
		
	}
	
	
	
	private File getExpectedFile(String fileName, String ext){
		
		return new File(expectedOutputDirectory + "/" + fileName + "." + ext);
		
	}
	
	
	

}
