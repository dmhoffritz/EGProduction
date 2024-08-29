public with sharing class GenerateEncryptedKey {
    public class Inputs {
        @InvocableVariable(
            label='Key Length'
            description='Length of encrypted key to be generated'
        )
        public Integer keyLength;
    }

    public class Outputs {
        @InvocableVariable(
            label='Encrypted Key'
            description='Key generated from method'
        )
        public String encryptedKey;
    }

    @InvocableMethod(label='Generate Encrypted Key' description='Use this method to generate a random key to be used elsewhere in flow')
    public static List<Outputs> generateKey(List<Inputs> inputs) {
        Integer keyLength = 8;
        for (Inputs input : inputs) {
            if (input.keyLength > 0) {
                keyLength = input.keyLength;
            }
        }

        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String encryption = key.substring(0, keyLength);

        List<Outputs> outputs = new List<Outputs>();
        Outputs output = new Outputs();
        output.encryptedKey = encryption;
        outputs.add(output);

        return outputs;
    }
}