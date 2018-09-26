for (( variableCount=$1; variableCount <= $2; variableCount+=$3 ))
do
	for (( termCount=$4; termCount <= $5; termCount+=$6 ))
	do
		for (( instance=1; instance <= $7; instance++ ))
		do
			vc=`printf "%03d" ${variableCount}`
			tc=`printf "%03d" ${termCount}`
			./generate.sh $variableCount $termCount > "instances/qbf_variablecount_${vc}_termcount_${tc}_inst_${instance}.inst"
		done
	done
done
