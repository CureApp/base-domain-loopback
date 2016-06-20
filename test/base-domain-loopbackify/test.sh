#!/bin/bash

dirname=${0%/*}

run_test () {

    cd $dirname

    preparation

    run_browserify

    result=`run_packed`

    evaluate_result $result
}

preparation () {

    rm -f "$dirname/domain/master-data/all.json"
    echo -e "window = {};\n" > packed.js
}


run_browserify () {
    browserify="../../node_modules/.bin/browserify"
    $browserify --extension=.coffee -t coffeeify -t [ base-domain-loopback/ify --dirname domain ] entry/index.coffee >> packed.js 
}

run_packed () {
    result=`node packed.js`
    rm -f "$dirname/packed.js"
    echo $result
}

evaluate_result () {
    result="$*"

    expected="device name is iPhone6S and os is iOS"

    if [[ $result == $expected ]]; then
        echo 'base-domain-loopback/ify succeeded!'
        exit 0
    else
        echo 'base-domain-loopback/ify failed'
        exit 1
    fi
}



run_test
