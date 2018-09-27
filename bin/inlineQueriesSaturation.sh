#!/bin/bash

mydir=$(dirname $0)
prog=$(cat $1 |
	sed 's/CQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/noAS(S=pos, T=cautious, F=\1, I=\2, Q=\3)/g' |
	sed 's/BQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/noAS(S=pos, T=brave, F=\1, I=\2, Q=\3)/g')

# inline all queries
queries=$(echo $prog | grep -o "noAS(S=[[:alnum:]]*, T=[[:alnum:]]*, F=[[:alnum:]]*, I=[[:alnum:]]*, Q=[[:alnum:]]*)")
echo $queries |
while read -r line
do
	# inline current query
	sign=$(echo $line | sed 's/.*S=\([[:alnum:]]*\).*/\1/')
	querytype=$(echo $line | sed 's/.*T=\([[:alnum:]]*\).*/\1/')
	filename=$(echo $line | sed 's/.*F=\([[:alnum:]]*\).*/\1/')
        queryinput=$(echo $line | sed 's/.*I=\([[:alnum:]]*\).*/\1/')
	queryatom=$(echo $line | sed 's/.*Q=\([[:alnum:]]*\).*/\1/')
	$mydir/encodeProgram.sh $filename $filename
	if [[ $querytype == "brave" ]]; then
		echo "head($filename,query,queryconstraintatom)."
		echo "bodyN($filename,query,queryconstraintatom)."
		if [[ $sign == "pos" ]]; then
			echo "bodyN($filename,query,$queryatom)."
		else
			echo "bodyP($filename,query,$queryatom)."
		fi
	fi
        if [[ $querytype == "cautious" ]]; then
                echo "head($filename,query,queryconstraintatom)."
                echo "bodyN($filename,query,queryconstraintatom)."
                if [[ $sign == "pos" ]]; then
                        echo "bodyP($filename,query,$queryatom)."
                else
                        echo "bodyN($filename,query,$queryatom)."
                fi
        fi

	# add query input as facts
	echo "head($filename,input(X),$queryinput(X)) :- $queryinput(X)."
done


cat $1 |
        sed 's/CQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/noAS(\1)/g' |
        sed 's/BQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/not noAS(\1)/g'
