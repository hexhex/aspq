# $1: variable count n (n existential and n universal)
# $2: term count

for (( i=0; i < $1; i++ ))
do
	echo "exists(x$i)."
	echo "forall(a$i)."
done

for (( i=1; i <= $2; i++ ))
do
	echo -n "term("
	for (( j=1; j <= 3; j++ ))
	do
		if [ $j -gt 1 ]; then
			echo -n ","
		fi
                if [ $RANDOM -le 16384 ]; then
			echo -n "1,"
		else
			echo -n "0,"
 		fi
                if [ $RANDOM -le 16384 ]; then
			echo -n "x"
		else
			echo -n "a"
		fi
                var=$(($RANDOM % $1))
		echo -n "$var" 
	done
	echo ")."
done
