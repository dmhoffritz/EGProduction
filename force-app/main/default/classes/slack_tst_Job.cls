@isTest
public class slack_tst_Job {
	@isTest 
	static void testTrigger() {
		FreightTM__Trip__c obj0 = new FreightTM__Trip__c(
			Freight_In_Amount__c = 1,
			Freight_Out_Amount__c = 1,
			Status__c = 'Active',
			City__c = 's',
			State__c = 'AK'
		);
		insert obj0;
	}
}