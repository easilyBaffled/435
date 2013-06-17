#!/bin/bash


echo "Testing core modules"
for dir in ./modules/*-core; do (cd "$dir"/tests && ant report); done

echo "Testing web modules"
for dir in ./modules/*-sel; do (cd "$dir"/tests && ant report); done
