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



#run test cases

for testfile in `find $testcase_dir -name '*Test.java'`
do
  filewithoutpath=$(basename $testfile)
  testcase=${filewithoutpath%.*}
  echo "Running testcase: $testcase"
  testclass=$testcase_package$testcase

  outputfile=$testcase".out"
  errorfile=$testcase".err"


  java $guitar_opts -cp $classpath org.junit.runner.JUnitCore $testclass > $outputfile 2> $errorfile
done
