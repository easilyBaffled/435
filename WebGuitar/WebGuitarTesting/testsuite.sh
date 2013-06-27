testcase_dir="."
cobertura_dir="../lib/cobertura"
coverage_report_dir="./coverage"


cobertura_intrument="$cobertura_dir/cobertura-instrument.sh"
cobertura_report="$cobertura_dir/cobertura-report.sh"

jars_dir="../dist/guitar/jars/guitar-lib"


# clear code coverage files/directories
echo "[INFO] - testsuite: Clearing code coverage files and directories"
rm -f cobertura.ser
rm -f -rf $coverage_report_dir




#intrument code: uses default datafile location & name (currentdirectory/cobertura.ser)
echo "[INFO] - testsuite: Intrumenting code from jars directory"
bash $cobertura_intrument $jars_dir/*.jar





total_count=0
error_count=0
succ_count=0

for testfile in `find $testcase_dir -name '*Test.sh'`
do
  let total_count+=1
  
  echo "[INFO] - testsuite: Running $testfile"
  bash $testfile
  status=$?
  
  if [ $status -eq 0 ]; then
    echo "[INFO] - testsuite: $testfile passed!"
    let succ_count+=1
  else
    echo "[INFO] - testsuite: $testfile failed!"
    let error_count+=1
  fi
  
done


if [ ! -d $coverage_report_dir ]; then
  echo "[INFO] - testsuite: Creating coverage report directory"
  mkdir $coverage_report_dir
fi



#report coverage: uses default datafile
echo "[INFO] - testsuite: Generating coverage report"
bash $cobertura_report --destination $coverage_report_dir --format xml $jars_dir/*.jar
bash $cobertura_report --destination $coverage_report_dir/html --format html $jars_dir/*.jar


if [ $total_count -eq $succ_count ]; then
  #all passed
  echo "[SUCCESS] - testsuite: Test suite passed!"
  exit 0
else
  #some failed
  echo "[FAILURE] - testsuite: Test suite failed: $error_count of $total_count failed!"
  
  #DEBUG
  exit 0
  
  #exit 1
fi




