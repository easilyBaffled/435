#Usage:
# HelloWorldTest.sh [isolate]
# NOTE: Isolate argument is optional and will default to true

# Prepare arguments for the testcase template script

testcase_template="./Testcase-Template.sh"


testname="HelloWorldTest"
website="https://googledrive.com/host/0B6TP-LuwGMgZbERwOXF5ZTNzWW8/helloworld.html"


isolate="true"
if [ ! -z "$1" ]; then
  isolate=$1
end


#execute testcase-template
bash $testcase_template $isolate $testname $website
