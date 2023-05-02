import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

import org.scijava.nativelib.NativeLoader;

import com.virtru.*;

public class virtru_java_sample {

   public static class k {
       static String owner = "neep@yeep.dance"; 
       static String clientId = "tdf-client";
       static String clientSecret = "123-456";
       static String organizationName = "tdf";
       static String oidcEndpoint = "http://localhost:65432/";
       static String kasUrl = "http://localhost:65432/api/kas";
   }

   public class testData {
       String plaintext = "Virtru is the industry leader in data protection!";

       File plaintextFile;
       File encryptedFile;
       File decryptedFile;

       ByteVector plaintextData;
       ByteVector encryptedData;
       ByteVector decryptedData;
    }

   public void prepareTestData(testData td) throws Exception {

       String prefix = "tdf-sdk-java-test";

       td.plaintextFile = File.createTempFile(prefix, "plaintext");
       td.plaintextFile.deleteOnExit();

       FileWriter fileWriter = new FileWriter(td.plaintextFile.getAbsolutePath());
       fileWriter.write(td.plaintext);
       fileWriter.close();

       // Create these files only to get a unique filename 
       td.encryptedFile = File.createTempFile(prefix, "encrypted");
       td.encryptedFile.deleteOnExit();

       td.decryptedFile = File.createTempFile(prefix, "decrypted");
       td.decryptedFile.deleteOnExit();

       td.plaintextData = new ByteVector(td.plaintext.getBytes());

   }

   public void validateTestData(testData td) throws Exception {

       // Read the file decryption results into a string
       char [] result = new char[128];
       FileReader fileReader = new FileReader(td.decryptedFile.getAbsolutePath());
       fileReader.read(result);
       fileReader.close();
       String decryptedFileText = new String(result);

       // Read the data decryption results into a string
       StringBuilder decryptedDataText = new StringBuilder();
       for (byte b : td.decryptedData) {
           char c = (char) (b);
           decryptedDataText.append(c);
       }

       System.out.println("Plaintext: " + td.plaintext);

       System.out.println("Decrypted file: " + decryptedFileText);

       System.out.println("Decrypted data: " + decryptedDataText);

   }

   public void doNanoOidc() throws Exception {
      try {
         System.out.println("Using NanoTDF client with OIDC credentials");

         testData td = new testData();
         prepareTestData(td);

         OIDCCredentials creds = new OIDCCredentials();
         creds.setClientCredentialsClientSecret(k.clientId, k.clientSecret, k.organizationName, k.oidcEndpoint);
         NanoTDFClient client = new NanoTDFClient(creds, k.kasUrl);

         TDFStorageType plaintextFileStorage = new TDFStorageType();
         plaintextFileStorage.setTDFStorageFileType(td.plaintextFile.getAbsolutePath());
         client.encryptFile(plaintextFileStorage, td.encryptedFile.getAbsolutePath());

         TDFStorageType encryptedFileStorage = new TDFStorageType();
         encryptedFileStorage.setTDFStorageFileType(td.encryptedFile.getAbsolutePath());
         client.decryptFile(encryptedFileStorage, td.decryptedFile.getAbsolutePath());

         TDFStorageType plaintextDataStorage = new TDFStorageType();
         plaintextDataStorage.setTDFStorageBufferType(td.plaintextData);
         td.encryptedData = client.encryptData(plaintextDataStorage);

         TDFStorageType encryptedDataStorage = new TDFStorageType();
         encryptedDataStorage.setTDFStorageBufferType(td.encryptedData);
         td.decryptedData = client.decryptData(encryptedDataStorage);

         validateTestData(td);
      } catch (RuntimeException e) {
         System.out.println("Exception" + e.toString());
         System.out.println("Caught");
         throw e;
      }
   }

   public void doTDFOidc() throws Exception {
      try {
         System.out.println("Using TDF client with OIDC credentials");

         testData td = new testData();
         prepareTestData(td);

         OIDCCredentials creds = new OIDCCredentials();
         creds.setClientCredentialsClientSecret(k.clientId, k.clientSecret, k.organizationName, k.oidcEndpoint);
         TDFClient client = new TDFClient(creds, k.kasUrl);

         TDFStorageType plaintextFileStorage = new TDFStorageType();
         plaintextFileStorage.setTDFStorageFileType(td.plaintextFile.getAbsolutePath());
         client.encryptFile(plaintextFileStorage, td.encryptedFile.getAbsolutePath());

         TDFStorageType encryptedFileStorage = new TDFStorageType();
         encryptedFileStorage.setTDFStorageFileType(td.encryptedFile.getAbsolutePath());
         client.decryptFile(encryptedFileStorage, td.decryptedFile.getAbsolutePath());

         TDFStorageType plaintextDataStorage = new TDFStorageType();
         plaintextDataStorage.setTDFStorageBufferType(td.plaintextData);
         td.encryptedData = client.encryptData(plaintextDataStorage);

         TDFStorageType encryptedDataStorage = new TDFStorageType();
         encryptedDataStorage.setTDFStorageBufferType(td.encryptedData);
         td.decryptedData = client.decryptData(encryptedDataStorage);

         validateTestData(td);
      } catch (RuntimeException e) {
         System.out.println("Exception" + e.toString());
         System.out.println("Caught");
         throw e;
      }
   }

   public static void main(String argv[]) throws Exception {
      try {
       NativeLoader.loadLibrary("tdf-java");

       virtru_java_sample sample = new virtru_java_sample();

       sample.doNanoOidc();

       sample.doTDFOidc();
      } catch (Exception e) {
         System.out.println("Exception" + e.toString());
         System.out.println("Caught");
         throw e;
      }
   }
}

