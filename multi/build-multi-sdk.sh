APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

rm tdf-sdk-all-*.jar
rm -rf tmpjar
mkdir tmpjar
cd  tmpjar
TDF_SDK_VERSION=$(cat $APP_DIR/../TDF-SDK-VERSION)
OUTPUT_VERSION=${1:-$TDF_SDK_VERSION}
echo "Generate all platform jar version $OUTPUT_VERSION"
extract_native () {
  inputJar=$1
  echo "$inputJar libtdf-java.$2 natives/$3/"
  cp ../$inputJar .
  jar -xf $inputJar
  mkdir -p natives/$3/
  mv libtdf-java.$2 natives/$3/
  rm -f *.$2
  rm $inputJar
}
extract_native "tdf-sdk-osx_amd64-$TDF_SDK_VERSION.jar" "dylib" "osx_64"
# extract_native "tdf-sdk-osx_arm64-$INPUT_VERSION.jar" "dylib" "osx_arm64"
extract_native "tdf-sdk-linux_amd64-$TDF_SDK_VERSION.jar" "so" "linux_amd64"
extract_native "tdf-sdk-linux_amd64-$TDF_SDK_VERSION.jar" "so" "linux_64"
extract_native "tdf-sdk-linux_arm64-$TDF_SDK_VERSION.jar" "so" "linux_arm64"
## patch new jar with latest native loader.
rm -rf org/scijava
curl -H "Accept: application/zip" https://repo1.maven.org/maven2/org/scijava/native-lib-loader/2.5.0/native-lib-loader-2.5.0.jar -o native-lib-loader-2.5.0.jar
jar -xf native-lib-loader-2.5.0.jar
rm  native-lib-loader-2.5.0.jar
rm -rf META-INF/maven
echo "FILES:"
echo $(ls)
jar cf tdf-sdk-all-$OUTPUT_VERSION.jar .
mv tdf-sdk-all-$OUTPUT_VERSION.jar ../
cd ../
echo "FILES OUTSIDE:"
echo $(ls)
echo $(pwd)
rm -rf tmpjar
