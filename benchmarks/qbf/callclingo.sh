#!/bin/bash
clingo -n 0 $@ | grep "Answer:" -A 1 | grep "Answer:" -v | sed 's/^/\{/; s/ /,/g; s/$/\}/'
