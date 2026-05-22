#!/bin/bash

output=$(sensors 2>/dev/null)

fan1=$(echo "$output" | grep "fan1:" | awk '{print $2}')
fan2=$(echo "$output" | grep "fan2:" | awk '{print $2}')

avg=$(( (fan1 + fan2) / 2 ))

echo "$avg $fan1 $fan2"