#!/bin/bash
set -ex
export TDF_JAVA_BUILD="build"
export TDF_JAVA_LIB_OUTPUT="tdf-lib-java"
export TDF_JAVA_LIB_ARCHIVE="tdf-lib-java.tar.gz"

# OSX build options
if [[ $OSTYPE == "darwin"* ]]; then
  OSNAME="macos"
  export VBUILD_ADD_MACOS_FLAGS="true"
  if [[ "${JAVA_HOME}x" == "x" ]]; then
    echo "JAVA_HOME not set, attempting to fix"
    export JAVA_HOME=`/usr/libexec/java_home`
  else
    echo "JAVA_HOME already set"
  fi
  echo "JAVA_HOME=${JAVA_HOME}"
fi

rm -rf $TDF_JAVA_BUILD
rm -rf $TDF_JAVA_LIB_OUTPUT
mkdir $TDF_JAVA_BUILD
mkdir $TDF_JAVA_LIB_OUTPUT
cd $TDF_JAVA_BUILD
conan install .. --build=missing
conan build .. -bf .
cd ..

cp native-*/target/tdf-sdk-*.jar $TDF_JAVA_LIB_OUTPUT
cp -rp target/swig/doc $TDF_JAVA_LIB_OUTPUT
tar -zcvf "$TDF_JAVA_LIB_ARCHIVE" "$TDF_JAVA_LIB_OUTPUT"
