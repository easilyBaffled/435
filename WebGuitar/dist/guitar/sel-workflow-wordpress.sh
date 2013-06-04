#!/bin/bash

# change these following configuration to your test system

#
# web site under test 
#
website="http://128.8.126.15/wordpress/"

#
# test case directory 
#
testcases_dir=GUITAR-Wordpress/TC
testcase_name=GUITAR-Wordpress
rm -rf $testcase_name.EFG $testcase_name.STA $testcase_name.GUI
rm -fdr $testcase_name
rm -fdr $testcases_dir

mkdir $testcase_name
chmod 777 $testcase_name

mkdir $testcases_dir
chmod 777 $testcases_dir

#
# number of test cases to run
#
testcase_num=2

# Use clean log
export GUITAR_OPTS="-Dlog4j.configuration=log/guitar-clean.glc"
SCRIPT_DIR=`dirname $0`
pushd $SCRIPT_DIR

# rip
echo "About to rip" 
read -p "Press ENTER to continue..."
./sel-ripper.sh --website-url $website -w 3 -d 3 -g $testcase_name.GUI

# convert GUI to EFG
echo "About to convert GUI to EFG " 
read -p "Press ENTER to continue..."
./gui2efg.sh -g $testcase_name.GUI -e $testcase_name.EFG

# generate test case 
echo "About to generate test cases" 
read -p "Press ENTER to continue..."
 ./tc-gen-sq.sh -e $testcase_name.EFG -d $testcases_dir

# replay
echo "About to replay" 
read -p "Press ENTER to continue..."

SAMPLE_TEST=`find TC -name "*.tst" | tail -n1`

for testcase in `find $testcases_dir -name "*.tst"| head -n$testcase_num`  
do
	# getting test name 
	test_name=`basename $testcase`
	test_name=${test_name%.*}
	
	./sel-replayer.sh --website-url $website -g $testcase_name.GUI -e $testcase_name.EFG -t $testcase -g $test_name.orc -d 1000 
done

popd # quit to the current directory

