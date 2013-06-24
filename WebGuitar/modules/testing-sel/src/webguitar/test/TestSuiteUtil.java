package webguitar.test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import junit.framework.TestCase;
import junit.framework.TestResult;
import junit.framework.TestSuite;
import junit.textui.TestRunner;

import org.junit.runner.Description;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.RunListener;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

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
	 * Iterate through files in test directory and find ones that match the test
	 * case name regex (which is .java files ending with "Test", by default) and
	 * run these tests via JUnit.
	 * 
	 * 
	 * @param core
	 * @param testPackage
	 * @param testDir
	 */
	public void runTests(String testPackage, String testDir) {
		File[] tests = new File(testDir).listFiles();

		File outputDir = new File(".");
		PrintStream err = System.err;
		PrintStream out = System.out;
		
		redirect(outputDir);

		for (File f : tests) {

			if (!f.isDirectory()) {
				String name = f.getName();

				if (name.matches(testRegex)) {
					String testcase = name.replaceFirst(testRegex, "$1");

					testPackage += testPackage.endsWith(".") ? "" : ".";

					String testClassName = testPackage + testcase;
					try {

						TestSuite suite = new TestSuite("Test for Engine. "
								+ testClassName + ".java");

						Class<? extends TestCase> testClass = (Class<? extends TestCase>) Class
								.forName(testClassName);

						suite.addTestSuite(testClass);

						// run test
						TestResult r = TestRunner.run(suite);

						// core.run(testClass);

					} catch (Exception e) {

					}

				}

			}

		}
		
		revert(err,out);

	}


	public static void redirect(File directory) {
		try {
			File stdErr = new File(directory.getAbsolutePath() + "output.err");
			System.setErr(new PrintStream(new FileOutputStream(stdErr)));

			File stdOut = new File(directory.getAbsolutePath() + "output.out");
			System.setOut(new PrintStream(new FileOutputStream(stdOut)));
		} catch (Throwable t) {
			System.err.println("Error overriding standard output to file.");
			t.printStackTrace(System.err);
		}
	}
	
	public static void revert(PrintStream err, PrintStream out){
		System.setErr(err);
		System.setOut(out);
		
	}

}
