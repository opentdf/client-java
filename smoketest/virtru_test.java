import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

import org.scijava.nativelib.*;
import com.virtru.*;

public class virtru_test {
   public static void main(String argv[]) throws Exception {

       NativeLoader.loadLibrary("virtru-tdf-java");

       String appId = System.getenv("VIRTRU_SDK_APP_ID");
       if (appId==null || appId.trim().isEmpty()) {
           appId = "2abb3273-9236-43bc-9fda-806855aa80f8";
       }
       String owner = System.getenv("VIRTRU_SDK_EMAIL");
       if (owner==null || owner.trim().isEmpty()) {
           owner = "tdf-user@virtrucanary.com";
       }

       String easUrl = "https://api.virtru.com/accounts";
       String kasUrl = "https://api.virtru.com/kas";
       String acmUrl = "https://api.virtru.com/acm";

       String prefix = "virtru-sdk-java-test";

       String plainText = "Hello World!!";

       File inputFile = File.createTempFile(prefix, "input");
       inputFile.deleteOnExit();
       File encryptedFile = File.createTempFile(prefix, "encrypted");
       encryptedFile.deleteOnExit();

       FileWriter fileWriter = new FileWriter(inputFile.getAbsolutePath());
       fileWriter.write(plainText);
       fileWriter.close();

       Client client = new Client(owner, appId);
       
       System.out.println(client);

       client.enableConsoleLogging(virtruConstants.LogLevel_Trace);
       client.setProtocol(virtruConstants.Protocol_Zip);

       client.setKasUrl(kasUrl);
       client.setEasUrl(easUrl);
       client.setAcmUrl(acmUrl);

       EncryptFileParams encryptFileParams = new EncryptFileParams(inputFile.getAbsolutePath(), encryptedFile.getAbsolutePath());
       
       StringVector recipientsIn = new StringVector();
       recipientsIn.add("user1@virtrucanary.com");
       Policy policy = new Policy();
       policy.shareWithUsers(recipientsIn);
       
       encryptFileParams.setPolicy(policy);
       
       client.encryptFile(encryptFileParams);
       
       FileReader fileReader1 = new FileReader(encryptedFile.getAbsolutePath());
       int i;
       while ((i = fileReader1.read()) != -1)
           System.out.print((char) i);
       System.out.println("");
       
       System.out.println("Encrypt success!");

       File decryptedFile = File.createTempFile(prefix, "decrypted");
       decryptedFile.deleteOnExit();
       
       client.decryptFile(encryptedFile.getAbsolutePath(), decryptedFile.getAbsolutePath());
       
       FileReader fileReader2 = new FileReader(decryptedFile.getAbsolutePath());
       int j;
       while ((j = fileReader2.read()) != -1)
           System.out.print((char) j);
       System.out.println("");
       
       System.out.println("Decrypt success!");
   }
 }
