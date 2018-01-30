#! /bin/sh
#
# buildsdk.sh
#
# Build script for the macchina.cloud Device SDK.
#

PARALLEL_BUILDS=4

config=""
if [ "$1" != "" ] ; then
	config="--config=$1"
fi

omit="--omit=Data,Data/SQLite,Data/ODBC,Data/MySQL,Data/PostgreSQL,Zip,PageCompiler,PDF,CppParser,MongoDB,Redis,PocoDoc,ProGen"
echo "Starting macchina.cloud SDK build..."

export SDK_BASE=`pwd`
export POCO_BASE=$SDK_BASE/poco
export PROJECT_BASE=$SDK_BASE/WebTunnel
export POCO_CONFIG=$1

cd $POCO_BASE

./configure --cflags=-DPOCO_UTIL_NO_XMLCONFIGURATION --cflags=-DPOCO_UTIL_NO_JSONCONFIGURATION --no-tests --no-samples --static $omit $config
if [ $? -ne 0 ] ; then
	echo "Configure script failed. Exiting."
	exit 1
fi
make -s -j$PARALLEL_BUILDS DEFAULT_TARGET=static_release 
if [ $? -ne 0 ] ; then
	echo "POCO C++ Libraries build failed. Exiting."
	exit 1
fi

cd $SDK_BASE

function build() {
	app=$1
	echo "Building: $app, target: $2"
	make -s DEFAULT_TARGET=$2 -C $app
	if [ $? -ne 0 ] ; then
		echo "SDK build failed."
		exit 1
	fi
}

build WebTunnel static_release

for app in WebTunnelAgent WebTunnelClient WebTunnelSSH WebTunnelVNC; do
	build WebTunnel/$app shared_release
done

echo ""
echo "macchina.cloud SDK build is complete."
echo ""
