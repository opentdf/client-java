set PROJECT_DIR=%~dp0
set TDF_JAVA_OUTPUT=tdf-lib-java
set TDF_CMAKE_BUILD_DIR=build

rmdir /s /q %TDF_CMAKE_BUILD_DIR%
rmdir /s /q %TDF_JAVA_OUTPUT%
mkdir %TDF_CMAKE_BUILD_DIR%
pushd %TDF_CMAKE_BUILD_DIR%

REM Install the prerequisites
conan install .. --build=missing
set builderrorlevel=%errorlevel%
if %builderrorlevel% neq 0 goto fin

REM Build the wrapper
conan build .. --build-folder .
set builderrorlevel=%errorlevel%
if %builderrorlevel% neq 0 goto fin

REM REM for some reason the cmake install isn't working, so copy these to the install area now
REM mkdir %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\include\
REM copy /y %PROJECT_DIR%\%TDF_CMAKE_BUILD_DIR%\csharp-bindings\source\*.cs %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\include\
REM 
REM mkdir %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\lib\
REM copy /y %PROJECT_DIR%\%TDF_CMAKE_BUILD_DIR%\lib\*.lib %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\lib\
REM copy /y %PROJECT_DIR%\%TDF_CMAKE_BUILD_DIR%\lib\*.dll %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\lib\
REM 
REM powershell -command Compress-Archive -Force -Path %PROJECT_DIR%\%TDF_JAVA_OUTPUT%\ -CompressionLevel Optimal -DestinationPath %PROJECT_DIR%\%TDF_JAVA_OUTPUT%%TDF_ZIP_SUFFIX%.zip

:fin
REM return to where we came from
popd
exit /b %builderrorlevel%
