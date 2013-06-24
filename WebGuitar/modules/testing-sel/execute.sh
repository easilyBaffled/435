

junitjar=../../lib/misc/junit.jar

guitar_lib=../../dist/guitar


for file in `find $guitar_lib -name '*.jar'` 
do
  classpath=$classpath:$file
done

classpath=$classpath:$junitjar




java -cp $classpath org.junit.runner.JUnitCore webguitar.test.HelloWorld
