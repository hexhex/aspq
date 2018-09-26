#!/bin/bash

runheader=$(which run_header.sh)
if [[ $runheader == "" ]] || [ $(cat $runheader | grep "run_header.sh Version 1." | wc -l) == 0 ]; then
        echo "Could not find run_header.sh (version 1.x); make sure that the benchmark scripts directory is in your PATH"
        exit 1
fi
source $runheader

# run instances
if [[ $all -eq 1 ]]; then
	# run all instances using the benchmark script run insts
	$bmscripts/runinsts.sh "instances/*.inst" "$mydir/run.sh" "$mydir" "$to" "" "" "$req"
else
	mydir=$(dirname $0)
	confstr="$mydir/callclingo.sh qbfPlain.hex $instance;$mydir/../../bin/aspq.sh dlvhex2 external qbfQueries.hex $instance;$mydir/../../bin/aspq.sh potassco eiterpolleres06unopt qbfQueries.hex $instance;$mydir/../../bin/aspq.sh potassco eiterpolleres06 qbfQueries.hex $instance;$mydir/../../bin/aspq.sh potassco eiterpolleres06revised qbfQueries.hex $instance;$mydir/../../bin/aspq.sh potassco redl18 qbfQueries.hex $instance;$mydir/../../bin/aspq.sh potassco faberwoltran11 qbfQueries.hex $instance"

	$bmscripts/runconfigs.sh "CONF" "$confstr" "$instance" "$to" ""
fi

