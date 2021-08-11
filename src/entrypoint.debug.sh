#!/bin/bash

function backtrace()
{
  TRACE=""
  CP=$$
  
  while true # safe because "all starts with init..."
  do
          CMDLINE=$(cat /proc/$CP/cmdline)
          PP=$(grep PPid /proc/$CP/status | awk '{ print $2; }') # [2]
          TRACE="$TRACE --> [$CP]:$CMDLINE\n"
          if [ "$CP" == "1" ]; then # we reach 'init' [PID 1] => backtrace end
                  break
          fi
          CP=$PP
  done

  printf "Backtrace of '$0'\n"
  printf "$TRACE" | tac | grep -n ":" # using tac to "print in reverse" [3]
} 2>/dev/null
