public class NameParser_InvocableAction {

    public class FlowInputs {
        @InvocableVariable(required = true)
        public String fullName;
    }

    public class FlowOutputs {
        @InvocableVariable
        public String firstName;

        @InvocableVariable 
        public String lastName;
    }

    public NameParser_InvocableAction() {

    }

    @InvocableMethod(label='Full Name Parser')
    public static List<FlowOutputs> parseName(List<FlowInputs> flowInput) {
        System.debug('Parsing Name...');
        List<FlowInputs> inputs = new List<FlowInputs>();
        FlowOutputs nameOutput = new FlowOutputs();
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        for (FlowInputs request : flowInput) {
            inputs.add(request);
        }

        System.debug('Inputs received from Flow: ');
        System.debug(inputs);

        String fName = '-';
        String lName = '-';

        if(inputs[0].fullName != null) {
            String name = inputs[0].fullName;
 
            List<String> splitName = name.split(' ');
            if(splitName.size() > 0) {
                fName = splitName[0];
                if(splitName.size() > 1) {
                    lName = splitName[1];
                } 
            }
            
        }

        nameOutput.firstName = fName;
        nameOutput.lastName = lName;

        outputs.add(nameOutput);
        return outputs;
    }
}