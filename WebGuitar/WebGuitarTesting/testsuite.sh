
testcase_dir="."
cobertura_dir="../lib/cobertura"
coverage_report_dir="./coverage"


cobertura_jar="$cobertura_dir/cobertura.jar"

cobertura_intrument="$cobertura_dir/cobertura-instrument.sh"
cobertura_report="$cobertura_dir/cobertura-report.sh"

jars_dir="../dist/guitar/jars/guitar-lib"

#intrument code: uses default datafile location & name (currentdirectory/cobertura.ser)
echo "[INFO] - testsuite: Intrumenting code from jars directory"
bash $cobertura_intrument --basedir $jars_dir





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
bash $cobertura_report --basedir $jars_dir --destination $coverage_report_dir --format xml


if [ $total_count -eq $succ_count ]; then
  #all passed
  echo "[SUCCESS] - testsuite: Test suite passed!"
  exit 0
else
  #some failed
  echo "[FAILURE] - testsuite: Test suite failed: $error_count of $total_count failed!"
  exit 1
fi




