#!/bin/bash

cp ./security.keystore.cloud ~/app/scripts/
cp ./TC.cloud.ldap.keystore ~/app/scripts/

rm -rf ~/processor/work
mkdir ~/processor/work
rm -rf ~/processor/cache
mkdir ~/processor/cache
chmod +x ~/processor/deploy/app/cpp/timeout/timeout

java -jar ~/dev/arena-vm/elasticmq-server-0.8.3.jar &

sleep 10

# create local sqs queues
java -cp "/home/apps/app/lib/jars/*" -Darena.sqs-endpoint='http://localhost:9324' com.topcoder.arena.util.sqs.LocalSqsSetup 'http://localhost:9324' devArenaCode- compile admin-test listener-results proc-results mm-test practice srm-test

sleep 2

OS_BITS=`getconf LONG_BIT`
CPP_ARGUMENTS="-DcppArguments='--std=c++0x'"
if [ $OS_BITS -eq 32 ]; then
    CPP_ARGUMENTS=""
fi

# localhost:9324 = elasticmq (local sqs)
# also set dummy aws credentials
export JAVA_OPTS="$CPP_ARGUMENTS -Darena.sqs-endpoint=http://localhost:9324 -Darena.env-prefix=dev -Daws.accessKeyId=x -Daws.secretKey=x -DconfigurationProvider.class=com.topcoder.farm.controller.configuration.XMLConfigurationProvider -Dconfiguration.xml.url=file:///home/apps/app/controller/config.xml"
export JBOSS_JAVA_OPTS="$JBOSS_JAVA_OPTS -Djavax.net.ssl.trustStore=TC.cloud.ldap.keystore"

cd ~/app/scripts

# start jboss
echo Starting JBoss...
./jboss.sh

echo Waiting for startup...
sleep 80

echo Starting main listener...
./runMainListener.sh

echo Waiting for listener to initialize...
sleep 90

echo Starting admin listener...
./runAdminListener.sh

echo Starting mpsqas listener...
./mpsqasListener.sh start 5037

echo Starting web socket listener...
./runWebSocketListener.sh

cd ~/processor/deploy/bin
echo Starting processor...
./processor.sh PR-LX

echo Startup complete
exit

