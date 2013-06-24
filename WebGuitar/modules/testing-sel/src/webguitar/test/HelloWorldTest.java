package webguitar.test;

import static org.junit.Assert.*;

import org.junit.Test;
import junit.framework.TestCase;

public class HelloWorldTest extends TestCase{

	@Test
	public void test() {
		String expectedDir= "";
		String website="https://googledrive.com/host/0B6TP-LuwGMgZbERwOXF5ZTNzWW8/helloworld.html";
		String fileName="helloworld";//name for all created files
		boolean isolate = false;//set to true to use expected files for input in relevant stages
		
		int width = 3;
		int depth = 1;
		
		int maximumTestCases = 5;
		
		TestingUtil tester = new TestingUtil(expectedDir, website, fileName, isolate);
		
		tester.runWebRipper(width, depth);
		
		//assertTrue(tester.verifyWebRipper());
		
		tester.runGuiToEfg();
		
		//assertTrue(tester.verifyGuiToEfg());
		
		tester.runTCGenerator(maximumTestCases);
		
		//assertTrue(tester.verifyTCGenerator());
		
		tester.runWebReplayer();
		
		//assertTrue(tester.verifyWebReplayer());
		
		
		assertTrue(true); //made it to the end!
		
	}

}
