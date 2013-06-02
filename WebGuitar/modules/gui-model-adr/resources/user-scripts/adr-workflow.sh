#!/bin/bash

#------------------------
# Sample command line arguments 
SCRIPT_DIR=`dirname $0`
aut_classpath=.

#aut_directory=TippyTipper
#aut_package=net.mandaria.tippytipper
#aut_main=activities.TippyTipper

aut_directory=$1
aut_package=$2
aut_main=$3
aut=$aut_package.$aut_main
port=10737

args=""

# configuration for the application
# you can specify widgets to ignore during ripping
# and terminal widgets
# configuration="$aut_dir/guitar-config/configuration.xml"

# intial waiting time
# change this if your application need more time to start
intial_wait=3000

# delay time between two events during ripping 
ripper_delay=500

# the length of test suite
tc_length=2

# delay time between two events during replaying  
# this number is generally smaller than the $ripper_delay
replayer_delay=1000

#------------------------
# Output artifacts 
#------------------------

# Directory to store all output of the workflow 
output_dir="./data/$aut_directory"

# GUI structure file
gui_file="$output_dir/$aut_directory.GUI"

# EFG file 
efg_file="$output_dir/$aut_directory.EFG"

# Log file for the ripper 
# You can examine this file to get the widget 
# signature to ignore during ripping 
log_file="$output_dir/$aut_directory.log"

# Test case directory  
testcases_dir="$output_dir/testcases"

# GUI states directory  
states_dir="$output_dir/states"

# Replaying log directory 
logs_dir="$output_dir/logs"

# Screenshot directory
screenshots_dir="$output_dir/screenshots"

#------------------------
# Main workflow 
#------------------------

# turn off posix mode
set +o posix

# Preparing output directories
mkdir -p $output_dir
mkdir -p $testcases_dir
mkdir -p $states_dir
mkdir -p $logs_dir
mkdir -p $screenshots_dir

old_dir=`pwd`

# Ripping
found=$(which android)
if [ $found ]; then
    echo -e "==> You already set up the Android SDK youself so we will not try to install.\n"
else
    if [ -f $HOME/android-sdk-linux/tools/android ]; then
        echo -e "==> Android SDK detected.\n"
    else
        echo -e "==> Download Android SDK"
        downloader=$(which wget)
        if [ $downloader ]; then
            wget http://dl.google.com/android/android-sdk_r15-linux.tgz
        else
            curl http://dl.google.com/android/android-sdk_r15-linux.tgz > android-sdk_r15-linux.tgz
        fi

        cp android-sdk_r15-linux.tgz $HOME
        rm android-sdk_r15-linux.tgz
        cd $HOME

        echo -e "==> Uncompress Android SDK"
        tar xvfz android-sdk_r15-linux.tgz
    fi
    tools_path="$HOME/android-sdk-linux/tools:$HOME/android-sdk-linux/platform-tools"
    original_PATH=${PATH}
    export PATH=${PATH}:${tools_path}
    android update sdk --no-ui -t tool
    android update sdk --no-ui -t platform-tool
    android update sdk --no-ui -t platform
fi

cd $old_dir

echo -e "==> Kill the emulator process if running.\n"
pkill emulator
killall emulator

echo "==> Delete the AVD if its name is ADRGuitarTestTest."
android delete avd -n ADRGuitarTest
echo -e "\n"

echo "==> Create an AVD. Its name will be ADRGuitarTestTest."
echo | android create avd -n ADRGuitarTest -t android-8 -s WQVGA432
echo -e "\n"

# ADR-Server Building
echo -e "==> Build ADR-Server"
cd adr-aut
rm -f adr-server.apk
cd adr-server

android update project --name adr-server --target android-8 --path .
python rename.py AndroidManifest.xml $aut_package
ant debug
../resign.sh ./bin/adr-server-debug.apk ../adr-server.apk
cd ../../

# AUT Building
echo -e "==> Build AUT"
cd adr-aut/$aut_directory

rm build.xml
android update project --target android-8 -p .
cp -rf src src.orig
if [ ! -f ./bin/no_fault/aut-resigned.apk ] || [ ! -f ./bin/no_fault/coverage.em ]; then
    ant instrument
    ../resign.sh ./bin/*-instrumented.apk ./bin/aut-resigned.apk
    mkdir -p ./bin/no_fault
    cp ./bin/aut-resigned.apk ./bin/no_fault
    cp coverage.em ./bin/no_fault
fi

rm -rf src
mv src.orig src
rm -rf bin/*.apk
cd ../../

# Run an emulator process
echo -e "==> Run the created emulator.\n"
emulator -avd ADRGuitarTest -cpu-delay 0 -netfast $4 -no-snapshot-save &

# Install ADR-Server
echo "==> Install ADR-Server."
cont=true
while $cont ;
do
    while read line
    do
        found=$(echo $line | grep Success)
        if [ "$found" ]; then
            cont=false
        fi
    done < <( adb install adr-aut/adr-server.apk )

    if $cont ; then
        echo "  The emulator is booting."
        echo "  We will retry."
        adb kill-server
        adb start-server
    fi
    sleep 10
done
echo -e "\n"

apk_file=`find adr-aut/$aut_directory -name *.apk | sed -n '/no_fault/p'`

# Install AUT
echo "==> Install AUT: $apk_file"
cont=true
while $cont ;
do
    while read line
    do
        found=$(echo $line | grep Success)
        if [ "$found" ]; then
            cont=false
        fi
    done < <( adb install $apk_file )

    if $cont ; then
        echo "    The emulator is booting."
        echo "    We will retry."
    fi
    sleep 10
done
echo -e "\n"

echo "About to rip the application "
cmd="$SCRIPT_DIR/adr-ripper.sh -cp $aut_classpath -c $aut -pt $port -g $gui_file -l $log_file -m"

# Adding application arguments if needed 
if [ ! -z $args ] 
then 
    cmd="$cmd -a \"$args\"" 
fi
echo $cmd
eval $cmd

rip_minute=`awk '/Elapsed:/ { print $7 }' $log_file | sed 's/^0*//'`
rip_second=`awk '/Elapsed:/ { print $9 }' $log_file | sed -n 's/:/ /p' | sed 's/^0*//'`

let rip_second=rip_minute*60+rip_second
let rip_second=rip_second*1000*3

# Converting GUI structure to EFG
echo ""
echo "About to convert GUI structure file to Event Flow Graph (EFG) file" 
#read -p "Press ENTER to continue..."
cmd="$SCRIPT_DIR/gui2efg.sh -g $gui_file -e $efg_file"
echo $cmd
eval $cmd

# Generating test cases
echo ""
echo "About to generate test cases to cover all possible $tc_length-way event interactions" 
#read -p "Press ENTER to continue..."
rm -rf $testcases_dir
cmd="$SCRIPT_DIR/tc-gen-sq.sh -e $efg_file -l $tc_length -m 0 -d $testcases_dir"
echo $cmd
eval $cmd 

testcase_num=`find $testcases_dir/*.tst | wc -l`

rm -rf `find adr-aut/$aut_directory -name '*.res'`
rm -rf `find adr-aut/$aut_directory -name '*.ec'`
rm -rf `find adr-aut/$aut_directory -name '*.log'`

# Replaying generated test cases
echo ""
echo "About to replay test case(s)" 
echo "Enter the number of test case(s): $testcase_num"

for testcase in `find $testcases_dir -name "*.tst"| head -n$testcase_num`
do
    # getting test name 
    test_name=`basename $testcase`
    test_name=${test_name%.*}

    rm -rf $logs_dir/$test_name.log

    cmd="$SCRIPT_DIR/adr-replayer.sh -cp $aut_classpath -c $aut -pt $port -g $gui_file -e $efg_file -t $testcase -i $intial_wait -d $replayer_delay -to $rip_second -so $rip_second -l $logs_dir/$test_name.log -gs $states_dir/$test_name.sta"

    # adding application arguments if needed 
    if [ ! -z $args ] 
    then 
        cmd="$cmd -a \"$args\" " 
    fi

    if [ -f adr-aut/$aut_directory/bin/no_fault/$test_name.res ]; then
        echo "This testcase was already run so we will skip"
    else
        echo $cmd 
        eval $cmd

        while [ ! -f adr-aut/$aut_directory/bin/no_fault/$test_name.ec ]
        do
            adb pull /data/data/$aut_package/files/coverage.ec adr-aut/$aut_directory/bin/no_fault/$test_name.ec
            sleep 2
        done

        emma_dir=`which android`
        emma_dir=${emma_dir%/*}
        emma_dir=${emma_dir}/lib/emma.jar
        java -cp $emma_dir emma report -r xml -in adr-aut/$aut_directory/bin/no_fault/coverage.em,adr-aut/$aut_directory/bin/no_fault/$test_name.ec
        java -cp $emma_dir emma report -r html -in adr-aut/$aut_directory/bin/no_fault/coverage.em,adr-aut/$aut_directory/bin/no_fault/$test_name.ec
        mv coverage $test_name
        rm -rf adr-aut/$aut_directory/bin/no_fault/$test_name
        mv -f $test_name -t adr-aut/$aut_directory/bin/no_fault/
        mv coverage.xml adr-aut/$aut_directory/bin/no_fault/$test_name/
        cp ${logs_dir}/${test_name}.log adr-aut/$aut_directory/bin/no_fault/
        cp $states_dir/$test_name.sta adr-aut/$aut_directory/bin/no_fault/
    fi
done

python cv_rpt.py adr-aut/$aut_directory/bin/no_fault
python ft_rpt.py adr-aut/$aut_directory/bin/result
cp -rf *.html adr-aut/$aut_directory

pkill emulator-arm
killall emulator-arm
android delete avd -n ADRGuitarTest
export PATH=${original_PATH}
