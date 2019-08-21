#!/usr/bin/env bash

set -e
# set -x

# Constants #

declare -r _RESULTS_DIRECTORY="$(mktemp -d --suffix=system-benchmark)"
declare -r _CPU_CORES="$(nproc)"

# Functions #

# Main #

function main {
    echo "Results in: $_RESULTS_DIRECTORY"

    pushd "$_RESULTS_DIRECTORY"

    # Single threaded CPU test
    sysbench --validate=on --threads=1 cpu run |& tee sysbench-single-thread.log

    # Multithreaded CPU tests
    sysbench --validate=on --threads="$_CPU_CORES" cpu run |& tee sysbench-all-cores-short.log
    # Time increased to 180 seconds to check for thermal throttling
    # issues. This does not put the CPU under a totally full load, as
    # something like `stress` would, but for general purposes we don't
    # want to know if the system will throttle under maximum load, but
    # under very high but more expected load.
    sysbench --validate=on --time=180 --threads="$_CPU_CORES" cpu run |& tee sysbench-all-cores-long.log

    popd

    echo "Results in: $_RESULTS_DIRECTORY"
}

main "$@"
