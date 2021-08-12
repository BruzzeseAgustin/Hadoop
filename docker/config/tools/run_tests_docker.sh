#!/bin/bash

# $HADOOP_HOME/etc/hadoop/hadoop-env.sh

## Start supervisord
# later, you will need to specifcy which demons you want to start
/usr/bin/supervisord -c /etc/supervisord.conf -n &

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run

retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1

    until $cmd
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            exit
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}
# example usage:
# retry 5 ls -ltr foo

# Main funcion for starting Hadoop image
function usage {
  echo "Usage: $0 [OPTION]..."
  echo 'Run Hadoop test suite'
  echo ''
  echo '  -h    Show usage'
  echo '  -i    Run Kerberos initialization'
  echo '  -a    Run Hadoop s component initialization'
  echo '  -s    Run Solr initialization'
  echo '  -r    Run Ranger initialization'
  echo '  -t    Run Hadoop cluster s tests' 
  echo '  -x    exit instantly on first error or failed test'
  exit
}

while getopts hirstax opt
do
  case "$opt" in
    h) usage;;
    i) init_krb="true";;
    a) init_hadoop="true";;
    s) init_solr="true";;
    r) init_rgr="true";;
    t) run_apt_tests="true";;
    x) exitfirst="-x";;
  esac
done

# Start Kerberos
if test ${init_krb}; then
    echo 'Runing tests'
    /opt/tools/bootstrap_krb.sh
    echo "KDC is up and ready to go... starting up"
    kinit -kt ${KEYTAB_DIR}/abruzzese.keytab abruzzese
    echo "========== Verifying Kerberos... =========="
    klist -ket ${KEYTAB_DIR}/abruzzese.keytab 2>&1 | tee /opt/ranger/results/test-admin-01_output.txt
    ret_code=$?
    if [ $ret_code != 0 ]; then
      echo "Error : Wrong bad inicialization ofthe kerberos service"
      exit $ret_code
    fi
fi

if test ${init_krb_keys}; then
    echo 'Creating kerberos key'

    echo "to be done "
fi

# Start SOLR
if test ${init_solr}; then
    echo 'Start solr'

    retry 5 klist -ket ${KEYTAB_DIR}/hdfs.keytab
    echo "KDC is up and ready to go... starting up"
    supervisorctl start solr-setup
    retry 5 chmod +x /opt/solr/ranger_audit_server/scripts/start_solr.sh
    supervisorctl start solr-server
    chmod -R 777 /opt/solr/ranger_audit_server/
fi

# Start Ranger
if test ${init_rgr}; then
    echo 'Start Ranger component'

    retry 5 klist -ket ${KEYTAB_DIR}/ranger.keytab
    echo "KDC is up and ready to go... starting up"
    /opt/tools/configure_ranger.sh
    /opt/tools/bootstrap_ranger.sh
    /opt/tools/bootstrap_ranger_services.sh
fi

# Start Hadoop
if test ${init_hadoop}; then
    echo 'Start Hadoop component'

    retry 5 klist -ket ${KEYTAB_DIR}/hdfs.keytab
    echo "KDC is up and ready to go... starting up"
    /opt/tools/bootstrap_hadoop.sh
fi

# Run tests
if test ${run_apt_tests}; then
    echo 'Runing application tests'
    /opt/tools/bootstrap_applications_tests.sh
    /opt/tools/bootstrap_web_tests.sh
    /opt/tools/bootstrap_check_tests.sh
fi


