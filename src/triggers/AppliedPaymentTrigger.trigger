trigger AppliedPaymentTrigger on Applied_Payment__c (before delete, after insert) {
	if(Trigger.isDelete){
		AppliedPaymentTriggerHandler.handleDelete(Trigger.oldMap);
	}
	if(Trigger.isInsert){
		AppliedPaymentTriggerHandler.handleInsert(Trigger.newMap);
	}


}