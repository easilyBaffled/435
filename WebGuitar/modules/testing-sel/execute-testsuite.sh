testcase_dir="./src/webguitar/test/"
testcase_package="webguitar.test."

guitar_opts="-Dlog4j.configuration=log/guitar-clean.glc"


junitjar=../../lib/misc/junit.jar

guitar_lib=../../dist/guitar

utiljar="./src/jars/webguitar-test-util.jar"
testjar="./src/jars/webguitar-unit-tests.jar"


for file in `find $guitar_lib -name '*.jar'` 
do
  classpath=$classpath:$file
done

classpath=$classpath:$junitjar:$utiljar:$testjar



#run test suite




java $guitar_opts -cp $classpath webguitar.test.TestSuiteUtil $testcase_package $testcase_dir
