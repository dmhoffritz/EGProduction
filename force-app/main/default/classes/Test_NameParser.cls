@isTest 
public class Test_NameParser {
    @isTest 
    public static void testNameParser() {
        test.startTest();
        List<NameParser_InvocableAction.FlowInputs> inputs = new List<NameParser_InvocableAction.FlowInputs>();
        NameParser_InvocableAction.FlowInputs nameInput = new NameParser_InvocableAction.FlowInputs(); 
        nameInput.fullName = 'Test Name';       
        inputs.add(nameInput);
        List<NameParser_InvocableAction.FlowOutputs> outputs = NameParser_InvocableAction.parseName(inputs);
        System.assertEquals('Test', outputs[0].firstName);
        System.assertEquals('Name', outputs[0].lastName);
        test.stopTest();
    }
}