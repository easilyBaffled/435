#Usage:
# Testcase-Template.sh <isolate> <testname> <website> [max_testcases]
# NOTE: Max testcases is optional and will default to 10


#Description:
# Goes through each stage of WebGUITAR (Ripper, GUI-to-EFG, Testcase Generator, Replayer) and checks the output files
# against the expected files that have been stored in the $expected_dir directory (below).
#Isolated-Mode:
# If the $isolate parameter is set to true, each stage of WebGUITAR that uses some form of input file will use
# the appropriate input file from the EXPECTED directory, rather than the input file generated during the test's
# runtime. This will effectively isolate each stage of the testing so that even if one fails, the others can still
# be tested.


#check for proper number of arguments

if [ $# -lt 3 ]; then
 echo "[ERROR] - Testcase-Template: Improper amount of arguments!"
 exit 1
end


#check if should be run in isolated-mode

isolate=$1
testname=$2
website=$3

piped_output="$testname.out"



testcase_dir="."

expected_dir=$testcase_dir"/expected"






max_testcases=10

if [ ! -z "$4" ];  then
    max_testcases=$4
fi


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

piped_output=$testcase_current_dir/$piped_output

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


# BEGIN TESTING STAGES

dist_dir="../dist/guitar"

width=3
depth=3

ripper_args="--website-url $website -w $width -d $depth -g $output_file_path.GUI -b Firefox -p firefoxV6 !> $piped_output"


# run ripper
echo "[INFO] - $testname: Running ripper now.."
bash $dist_dir/sel-ripper.sh $ripper_args 


echo "[INFO] - $testname: Checking generated GUI file.."
diff $current_file_path.GUI $expected_file_path.GUI &>/dev/null/
status=$?

if [ $status -ne 0]; then
  let error_count+=1
  echo "[ERROR] - $testname: Ripper output failed. Generated GUI did not match the expected GUI"
else
  echo "[SUCCESS] - $testname: Ripper output verified! Generated GUI is consistent with expected GUI"
fi




# run gui 2 efg
echo "[INFO] - $testname: Running GUI-to-EFG Converter.."
gui_to_efg_args="-g $input_file_path.GUI -e $output_file_path.EFG !> $piped_output"

bash $dist_dir/gui2efg.sh $gui_to_efg_args

echo "[INFO] - $testname: Checking generated EFG file.."
diff $current_file_path.EFG $expected_file_path.EFG &>/dev/null/
status=$?

if [ $status -ne 0]; then
  let error_count+=1
  echo "[ERROR] - $testname: GUI-to-EFG output failed. Generated EFG did not match the expected EFG"
else
  echo "[SUCCESS] - $testname: GUI-to-EFG output verified! Generated EFG is consistent with expected EFG"
fi





# run testcase generator
tc_args="-e $output_file_path.EFG -m $max_testcases -d $current_gen_testcase_dir !> $piped_output"

echo "[INFO] - $testname: Running test-case generator.."
bash $dist_dir/tc-gen-sq.sh $tc_args

echo "[INFO] - $testname: Checking generated tst files.."

invalid_tc_count=0
for testcase in `find $current_gen_testcase_dir -name "*.tst"| head -n$max_testcases`  
do
  # getting test name 
  test_name=`basename $testcase`
  test_name=${test_name%.*}

  diff $current_gen_testcase_dir/$testcase $expected_gen_testcase_dir/$testcase &>/dev/null/
  status=$?

  if [ $status -ne 0]; then
    let error_count+=1
    let invalid_tc_count+=1
    echo "[ERROR] - $testname: Generated test case output failed. Generated $testcase did not match the expected"
  fi

done

if [ $invalid_tc_count -eq 0 ]; then
  echo "[SUCCESS] - $testname: All generated test-cases verified!"
else
  echo "[ERROR] - $testname: $invalid_tc_count test-cases failed to match expected."
fi





# run replayer

echo "[INFO] - $testname: Beginning replayer.."
for testcase in `find $input_gen_testcase_dir -name "*.tst"| head -n$max_testcases`  
do
  # getting test name 
  test_name=`basename $testcase`
  test_name=${test_name%.*}

  replayer_args="--website-url $website -g $output_file_path.GUI -e $output_file_path.EFG -t $testcase -g $test_name.orc -d 1000 !> $piped_output"

	$dist_dir/sel-replayer.sh $replayer_args

	mv GUITAR-Default.STA $output_file_path.$test_name.STA

done

echo "[INFO] - $testname: Checking STA files.."

invalid_sta_count=0
for statefile in `find $current_gen_testcase_dir -name "*.STA"| head -n$max_testcases`  
do
  # getting test name 
  statefile_name=`basename $statefile`

  diff $statefile $statefile_name &>/dev/null/
  status=$?
  
  if [ $status -ne 0]; then
    let error_count+=1
    let invalid_sta_count+=1
    echo "[ERROR] - $testname: Generated state output failed. Generated $statefile did not match the expected"
  fi
 

done


if [ $invalid_sta_count -eq 0 ]; then
  echo "[SUCCESS] - $testname: All STA files verified!"
else
  echo "[ERROR] - $testname: $invalid_sta_count STA files failed to matched expected"

fi




if [ $error_count -eq 0 ]; then
  echo "[INFO] - $testname: Test case passed!"
  exit 0
else
  echo "[INFO] - $testname: Test case failed!"
  exit 1
fi
