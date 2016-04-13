#!/bin/sh
#
# opensig bash test file
# 
# Tests the verify function
#
# Options: 
#
#   -w  run in-development (working) tests only
#   -s  run as a subtest.  Don't create own instance of test harness.
#

baseDir=..

working=0
subtest=0

while [ $1 ]; do
    case "$1" in
       -w) working=1;;
       -s) subtest=1;;
    esac
    shift;
done


if [[ $subtest -eq 0 ]] ; then source test_harness.sh; fi


#
# Test Cases
#

if [[ $working -eq 0 ]]
then

# verify no argument
runTest node $baseDir/src/index.js verify
assertError "calling verify with no argument results in an error" $'\n'"  error: missing required argument \`file'"

# verify unsigned
node $baseDir/src/index.js create > uniqueFile.txt
runTest node $baseDir/src/index.js verify uniqueFile.txt
assert "verifying an unsigned file results in no error" ""
rm -f uniqueFile.txt 2>/dev/null

# verify hello_world.txt
echo '{ "expectedURL":"https://blockchain.info/address/13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14?format=json", "testType":"response", "file":"test/test_files/blockchain.info/hello_world-tx_response-signed_by_me.json" }' > testURLResponse1
runTest node $baseDir/src/index.js verify test_files/hello_world.txt 
wait $! 2>/dev/null
assert "hello_world.txt has been signed" "Mon, 28 Mar 2016 13:31:08 GMT	121GfwxgvdEUck7Xb4d5wbMnf7Xm2b4zw3	"$'\n'"Sun, 27 Mar 2016 15:10:39 GMT	121GfwxgvdEUck7Xb4d5wbMnf7Xm2b4zw3	"
rm -f testURLResponse*

# verify hello_world.txt formatting
echo '{ "expectedURL":"https://blockchain.info/address/13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14?format=json", "testType":"response", "file":"test/test_files/blockchain.info/hello_world-tx_response-signed_by_me.json" }' > testURLResponse1
runTest node $baseDir/src/index.js verify test_files/hello_world.txt -f "Signed by <label> (<pub>) on <longtime> (<time>)"
wait $! 2>/dev/null
assert "signature can be user formatted" "Signed by  (121GfwxgvdEUck7Xb4d5wbMnf7Xm2b4zw3) on Mon, 28 Mar 2016 13:31:08 GMT (1459171868)"$'\n'"Signed by  (121GfwxgvdEUck7Xb4d5wbMnf7Xm2b4zw3) on Sun, 27 Mar 2016 15:10:39 GMT (1459091439)"
rm -f testURLResponse*

# api returns crap
echo '{ "expectedURL":"https://blockchain.info/address/13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14?format=json", "testType":"response", "data":"arfle barfle gloop" }' > testURLResponse1
runTest node $baseDir/src/index.js verify test_files/hello_world.txt --test-blockchain-api
wait $! 2>/dev/null
assertError "error is handled cleanly when blockchain web api returns nonsense" "blockchain.info response was invalid"
rm -f testURLResponse*

fi;

if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi

