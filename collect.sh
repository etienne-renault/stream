#! /bin/bash

# Display environment 
(
    echo "Kernel"
    echo "------"
    uname -m -p -r -s -v

    echo
    echo "Operating system"
    echo "----------------"
    if [[ $SYSTEM == Darwin ]]; then
	sw_vers
    else
	for name in os fedora redhat ubuntu debian alpine; do
            if [[ -e /etc/$name-release ]]; then
		cat /etc/$name-release
		break
            fi
	done
    fi

    echo
    echo "CPU Architecture"
    echo "----------------"
    lscpu

    echo
    echo "CPU Architecture"
    echo "----------------"
    lscpu --all --extended

    echo
    echo "SIMD"
    echo "----------------"
    cat /proc/sys/abi/sve_default_vector_length
 
    echo
    echo "Compiler"
    echo "--------"
    gcc --version
) > results.txt


# collect stream info
(
    NUM_CORES=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
    for pow in $(seq 1 25); do
         STREAM_ARRAY_SIZE=$((2**$pow)) make clean all
	 echo
	 echo ">> Stream pow 2^$pow"
	 echo "--------------------"	 
	 for i in $(seq 1 $NUM_CORES); do
             OMP_NUM_THREADS=$i  OMP_PROC_BIND=close ./stream_openmp.exe 
         done
    done
) >> results.txt
