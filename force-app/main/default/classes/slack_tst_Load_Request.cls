@isTest
public class slack_tst_Load_Request {
	@isTest 
	static void testTrigger() {
		FreightTM__Trip__c obj1 = new FreightTM__Trip__c(
			Status__c = 'Active'
		);
		insert obj1;

		Load_Request__c obj0 = new Load_Request__c(
			Job__c = obj1.Id,
			Request_For__c = 'Mats'
		);
		insert obj0;
	}
}