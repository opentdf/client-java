/* virtru.i */
%module virtru


/* This is Swig magic that will take char** outPolicyId and 
   turn it into String[] in Java.  

   See: https://github.com/swig/swig/blob/master/Lib/java/various.i

   -jgrady
*/
%include "various.i"
%include "enumsimple.swg"
%include "std_string.i"
%include "std_vector.i"
%include <stdint.i>

%rename(operatorEqual) operator=;

namespace std {
   %template(StringVector) vector<string>;
   %template(ByteVector) vector<int8_t>;
}

#define SWIG 1
#define SWIG_JAVA 1

/* SWIG by default will not touch pure virtual content, force it to */
%feature("notabstract") TDFClient;
%feature("notabstract") NanoTDFClient;

%{
#include "tdf_constants.h"
#include "oidc_credentials.h"
#include "tdf_assertion.h"
#include "tdf_storage_type.h"
#include "tdf_client_base.h"
#include "tdf_client.h"
#include "nanotdf_client.h"
%}

/* 
https://stackoverflow.com/questions/69496549/wrap-all-swig-generated-methods-in-try-catch
*/

%exception {
    try {
        $action
    }
    catch (const std::exception& e) {
        SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, e.what());
        return $null;
    }
}


%include "tdf_constants.h"
%include "oidc_credentials.h"
%include "tdf_assertion.h"
%include "tdf_storage_type.h"
%include "tdf_client_base.h"
%include "tdf_client.h"
%include "nanotdf_client.h"
