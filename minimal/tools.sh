#!/bin/bash -i

bpftraceprefix=$(rpm -ql bpftrace | grep tools | head -n 1)
BPFTRACEPATH=${bccpath:-${bpftraceprefix}}
LOGPREFIX=$(dirname $0)/logs/$(basename $0)

oneTimeSetUp(){
rm -rf ${LOGPREFIX}
mkdir -p ${LOGPREFIX}
ps -ef | grep '/usr/share/bpftrace' | grep -v grep | awk '{print $2}' | xargs /usr/bin/kill -9 {} &> /dev/null || true 
}

test_bashreadline(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/bashreadline.bt &> ${logfile}
}

test_biolatency(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/biolatency.bt &> ${logfile}
}

test_biosnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/biosnoop.bt &> ${logfile}
}

test_bitesize(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/bitesize.bt &> ${logfile}
}

test_capable(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/capable.bt &> ${logfile}
}

test_cpuwalk(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/cpuwalk.bt &> ${logfile}
}

test_dcsnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/dcsnoop.bt &> ${logfile}
}

test_execsnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/execsnoop.bt &> ${logfile}
}

test_gethostlatency(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/gethostlatency.bt &> ${logfile}
}

test_killsnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassTerm ${BPFTRACEPATH}/killsnoop.bt &> ${logfile}
}

test_loads(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/loads.bt &> ${logfile}
}

test_mdflush(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/mdflush.bt &> ${logfile}
}

test_oomkill(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/oomkill.bt &> ${logfile}
}

test_opensnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/opensnoop.bt &> ${logfile}
}

test_pidpersec(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/pidpersec.bt &> ${logfile}
}

test_runqlat(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/runqlat.bt &> ${logfile}
}

test_runqlen(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/runqlen.bt &> ${logfile}
}

test_statsnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/statsnoop.bt &> ${logfile}
}

test_syncsnoop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/syncsnoop.bt &> ${logfile}
}

test_syscount(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/syscount.bt &> ${logfile}
}

test_tcpaccept(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/tcpaccept.bt &> ${logfile}
}

test_tcpconnect(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/tcpconnect.bt &> ${logfile}
}

test_tcpdrop(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/tcpdrop.bt &> ${logfile}
}

test_tcpretrans(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/tcpretrans.bt &> ${logfile}
}

test_vfscount(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/vfscount.bt &> ${logfile}
}

test_vfsstat(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/vfsstat.bt &> ${logfile}
}

test_writeback(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/writeback.bt &> ${logfile}
}

test_xfsdist(){
    skipIfNotExist ${BPFTRACEPATH}/$(echo ${FUNCNAME[ 0 ]} | awk -F '_' '{print $2}').bt
    modprobe xfs
    logfile=${LOGPREFIX}/${FUNCNAME[ 0 ]}.log
    assertPassInt ${BPFTRACEPATH}/xfsdist.bt &> ${logfile}
}

. $(dirname $0)/../lib/include
