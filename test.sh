#!/usr/bin/env bash

while [[ "$#" -gt 0 ]]
do
case $1 in
    -f|--follow-me|-a|--aaa)
        FOLLOW="following"
        shift 1
        ;;
    -t|--tail)
        TAIL="tail=$2"
        shift 2
        ;;
    *)
        echo "WARNING: Ignoring command line argument: $1"
        shift 1
        ;;
esac
done

echo "FOLLOW: $FOLLOW"
echo "TAIL: $TAIL"


# Adapted from: https://riptutorial.com/bash/example/19531/a-function-that-accepts-named-parameters
