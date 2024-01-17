###########################################################
# Java bindings library
###########################################################
cmake_minimum_required (VERSION 3.8)

# enable verbose logging
set(CMAKE_VERBOSE_MAKEFILE ON)

# Set the project name
project(tdf-java)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

set(CMAKE_CXX_STANDARD 17)

# Get this from VERSION file
file(READ ${PROJECT_SOURCE_DIR}/VERSION JAVA_SDK_BUILD_VERSION)
string(STRIP "${JAVA_SDK_BUILD_VERSION}" JAVA_SDK_BUILD_VERSION)
SET(PACKAGE_VERSION ${JAVA_SDK_BUILD_VERSION})

set(TDFLIB "opentdf_static")

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(JAVA_MODULE_SUFFIX ".dll")
    set(VBUILDTYPEDIR $ENV{VBUILDTYPE}/)
else()
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      set(JAVA_MODULE_SUFFIX ".dylib")
  else()
    set(JAVA_MODULE_SUFFIX ".so")
  endif()
endif()

set(TDF_JAVA_BINDINGS_FILENAME ${PROJECT_NAME}${JAVA_MODULE_SUFFIX})


# generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(SWIG_SOURCE_FILE "virtru.i")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "swig_generated_lib")

find_package(SWIG REQUIRED)
include(UseSWIG)
set_source_files_properties(${SWIG_SOURCE_FILE} PROPERTIES CPLUSPLUS ON)
find_package(Java COMPONENTS Development)
find_package(JNI REQUIRED)

include_directories(
    ${CONAN_INCLUDE_DIRS}
    ${JNI_INCLUDE_DIRS}
)

link_directories(
    ${CONAN_LIB_DIRS}
)

link_libraries(
    ${CONAN_LIBS}
    ${TDFLIB}
)

message(STATUS "Conan include dirs = ${CONAN_INCLUDE_DIRS}")
message(STATUS "JNI include dirs = ${JNI_INCLUDE_DIRS}")
message(STATUS "Conan libs = ${CONAN_LIBS}")

set(CMAKE_SWIG_FLAGS -package com.virtru)

set(TDF_SWIG_JAVA_VERSION "1.9.9")
set(TDF_SWIG_JAVA_TARGET_DIR ${PROJECT_SOURCE_DIR}/target/swig)
set(TDF_SWIG_JAVA_COMVIRTRU "com.virtru")
set(TDF_SWIG_JAVA_JAVADOC "true")

set(TDF_SWIG_JAVA_OUTPUT_DIR ${TDF_SWIG_JAVA_TARGET_DIR}/com/virtru)
set(TDF_SWIG_JAVA_SOURCE_DIR ${PROJECT_SOURCE_DIR})

swig_add_library(
  ${PROJECT_NAME}
  LANGUAGE java
  OUTPUT_DIR ${TDF_SWIG_JAVA_OUTPUT_DIR}
  OUTFILE_DIR ${TDF_SWIG_JAVA_TARGET_DIR}
  SOURCES ${SWIG_SOURCE_FILE}
)

if($ENV{VBUILD_JAVA_MULTI} MATCHES "true")
  message(STATUS "Multi platform build")
else()
  message(STATUS "Single platform build")
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    # For some reason, the default is .jnilib ...
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ${JAVA_MODULE_SUFFIX})
  endif()
  set(TDF_SWIG_JAVA_NATIVE_LIB ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${VBUILDTYPEDIR}tdf-java${JAVA_MODULE_SUFFIX})
  message(STATUS "TDF_SWIG_JAVA_NATIVE_LIB: ${TDF_SWIG_JAVA_NATIVE_LIB}")

endif()

############################################################
# Package for distribution
############################################################

# Create java distribution directory
set(TDF_LIB_INSTALL_LOCATION  ${PROJECT_SOURCE_DIR}/tdf-lib-java)
set(TDF_LIB_JAVA_INSTALL_LOCATION  ${TDF_LIB_INSTALL_LOCATION})
install(DIRECTORY DESTINATION ${TDF_LIB_JAVA_INSTALL_LOCATION})

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND mvn -f ${PROJECT_SOURCE_DIR}/pom.xml install)

if($ENV{VBUILD_JAVA_MULTI} MATCHES "true")
    set(TDF_SWIG_JAVA_PLAT_NAME "multi")
else()
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(TDF_SWIG_JAVA_PLAT_NAME "osx_64")
  endif()
  
  if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(TDF_SWIG_JAVA_PLAT_NAME "linux_64")
  endif()

  if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(TDF_SWIG_JAVA_PLAT_NAME "win_64")
  endif()
endif()

if($ENV{VBUILD_JAVA_MULTI} MATCHES "true")
  set(TDF_SWIG_JAVA_PLAT_JAR "${TDF_SWIG_JAVA_PLAT_NAME}/target/tdf-sdk-${TDF_SWIG_JAVA_PLAT_NAME}-${TDF_SWIG_JAVA_VERSION}.jar")
  set(TDF_JAVA_EXAMPLES ${PROJECT_SOURCE_DIR}/examples)
  set(TDF_JAVA_DOC ${TDF_SWIG_JAVA_TARGET_DIR}/doc)
  message(STATUS "TDF_JAVA_DOC=${TDF_JAVA_DOC}")
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND mvn -f ${TDF_SWIG_JAVA_SOURCE_DIR}/${TDF_SWIG_JAVA_PLAT_NAME}/pom.xml install)

else()
  set(TDF_SWIG_JAVA_PLAT_JAR "native-${TDF_SWIG_JAVA_PLAT_NAME}/target/tdf-sdk-${TDF_SWIG_JAVA_PLAT_NAME}-${TDF_SWIG_JAVA_VERSION}.jar")
  set(TDF_JAVA_EXAMPLES ${PROJECT_SOURCE_DIR}/examples)
  set(TDF_JAVA_DOC ${TDF_SWIG_JAVA_TARGET_DIR}/doc)
  message(STATUS "TDF_JAVA_DOC=${TDF_JAVA_DOC}")
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND mvn -f ${TDF_SWIG_JAVA_SOURCE_DIR}/native-${TDF_SWIG_JAVA_PLAT_NAME}/pom.xml install)

endif()


if(${TDF_SWIG_JAVA_JAVADOC} MATCHES "true")
  # Generate javadoc
  add_custom_command(TARGET ${PROJECT_NAME} DEPENDS ${TDF_SWIG_JAVA_PLAT_JAR} POST_BUILD COMMAND javadoc -d ${TDF_JAVA_DOC} -sourcepath ${TDF_SWIG_JAVA_TARGET_DIR} ${TDF_SWIG_JAVA_COMVIRTRU})
endif()

# Copy the jarfile
#TODO install(FILES ${TDF_SWIG_JAVA_PLAT_JAR} DESTINATION ${TDF_LIB_JAVA_INSTALL_LOCATION})

# Copy the sample dir
file(COPY ${TDF_JAVA_EXAMPLES} DESTINATION ${TDF_LIB_JAVA_INSTALL_LOCATION})

if(${TDF_SWIG_JAVA_JAVADOC} MATCHES "true")
  # Copy the doc dir
  #TODO install(DIRECTORY ${TDF_JAVA_DOC}/ DESTINATION ${TDF_LIB_JAVA_INSTALL_LOCATION}/doc)
endif()

# Copy the README, VERSION, and LICENSE
CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/README.md
        ${TDF_LIB_JAVA_INSTALL_LOCATION})

CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/VERSION
        ${TDF_LIB_JAVA_INSTALL_LOCATION})

CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/LICENSE
        ${TDF_LIB_JAVA_INSTALL_LOCATION})


