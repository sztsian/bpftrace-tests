#!/bin/bash

# Note: Logs are not teardown after running so that
# people can check the output if there are failures

LOGPREFIX=$(dirname $0)/logs/$(basename $0)
oneTimeSetUp(){
rm -rf ${LOGPREFIX}
mkdir -p ${LOGPREFIX}
/usr/bin/pkill -9 bpftrace || true
}

test_syscallCountTracepoint(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile "tracepoint"
    assertFileNotContains $logfile "error"
}

test_readHistogram(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace scripts/read.bt &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_printFileOpens(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'kprobe:do_sys_open { printf("%s: %s\n", comm, str(arg1)) }' &> $logfile &
    bpid=$!
    sleep 5
    cat /etc/kdump.conf &>/dev/null
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile 'irqbalance|sleep|cat|grep|bpftrace'
    assertFileNotContains $logfile "error"
}


test_CPUprofiling(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'profile:hz:99 { @[stack] = count() }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

test_syscallCountProgram(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile 'bpftrace'
    assertFileNotContains $logfile "error"
}

test_readBytesByProcess(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:syscalls:sys_exit_read /args->ret/ { @[comm] = sum(args->ret); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

test_readSizeDistributionByProcess(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:syscalls:sys_exit_read { @[comm] = hist(args->ret); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_perSecondSyscallRates(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @ = count(); } interval:s:1 { print(@); clear(@); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@:'
    assertFileNotContains $logfile "error"
}

#test_diskSizeByProcess(){
#    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
#    bpftrace -e 'tracepoint:block:block_rq_issue { printf("%d %s %d\n", pid, comm, args->bytes); }'&> $logfile &
#    bpid=$!
#    sleep 5
#    df -hT
#    /usr/bin/kill -INT $bpid
#    sleep 5
#
#    assertFileContains $logfile "df"
#    assertFileNotContains $logfile "error"
#}

test_pageFaultsByProcess(){
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    bpftrace -e 'software:faults:1 { @[comm] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    /usr/bin/kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

# README.md not tested
# Print process name and paths for file opens, using kprobes (kernel dynamic tracing) of do_sys_open()
# Files opened by process
# Count LLC cache misses by process name and PID (uses PMCs)
# Profile user-level stacks at 99 Hertz, for PID 189

. $(dirname $0)/../lib/include
