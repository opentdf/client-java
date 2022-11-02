set PROJECT_DIR=%~dp0
set TDF_JAVA_OUTPUT=tdf-lib-java
set TDF_CMAKE_BUILD_DIR=build

rmdir /s /q %TDF_CMAKE_BUILD_DIR%
rmdir /s /q %TDF_JAVA_OUTPUT%
mkdir %TDF_CMAKE_BUILD_DIR%
mkdir %TDF_JAVA_OUTPUT%
pushd %TDF_CMAKE_BUILD_DIR%

REM Install the prerequisites
conan install .. --build=missing
set builderrorlevel=%errorlevel%
if %builderrorlevel% neq 0 goto fin

REM Build the wrapper
conan build .. --build-folder .
set builderrorlevel=%errorlevel%
if %builderrorlevel% neq 0 goto fin

copy %PROJECT_DIR%\native-win_64\target\opentdf-sdk-*.jar %PROJECT_DIR%%TDF_JAVA_OUTPUT%\
xcopy /s %PROJECT_DIR%\target\swig\doc %PROJECT_DIR%%TDF_JAVA_OUTPUT%\

powershell -command Compress-Archive -Force -Path %PROJECT_DIR%%TDF_JAVA_OUTPUT%\ -CompressionLevel Optimal -DestinationPath %PROJECT_DIR%%TDF_JAVA_OUTPUT%%TDF_ZIP_SUFFIX%.zip

:fin
REM return to where we came from
popd
exit /b %builderrorlevel%
