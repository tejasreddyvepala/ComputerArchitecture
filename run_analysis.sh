#! /usr/bin/env bash

if [ "$#" -lt 3 ]; then
	echo "Incorrect number of parameters"
	echo "Usage: ./run_analysis.sh [ANALYSIS_TYPE] [TEST_FILE_PATH] [DEBUG]"
	exit 1
fi

SIM_TYPE="$1"
TEST_FILE=$2
DEBUG=$3

CONFIGS_DIR="./myconfig"
SIM_DIR="./output-sim"
PROG_DIR="./output-prog"
RESULTS_DIR="./results"

if [ ! -d $CONFIGS_DIR ]; then
	echo "Missing configuration files to run analysis with!"
	exit 1
fi

if [ ! -e $TEST_FILE ] && [ $SIM_TYPE == 'b' ]; then
	echo "Missing test file to run analysis on!"
	exit 1
fi

if [ ! -d $SIM_DIR ]; then
	if [ $DEBUG -eq 1 ]; then
		echo "Making $SIM_DIR directory..."
	fi
	mkdir $SIM_DIR
fi

if [ ! -d $PROG_DIR ]; then
	if [ $DEBUG -eq 1 ]; then
		echo "Making $PROG_DIR directory..."
	fi
	mkdir $PROG_DIR
fi

if [ ! -d $RESULTS_DIR ]; then
	if [ $DEBUG -eq 1 ]; then
		echo "Making $RESULTS_DIR directory..."
	fi
	mkdir $RESULTS_DIR
fi

if [ $SIM_TYPE == 'b' ] || [ $SIM_TYPE == 'a' ]; then
	echo; echo "Executing analysis on branch predictors"; echo
	for bpred_cfg_path in "$CONFIGS_DIR"/bpred_*; do
		bpred=$(echo $bpred_cfg_path | cut -d/ -f3 | cut -d_ -f2 | cut -d. -f1)
		echo -e "\t Running sim-outorder simulator with $bpred branch predictor..."
		./sim-outorder -config $bpred_cfg_path $TEST_FILE
	done

	echo; echo "Extracting vital branch prediction results from the simulator runs..."; echo
	for test_bpred_path in "$SIM_DIR"/test_bpred_*; do
		bpred=$(echo $test_bpred_path | cut -d/ -f3 | cut -d_ -f3)
		echo -e "\tSaving bpred:${bpred}'s results..."
		sed -n -e '8p' -e '130,150p' -e '171,188p' $test_bpred_path > ${RESULTS_DIR}/result_bpred_${bpred}
		
		if [ $DEBUG -eq 1 ]; then
			echo -e "\tPrinting bpred:${bpred}'s metrics:";
			echo -e "\t\t$(sed -n '/bpred_addr_rate/ p' $test_bpred_path)"
			echo -e "\t\t$(sed -n '/bpred_dir_rate/ p' $test_bpred_path)"
			echo -e "\t\t$(sed -n '/bpred_jr_rate/ p' $test_bpred_path)"
			echo
		fi
	done
fi

if [ $SIM_TYPE == 'c' ] || [ $SIM_TYPE == 'a' ]; then
	echo; echo "Executing analysis on cache-oblivious algorithms"; echo
	./sim-outorder -config myconfig/caching_row.cfg mytests/caching_row_major.o
	./sim-outorder -config myconfig/caching_col.cfg mytests/caching_col_major.o

	echo; echo "Extracting vital cache stats from the simulator runs..."; echo
	types=(row col)
	for access_type in "${types[@]}"; do
		echo -e "\tSaving cache_${access_type}'s results..."
		sim_output_path=${SIM_DIR}/test_cache_${access_type}
		sed -n -e '139,142p' -e '146,148p' -e '189,238p' $sim_output_path > ${RESULTS_DIR}/result_caching_${access_type}
		
		if [ $DEBUG -eq 1 ]; then
			echo -e "\tPrinting cache:${access_type}'s metrics:";
			echo -e "\t\t$(sed -n '/sim_elapsed_time/ p' $sim_output_path)"
			echo -e "\t\t$(sed -n '/sim_cycle/ p' $sim_output_path)"
			echo -e "\t\t$(sed -n '/sim_IPC/ p' $sim_output_path)"
			echo -e "\t\t$(sed -n '/dl1.miss_rate/ p' $sim_output_path)"
			echo -e "\t\t$(sed -n '/ul2.miss_rate/ p' $sim_output_path)"
			echo
		fi
	done
fi