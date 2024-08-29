@isTest
public class Test_GenerateEncryptedKey {

    @isTest
    public static void testEncryption() {
        test.startTest();
        List<GenerateEncryptedKey.Inputs> inputs = new List<GenerateEncryptedKey.Inputs>();
        GenerateEncryptedKey.Inputs input = new GenerateEncryptedKey.Inputs();
        input.keyLength = 10;
        inputs.add(input);
        List<GenerateEncryptedKey.Outputs> outputs = GenerateEncryptedKey.generateKey(inputs);
        test.stopTest();
    }
}