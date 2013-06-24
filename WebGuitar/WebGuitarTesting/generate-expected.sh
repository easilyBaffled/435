
testcase_dir="."

expected_dir=$testcase_dir"/expected"

# generate-expected.sh <testname> <websiteUrl>

testname=$1
website=$2


testcase_expected_dir=$expected_dir"/"$testname

if [ ! -d $expected_dir ]; then
  mkdir $expected_dir
fi

if [ ! -d $testcase_expected_dir ]; then
  mkdir $testcase_expected_dir
fi


# run ripper


# run gui 2 efg


# run testcase generator


# run replayer


