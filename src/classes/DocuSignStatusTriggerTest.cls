@isTest
public class DocuSignStatusTriggerTest {
	@isTest
	static void testUpdate(){
		Account ac  = DataFactory.createAccount('Test', true);
		Opportunity op = DataFactory.createOpp('Test', ac.id, Date.today(), true);
		dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c(dsfs__Opportunity__c=op.Id, dsfs__Envelope_Status__c='Sent');
		insert status;
		status.dsfs__Envelope_Status__c = 'Completed';
		update status;
	}
}