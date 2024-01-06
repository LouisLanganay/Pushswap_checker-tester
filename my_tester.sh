#!/bin/bash

BINARY_NAME=pushswap_checker
TOTAL_TESTS=0
SUCCESS_TESTS=0

compare() {
    expected_prefix=$1
    eval_output=$2
    expected_return=$3
    eval_return=$4
    command=$5

    if [[ "${eval_output:0:2}" == "$expected_prefix" ]] && [[ "$expected_return" == "$eval_return" ]]; then
        printf "%d -\t\033[1;32m[SUCCESS]\033[0m ┌ \033[1m(%s)\033[0m\n" $TOTAL_TESTS "$command"
        printf "\t\t  ├ \033[1;042;30mExpected: \"%s\" - %s\033[0m\n" "$1" "$expected_return"
        printf "\t\t  └ \033[1;042;30mGot: \"%s\" - %d\033[0m\n" "$2" "$eval_return"
        SUCCESS_TESTS=$((SUCCESS_TESTS+1))
    else
        printf "%d -\t\033[1;31m[FAIL]\033[0m\t  ┌ \033[1m(%s)\033[0m\n" $TOTAL_TESTS "$command"
        printf "\t\t  ├ \033[1;042;30mExpected: \"%s\" - %s\033[0m\n" "$1" "$expected_return"
        printf "\t\t  └ \033[1;041;30mGot: \"%s\" - %d\033[0m\n" "$2" "$eval_return"
    fi
}

check_binary_existence() {
    if [ ! -x "$BINARY_NAME" ]; then
        printf "\033[1;31m[ERROR]\033[0m %s binary not found\n" "$BINARY_NAME"
        printf "\033[1;33mPlease compile your project before running this script with make\033[0m\n\n"
        printf "\033[1;36m----- PUSHSWAP_CHECKER FUNCTIONAL TESTS -----\033[0m\n\n"
        exit 1
    fi
}

run_test() {
    expected_output=$2
    expected_return=$3
    eval_output=$(eval "$1")
    return_value=$?

    compare "$expected_output" "$eval_output" "$expected_return" "$return_value" "$1"
    TOTAL_TESTS=$((TOTAL_TESTS+1))
}

printf "\033[1;36m----- PUSHSWAP_CHECKER FUNCTIONAL TESTS -----\033[0m\n\n"

check_binary_existence

printf "\n\033[1;33m----- PUSHSWAP_CHECKER BASICS TESTS -----\033[0m\n\n"

run_test "echo 'sa' | ./$BINARY_NAME 2 1" "OK" 0
run_test "echo 'sa' | ./$BINARY_NAME 2 1 2" "OK" 0
run_test "echo 'sa' | ./$BINARY_NAME 2 1 2 3" "OK" 0
run_test "echo 'sa' | ./$BINARY_NAME 2 1 2 3 1" "KO" 0
run_test "echo 'sb' | ./$BINARY_NAME 1 2" "OK" 0
run_test "echo 'sc' | ./$BINARY_NAME 2 1" "OK" 0
run_test "echo 'pb pa' | ./$BINARY_NAME 1 2" "OK" 0
run_test "echo 'pa pb' | ./$BINARY_NAME 1 2" "KO" 0
run_test "echo 'ra' | ./$BINARY_NAME 2 1" "OK" 0
run_test "echo 'ra' | ./$BINARY_NAME 1 2" "KO" 0
run_test "echo 'pb pb rb pa pa' | ./$BINARY_NAME 2 1" "OK" 0
run_test "echo 'pb pb rb pa' | ./$BINARY_NAME 1 2" "KO" 0

printf "\n\033[1;33m----- PUSHSWAP_CHECKER ADVANCED TESTS -----\033[0m\n\n"

run_test "echo 'pb' | ./$BINARY_NAME 2 1" "KO" 0
run_test "echo 'sa pb pb pb sa pa pa pa' | ./$BINARY_NAME 2 1 3 6 5 8" "OK" 0
run_test "echo 'sa pb pb pb' | ./$BINARY_NAME 2 1 3 6 5 8" "KO" 0
run_test "echo 'pb pb ra pa pa' | ./$BINARY_NAME 2 2 1" "KO" 0
run_test "echo 'sa pb ra rra pa' | ./$BINARY_NAME 2 1" "OK" 0

printf "\n\033[1;33m----- PUSHSWAP_CHECKER ERROR HANDLING TESTS -----\033[0m\n\n"

run_test "echo 'sasa' | ./$BINARY_NAME 2 1" "" 84
run_test "echo 'sa' | ./$BINARY_NAME 2 a" "" 84
run_test "echo '' | ./$BINARY_NAME" "OK" 0
run_test "echo 'sa' | ./$BINARY_NAME 2 -1" "OK" 0
run_test "echo 'sa' | ./$BINARY_NAME 20000000 -10000000" "OK" 0


printf "\n\033[1;34m----- PUSHSWAP_CHECKER RESULT TESTS -----\033[0m\n"
printf "\n\033[1;34mSuccess: %d/%d\n\033[0m" $SUCCESS_TESTS $TOTAL_TESTS
printf "\033[1;34mFailed: %d/%d\033[0m\n\n" $((TOTAL_TESTS-SUCCESS_TESTS)) $TOTAL_TESTS
printf "\033[1;36m----- PUSHSWAP_CHECKER FUNCTIONAL TESTS -----\033[0m\n\n"

if [ $? -eq 0 ]; then
    exit 0
else
    exit 1
fi
