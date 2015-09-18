#!/bin/sh 
DEMO="JBoss BPM Suite Anti Money Laundering Demo"
AUTHORS="Anurag Saran, Eric D. Schabell"
PROJECT="git@github.com:eschabell/bpms-anti-money-laundering-demo.git"

#BPM env
JBOSS_HOME=./target/jboss-eap-6.4
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
PRJ_DIR=./projects
SUPPORT_DIR=./support
BPMS=jboss-bpmsuite-6.1.0.GA-installer.jar
EAP=jboss-eap-6.4.0-installer.jar
BPM_VERSION=6.1

#DataGrid env 
DEMO_HOME=./target
DATAGRID_ZIP=jboss-datagrid-6.5.1-server.zip
DATAGRID_HOME=$DEMO_HOME/jboss-datagrid-6.5.1-server
DATAGRID_SERVER_BIN=$DATAGRID_HOME/bin
DATAGRID_VERSION=6.5.1


# wipe screen.
clear 

# add executeable in installs
chmod +x installs/*.zip

echo
echo "########################################################################################"
echo "##                                                                                    ##"   
echo "##  Setting up the                                                                    ##"
echo "##                                                                                    ##"   
echo "##            ${DEMO}                              ##"
echo "##                                                                                    ##"   
echo "##   ####  ####   #   #   ###       ####   ###  #####  ###   #### ##### ##### ####    ##"
echo "##   #   # #   # # # # # #      #   #   # #   #   #   #   # #     #   #   #   #   #   ##"
echo "##   ####  ####  #  #  #  ##   ###  #   # #####   #   ##### #  ## #####   #   #   #   ##"
echo "##   #   # #     #     #    #   #   #   # #   #   #   #   # #   # #  #    #   #   #   ##"
echo "##   ####  #     #     # ###        ####  #   #   #   #   #  #### #   # ##### ####    ##"
echo "##                                                                                    ##"   
echo "##  brought to you by,                                                                ##"
echo "##                     ${AUTHORS}                                 ##"
echo "##                                                                                    ##"   
echo "##  project: ${PROJECT}             ##"
echo "##                                                                                    ##"   
echo "########################################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $EAP package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
	echo Product sources BPM are present...
	echo
else
	echo Need to download $BPMS package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [[ -r $SRC_DIR/$DATAGRID_ZIP || -L $SRC_DIR/$DATAGRID_ZIP ]]; then
		echo Product sources DataGrid are present...
		echo
else
		echo Need to download $DATAGRID_ZIP package from the Customer Support Portal 
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

# Remove JBoss product installation if exists.
if [ -x target ]; then
	echo "  - existing JBoss product installation detected..."
	echo
	echo "  - removing existing JBoss product installation..."
	echo
	rm -rf target
fi

# Run installers.
echo "JBoss EAP installer running now..."
echo
java -jar $SRC_DIR/$EAP $SUPPORT_DIR/installation-eap -variablefile $SUPPORT_DIR/installation-eap.variables

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP installation!
	exit
fi

echo
echo "JBoss BPM Suite installer running now..."
echo
java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables

if [ $? -ne 0 ]; then
	echo Error occurred during BPMS installation!
	exit
fi

# Start DataGrid installation
if [ -x target ]; then
  # Unzip the JBoss DataGrid instance.
	echo
  echo Installing JBoss DataGrid $DATAGRID_VERSION
  echo
  unzip -q -d target $SRC_DIR/$DATAGRID_ZIP
else
	echo
	echo Missing target directory, stopping installation.
	echo 
	exit
fi

echo
echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/application-roles.properties $SERVER_CONF

echo "  - setting up demo projects..."
echo
cp -r $SUPPORT_DIR/bpm-suite-demo-niogit $SERVER_BIN/.niogit

echo "  - building projects..."
echo
mvn clean install -f $PRJ_DIR/pom.xml

# Example of copying sources from project to deployments directory.
#
#echo "  - deploying external-client-ui-form-1.0.war to EAP deployments directory"
#echo
#cp -r $PRJ_DIR/external-client-ui-form/target/external-client-ui-form-1.0.war $SERVER_DIR/

echo
echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

echo "  - setup email task notification users..."
echo
cp $SUPPORT_DIR/userinfo.properties $SERVER_DIR/business-central.war/WEB-INF/classes/

# Optional: uncomment this to install mock data for BPM Suite.
#
#echo - setting up mock bpm dashboard data...
#cp $SUPPORT_DIR/1000_jbpm_demo_h2.sql $SERVER_DIR/dashbuilder.war/WEB-INF/etc/sql
#echo

echo
echo "===================================================================================================="
echo "=                                                                                                  ="
echo "=  You can now start the JBoss BPM Suite with:                                                     ="
echo "=                                                                                                  ="
echo "=        $SERVER_BIN/standalone.sh                                                  ="
echo "=                                                                                                  ="
echo "=    - login, build and deploy JBoss BPM Suite process project at:                                 ="
echo "=                                                                                                  ="
echo "=        http://localhost:8080/business-central (u:erics/p:bpmsuite1!)                             ="
echo "=                                                                                                  ="
echo "=  You can now start the JBoss Data Grid with:                                                     ="
echo "=                                                                                                  ="
echo "=   $DATAGRID_SERVER_BIN/standalone.sh -Djboss.socket.binding.port-offset=100  ="
echo "=                                                                                                  ="
echo "=   $DEMO Setup Complete.                                     ="
echo "===================================================================================================="
echo
