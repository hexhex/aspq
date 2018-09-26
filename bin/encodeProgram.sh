#!/bin/bash

index=0
if [[ $# -ge 2 ]]; then
        index=$2
fi
echo "index($index)."

#atomcnt=$(gringo $1 2>/dev/null | sed -n '/^0$/,/^0$/p' | grep -v "^0" | wc -l)
#echo "int($index, 0..$atomcnt)".

haveHead=0
body=0
atomnr=0
rulenr=1
consatom="constraint"
consnr=1
cat $1 |
	grep -v " *%" |		# ignorecomments
	tr -d '\n' |		# into one line
	sed 's/(/\n(/g' | sed 's/)/)\n/g' |  # split before ( and after )
	sed '/^(/!s/\,/;/g' | 	# substitute commas excelt in lines of form (...)
	tr -d '\n' |            # into one line
	sed 's/:-/\n:-\n/g' | 	# split before and after :-
	sed 's/\./\n.\n/g' |	# split before and after .
	sed 's/;/\n/g' |        # replace semicolons
	sed 's/not /!/g' |	# replace not
	tr -d ' ' |		# remove blanks
	grep -v '^$' |		# eliminate blank lines
while read -r line
do
	if [[ $line == ":-" ]]; then
		if [[ $haveHead == 0 ]]; then
			ocache="$ocache\nhead($index,r$rulenr\$variables,$consatom$consnr)\$guard."
			ocache="$ocache\nbodyN($index,r$rulenr\$variables,$consatom$consnr)\$guard."
			let consnr=consnr+1
		fi
		body=1
	elif [[ $line == "." ]]; then
		haveHead=0
		body=0
		atomnr=0
		let rulenr++
		variables=$(echo -e "$variables" | sort | uniq | sed 's/$/\,/g' | tr -d '\n' | sed 's/,$//' )
		if [[ "$variables" != "" ]]; then
			variables="($variables)"
		fi
		eval "echo -e \"$ocache\"" | grep -v "^$"
		variables=""
		guard=""
		ocache=""
	else
		if [[ $body == 0 ]]; then
			ocache="$ocache\nhead($index,r$rulenr\$variables,$line)\$guard."
			haveHead=1
		else
			if [[ "$line" =~ "!".* ]]; then
				ocache="$ocache\nbodyN($index,r$rulenr\$variables,${line:1})\$guard."
			else
				ocache="$ocache\nbodyP($index,r$rulenr\$variables,$line)\$guard."
				if [[ "$guard" == "" ]]; then
					guard=" :- head($index,R$atomnr,$line)"
				else
					guard=$(echo "$guard, head($index,R$atomnr,$line)")
				fi
				nvariables=$(echo -n $line | grep -o '[A-Z][[:alnum:]]*')
				if [[ "$variables" == "" ]]; then
					variables="$nvariables"
				else
					variables=$(echo "$variables\n$nvariables")
				fi
			fi
			let atomnr++
		fi
	fi
done

