#!/bin/bash

# make the script stop when error (non-true exit code) is occured
set -e

############################################################
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$__conda_setup"
unset __conda_setup
# <<< conda initialize <<<
############################################################

SCRIPT=`realpath -s $0`
export PIPEDIR=`dirname $SCRIPT`

CPU="8"  # number of CPUs to use
MEM="64" # max memory (in GB)

# Inputs:
IN="$1"                # input.fasta
WDIR=`realpath -s $2`  # working folder


LEN=`tail -n1 $IN | wc -m`


conda activate RoseTTAFold
############################################################
# 1. generate MSAs
############################################################
if [ ! -s $WDIR/t000_.msa0.a3m ]
then
    echo "Running HHblits"
    $PIPEDIR/input_prep/make_msa.sh $IN $WDIR $CPU $MEM 
fi


############################################################
# 2. predict secondary structure for HHsearch run
############################################################
if [ ! -s $WDIR/t000_.ss2 ]
then
    echo "Running PSIPRED"
    $PIPEDIR/input_prep/make_ss.sh $WDIR/t000_.msa0.a3m $WDIR/t000_.ss2 
fi


############################################################
# 3. search for templates
############################################################
DB="/databases/rosettafold_dbs/pdb100_2021Mar03/pdb100_2021Mar03"
if [ ! -s $WDIR/t000_.hhr ]
then
    echo "Running hhsearch"
    HH="hhsearch -b 50 -B 500 -z 50 -Z 500 -mact 0.05 -cpu $CPU -maxmem $MEM -aliw 100000 -e 100 -p 5.0 -d $DB"
    cat $WDIR/t000_.ss2 $WDIR/t000_.msa0.a3m > $WDIR/t000_.msa0.ss2.a3m
    $HH -i $WDIR/t000_.msa0.ss2.a3m -o $WDIR/t000_.hhr -atab $WDIR/t000_.atab -v 0
fi


############################################################
# 4. end-to-end prediction
############################################################
if [ ! -s $WDIR/t000_.3track.npz ]
then
    echo "Running end-to-end prediction"
    python $PIPEDIR/network/predict_e2e.py \
        -m /databases/rosettafold_dbs/weights \
        -i $WDIR/t000_.msa0.a3m \
        -o $WDIR/t000_.e2e \
        --hhr $WDIR/t000_.hhr \
        --atab $WDIR/t000_.atab \
        --db $DB 
fi
echo "Done"
