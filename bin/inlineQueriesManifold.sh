#!/bin/bash

mydir=$(dirname $0)
prog=$(cat $1 |
	sed 's/CQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/query(S=pos, T=cautious, F=\1, I=\2, Q=\3)/g' |
	sed 's/BQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/query(S=pos, T=brave, F=\1, I=\2, Q=\3)/g')

# inline all queries
queries=$(echo $prog | grep -o "query(S=[[:alnum:]]*, T=[[:alnum:]]*, F=[[:alnum:]]*, I=[[:alnum:]]*, Q=[[:alnum:]]*)")
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
                if [[ $sign == "pos" ]]; then
			echo "#minimize{1@0, Atom : not true($filename, Atom, Atom), atom($filename, Atom); 1:inconsistent($filename)}."
		else
                        echo "#minimize{1@0, Atom : true($filename, Atom, Atom), atom($filename, Atom); 1:inconsistent($filename)}."
		fi
	fi
        if [[ $querytype == "cautious" ]]; then
                if [[ $sign == "pos" ]]; then
                        echo "#minimize{1@0, Atom : true($filename,Atom,Atom), atom($filename, Atom); 1:inconsistent($filename)}."
		else
                        echo "#minimize{1@0, Atom : not true($filename,Atom,Atom), atom($filename, Atom); 1:inconsistent($filename)}."
		fi
		echo "true($filename, Atom, Atom) :- inconsistent($filename), atom($filename, Atom)."
        fi

	# make sure that the query atom contains in the subprogram by introducing a dummy rule without effects
	echo "head($filename,dummy,$queryatom)."
        echo "bodyP($filename,dummy,$queryatom)."

	# we want to know if the query atom is a brave resp. cautious consequence
	echo "copy($filename, $queryatom)."

	# extract query answer
	echo "query($filename) :- true($filename, $queryatom, $queryatom)."

	# add query input as facts
	echo "head($filename,input(X),$queryinput(X)) :- $queryinput(X)."
done


cat $1 |
        sed 's/CQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/query(\1)/g' |
        sed 's/BQ *\[ *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *, *\([[:alnum:]]*\) *\] *( *)/query(\1)/g'
