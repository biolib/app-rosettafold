#!/bin/bash
echo "Running RoseTTAFold with: $@"

for i in "$@"; do
  case $i in
    --fasta=*)
      INPUT_FILE="${i#*=}"
      shift # past argument=value
      ;;
    --model=*)
      MODEL="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

echo "$MODEL $INPUT_FILE"


if [[ $MODEL == "pyrosetta" ]]
then
    ./run_pyrosetta_ver.sh $INPUT_FILE .
elif [[ $MODEL == "e2e" ]] 
then
    ./run_e2e_ver.sh $INPUT_FILE .
fi

