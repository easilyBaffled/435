package webguitar.test;

import java.io.File;
import junit.framework.TestCase;
import junit.framework.TestResult;
import junit.framework.TestSuite;
import junit.textui.TestRunner;

import org.junit.runner.Description;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.RunListener;

public class TestSuiteUtil {

  private String testRegex = "(\\w+Test)\\.java";
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		String testPackage = args[0];
		String testDir = args[1];

		TestSuiteUtil suite = new TestSuiteUtil();
		
		    suite.runTests(testPackage, testDir);
		    

	}
	

	
	/**
	 * Iterate through files in test directory and find ones that match the test case
	 * name regex (which is .java files ending with "Test", by default) and run these
	 * tests via JUnit.
	 * 
	 * 
	 * @param core
	 * @param testPackage
	 * @param testDir
	 */
	public void runTests(String testPackage, String testDir){
		File[] tests = new File(testDir).listFiles();
		
		
		
		for(File f: tests){
			
			if(!f.isDirectory()){
				String name = f.getName();
				
				if(name.matches(testRegex)){
					String testcase = name.replaceFirst(testRegex, "$1");
					
					testPackage += testPackage.endsWith(".") ? "" : ".";
					
					String testClassName = testPackage + testcase;
					try{
						
						TestSuite suite = new TestSuite("Test for Engine. "+testClassName+".java");
		
						Class<? extends TestCase> testClass = (Class<? extends TestCase>) Class.forName(testClassName);
						
						suite.addTestSuite(testClass);
						
						//run test
						TestResult r = TestRunner.run(suite);

						
					} catch(Exception e){
						System.err.println("Exception thrown in test suite.");
					}
					
				}
				
				
			}
			
		}
		
		
	}
	
	public void addResult(TestResult tr, String testcase){
		
		if(tr.wasSuccessful()){
			System.out.println(testcase + " was successful!");
			
		} else {
			
			System.out.println(testcase + " failed!");
			
		}
		
		
	}
	
		
	

}
