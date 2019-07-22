#!/bin/bash

# Note: Logs are not teardown after running so that
# people can check the output if there are failures

LOGPREFIX=$(dirname $0)/logs/$(basename $0)
oneTimeSetUp(){
rm -rf ${LOGPREFIX}
mkdir -p ${LOGPREFIX}
/usr/bin/pkill -9 bpftrace || true
}

test_listingProbes(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -l 'tracepoint:syscalls:sys_enter_*' &> $logfile
    assertFileContains $logfile "tracepoint"
}

test_helloWorld(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    unbuffer bpftrace -e 'BEGIN { printf("hello world\n"); }' &> $logfile &
    bpid=$!
    sleep 3
    /usr/bin/kill -INT $bpid

    assertFileContains $logfile 'hello'
    assertFileNotContains $logfile "error"
}

test_fileOpens(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    unbuffer bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args->filename)); }' &> $logfile &
    bpid=$!
    sleep 3
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid

    assertFileContains $logfile 'lscpu'
}


test_syscallCountsByProcess(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid
    sleep 3

    assertFileContains $logfile '@\[lscpu\]'
    assertFileNotContains $logfile "error"
}

test_distributionofReadBytes(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:syscalls:sys_exit_read /pid == 1/ { @bytes = hist(args->ret); }' &> $logfile &
    bpid=$!
    sleep 5
    systemctl status noexistprogram &>/dev/null
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_kernelDynamicTracingofReadBytes(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'kretprobe:vfs_read { @bytes = lhist(retval, 0, 2000, 200); }' &> $logfile &
    bpid=$!
    sleep 5
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_timingReads(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'kprobe:vfs_read { @start[tid] = nsecs; } kretprobe:vfs_read /@start[tid]/ { @ns[comm] = hist(nsecs - @start[tid]); delete(@start[tid]); }' &> $logfile &
    bpid=$!
    sleep 3
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_countProcessLevelEvents(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:sched:sched* { @[probe] = count(); } interval:s:5 { exit(); }' &> $logfile &
    bpid=$!
    sleep 3
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@\[tracepoint'
    assertFileNotContains $logfile "error"
}

test_profileOnCPUKernelStacks(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'profile:hz:99 { @[kstack] = count(); }' &> $logfile &
    bpid=$!
    sleep 3
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@\['
    assertFileNotContains $logfile "error"
}

test_schedulerTracing(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:sched:sched_switch { @[kstack] = count(); }' &> $logfile &
    bpid=$!
    sleep 3
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid
    sleep 3
    assertFileContains $logfile '@\['
    assertFileNotContains $logfile "error"
}


test_kernelStructTracing(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    unbuffer bpftrace scripts/path.bt &> $logfile &
    bpid=$!
    sleep 3
    lscpu > /dev/null
    /usr/bin/kill -INT $bpid
    assertFileContains $logfile 'open'
}

# tutorial_one_liners not tested:
#  Lesson 11. Block I/O Tracing

. $(dirname $0)/../lib/include
