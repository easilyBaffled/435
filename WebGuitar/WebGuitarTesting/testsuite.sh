testcase_dir="."

total_count=0
error_count=0
succ_count=0

for testfile in `find $testcase_dir -name '*Test.sh'`
do
  total_count=`expr $total_count + 1`
  
  bash $testfile
  status=$?
  
  if [ $status -eq 0 ];then
    echo "$testfile passed!"
    succ_count=`expr $succ_count + 1`
  else
    echo "$testfile failed!"
    error_count=`expr $error_count + 1`
  fi
  
done
