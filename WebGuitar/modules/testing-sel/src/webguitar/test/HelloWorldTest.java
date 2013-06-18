import static org.junit.Assert.*;

import org.junit.Test;


public class HelloWorldTest {

	@Test
	public void test() {
		String expectedDir= "";
		String website="";
		String fileName="helloworld";
		boolean isolate = true;
		
		int width = 3;
		int depth = 1;
		
		int maximumTestCases = 5;
		
		TestingUtil tester = new TestingUtil(expectedDir, website, fileName, isolate);
		
		tester.runWebRipper(width, depth);
		
		assertTrue(tester.verifyWebRipper());
		
		tester.runGuiToEfg();
		
		//assertTrue(tester.verifyGuiToEfg());
		
		tester.runTCGenerator(maximumTestCases);
		
		//assertTrue(tester.verifyTCGenerator());
		
		tester.runWebReplayer();
		
		//assertTrue(tester.verifyWebReplayer());
		
	}

}
