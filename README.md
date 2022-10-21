# TDF SDK

The TDF Java SDK allows developers to easily create and manage encrypted [Trusted Data Format (TDF) objects](https://github.com/virtru/tdf-spec) and interact with [Key Access and Entity Attribute Services (KAS, EAS).](https://developer.virtru.com/docs/architecture)

## Installation

Unpack the archive file, and ensure the .jar file is in your classpath.  Note that the jar file contains native code, so the flavor appropriate for the platform must be used.

## Authentication

opentdf allows users to set authentication headers (OIDC bearer tokens, etc), and will use those for authenticating with
backing services - by design it *does not contain* authentication flow logic, for example to exchange client credentials
for OIDC bearer tokens, refresh expired tokens, etc - it expects callers to handle that.

For an example of how to wrap this library in auth provider flows, see `virtru-tdf-cpp`

### OIDC

1. Provide KAS url, user id, and set the use_oidc flag to true:

```java
TDFClient client = new TDFClient(kas_url, user_id, True);
```

1. Provide the TDFClient instance with your valid, previously obtained/generated OIDC bearer token:

``` java
client.set_auth_header("eyJhbGciOiJSUzI1NiIsInR5cCIg...");
```

### Legacy EAS

Two different methods:

1. Provide EAS url and user id (user should be registered on EAS):

```java
TDFClient client = new TDFClient(eas_url, user_id);
```

1. Provide EAS url, user id, client key (absolute file path), client cetificate (absolute file path) and root CA (absolute file path)

```java
TDFClient client = TDFClient(eas_url, user_id, filepath_client_key, filepath_client_cert, filepath_rootCA)
```

## Create Encrypted TDF Object (minimal example)

```java
import com.virtru.*;
import org.scijava.nativelib.NativeLoader;

[...]

NativeLoader.loadLibrary("tdf-java");

NanoTDFClient client = new NanoTDFClient(eas_url, user_id);

client.encryptFile(unprotected_file, protected_file);
```

