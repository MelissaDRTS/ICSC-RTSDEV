trigger DocuSignStatusTrigger on dsfs__DocuSign_Status__c (after update) {
	DocuSignStatusTriggerHandler handler = new DocuSignStatusTriggerHandler();
	handler.handleUpdate(Trigger.new);
}