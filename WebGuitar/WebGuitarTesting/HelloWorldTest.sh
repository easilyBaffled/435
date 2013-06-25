#check if should be run in isolated-mode

testname="HelloWorldTest"
website="https://googledrive.com/host/0B6TP-LuwGMgZbERwOXF5ZTNzWW8/helloworld.html"



testcase_dir="."

expected_dir=$testcase_dir"/expected"

# HelloWorldTest.sh <isolate>

isolate=$1


max_testcases=10


error_count=0



testcase_expected_dir=$expected_dir/$testname



if [ ! -d $expected_dir ]; then
  echo "[ERROR] - $testname: No expected directory!"
  exit 1
fi

if [ ! -d $testcase_expected_dir ]; then
  echo "[ERROR] - $testname: No expected directory for this test case!"
  exit 1
fi

testcase_current_dir=$testcase_dir/$testname


expected_file_path=$testcase_expected_dir/$testname
current_file_path=$testcase_current_dir/$testname



expected_gen_testcase_dir="$testcase_expected_dir/TC"
current_gen_testcase_dir="$testcase_current_dir/TC"

input_gen_testcase_dir=$current_gen_testcase_dir



input_file_path=$current_file_path

if [ $isolate -eq "true" ]; then
  echo "[INFO] - $testname: Isolated-mode active"
  input_file_path=$expected_file_path
  input_gen_testcase_dir=$expected_gen_testcase_dir
fi

output_file_path=$current_file_path







#setup java
dist_dir="../dist/guitar"

width=3
depth=3

ripper_args="--website-url $website -w $width -d $depth -g $output_file_path.GUI -b Firefox -p firefoxV6"


# run ripper
bash $dist_dir/sel-ripper.sh $ripper_args 



diff $current_file_path.GUI $expected_file_path.GUI &>/dev/null/
status=$?

if [ $status -ne 0]; then
  let error_count+=1
  echo "[ERROR] - $testname: Ripper output failed. Generated GUI did not match the expected GUI"
fi




# run gui 2 efg
gui_to_efg_args="-g $input_file_path.GUI -e $output_file_path.EFG"

bash $dist_dir/gui2efg.sh $gui_to_efg_args

diff $current_file_path.EFG $expected_file_path.EFG &>/dev/null/
status=$?

if [ $status -ne 0]; then
  let error_count+=1
  echo "[ERROR] - $testname: GUI-to-EFG output failed. Generated EFG did not match the expected EFG"
fi





# run testcase generator
tc_args="-e $output_file_path.EFG -m $max_testcases -d $current_gen_testcase_dir"

bash $dist_dir/tc-gen-sq.sh $tc_args

for testcase in `find $current_gen_testcase_dir -name "*.tst"| head -n$max_testcases`  
do
  # getting test name 
  test_name=`basename $testcase`
  test_name=${test_name%.*}

  diff $current_gen_testcase_dir/$testcase $expected_gen_testcase_dir/$testcase &>/dev/null/
  status=$?

  if [ $status -ne 0]; then
    let error_count+=1
    echo "[ERROR] - $testname: Generated test case output failed. Generated $testcase did not match the expected"
  fi

done





# run replayer


for testcase in `find $input_gen_testcase_dir -name "*.tst"| head -n$max_testcases`  
do
  # getting test name 
  test_name=`basename $testcase`
	test_name=${test_name%.*}

  replayer_args="--website-url $website -g $output_file_path.GUI -e $output_file_path.EFG -t $testcase -g $test_name.orc -d 1000"

	$dist_dir/sel-replayer.sh $replayer_args
	
	mv GUITAR-Default.STA $output_file_path.$test_name.STA

done


for statefile in `find $current_gen_testcase_dir -name "*.STA"| head -n$max_testcases`  
do
  # getting test name 
  statefile_name=`basename $statefile`

  diff $statefile $statefile_name &>/dev/null/
  status=$?
  
  if [ $status -ne 0]; then
    let error_count+=1
    echo "[ERROR] - $testname: Generated state output failed. Generated $statefile did not match the expected"
  fi
 

done

if [ $error_count -eq 0 ]; then
  echo "[INFO] - $testname: Test case passed!"
  exit 0
else
  echo "[INFO] - $testname: Test case failed!"
  exit 1
fi
