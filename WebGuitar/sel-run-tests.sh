#!/bin/bash


echo "Testing core modules"
for dir in ./modules/*-core; do 

  if [ -d "$dir" ]; then
    cd "$dir"
    
    if [-d ./tests ]; then
      cd tests
      
      ant report
    fi
    
  fi
  
done



echo "Testing web modules"
for dir in ./modules/*-sel; do 

  if [ -d "$dir" ]; then
    cd "$dir"
    
    if [-d ./tests ]; then
      cd tests
      
      ant report
    fi
    
  fi
  
done
