#!/bin/bash

# Note: Logs are not teardown after running so that
# people can check the output if there are failures

oneTimeSetUp(){
  rm -rf logs
  mkdir logs
}

assertPass(){
$@
assertEquals 'assertPass failed' 0 $?
}

assertFail(){
$@
assertEquals 'assertFail failed' 1 $?
}

assertFileContains(){
    assertPass egrep -q "$2" $1
}

assertFileNotContains(){
    assertFail grep -i -q "$2" $1
}

test_syscallCountTracepoint(){
    logfile="logs/syscallcount-tracepoint.log"
    bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile "tracepoint"
    assertFileNotContains $logfile "error"
}

test_readHistogram(){
    logfile="logs/readHistogram.log"
    bpftrace scripts/read.bt &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_printFileOpens(){
    logfile="logs/printFileOpens.log"
    bpftrace -e 'kprobe:do_sys_open { printf("%s: %s\n", comm, str(arg1)) }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile 'irqbalance|sleep'
    assertFileNotContains $logfile "error"
}


test_CPUprofiling(){
    logfile="logs/cpuprofiling.log"
    bpftrace -e 'profile:hz:99 { @[stack] = count() }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

test_syscallCountProgram(){
    logfile="logs/syscallcountprogram.log"
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile 'bpftrace'
    assertFileNotContains $logfile "error"
}

test_readBytesByProcess(){
    logfile="logs/readbytesprocess.log"
    bpftrace -e 'tracepoint:syscalls:sys_exit_read /args->ret/ { @[comm] = sum(args->ret); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

test_readSizeDistributionByProcess(){
    logfile="logs/read-size-distribution-process.log"
    bpftrace -e 'tracepoint:syscalls:sys_exit_read { @[comm] = hist(args->ret); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@@'
    assertFileNotContains $logfile "error"
}

test_perSecondSyscallRates(){
    logfile="logs/per-second-syscall-rates.log"
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @ = count(); } interval:s:1 { print(@); clear(@); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@:'
    assertFileNotContains $logfile "error"
}

test_diskSizeByProcess(){
    logfile="logs/disk-size-process.log"
    bpftrace -e 'tracepoint:block:block_rq_issue { printf("%d %s %d\n", pid, comm, args->bytes); }'&> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    logline=$(grep -v '^$' $logfile | grep -v Attach | wc -l)
    assertTrue "[ $logline -gt 1 ]"
    assertFileNotContains $logfile "error"
}

test_pageFaultsByProcess(){
    logfile="logs/page-faults-process.log"
    bpftrace -e 'software:faults:1 { @[comm] = count(); }' &> $logfile &
    bpid=$!
    sleep 5
    kill -INT $bpid
    sleep 5

    assertFileContains $logfile '@'
    assertFileNotContains $logfile "error"
}

# README.md not tested
# Print process name and paths for file opens, using kprobes (kernel dynamic tracing) of do_sys_open()
# Files opened by process
# Count LLC cache misses by process name and PID (uses PMCs)
# Profile user-level stacks at 99 Hertz, for PID 189

. ../shunit2
