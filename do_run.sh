#!/bin/bash

trap 'echo "last command failed" && exit 1' ERR
trap 'echo "user interrupted" && exit 1' INT

TEST_RUN=$1

do_run() {
  local outputFile="output/$1.txt"

  echo "start test on `date`" > $outputFile

  for subcmd in build up; do

    local cmd="docker-compose $subcmd"

    echo "------------------" >> $outputFile 2>&1
    echo "# $cmd"             >> $outputFile 2>&1
    echo "------------------" >> $outputFile 2>&1
    $cmd                      >> $outputFile 2>&1
  done
}

do_run $TEST_RUN
