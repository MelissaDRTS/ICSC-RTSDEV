public with sharing class DocuSignStatusTriggerHandler {
	public DocuSignStatusTriggerHandler() {
		
	}
	public void handleUpdate(List<dsfs__DocuSign_Status__c> updatedStatuses){
		List<Id> oppIds = new List<Id>();
		Map<id,id> opp2status = new Map<id,id>();
		for(dsfs__DocuSign_Status__c status : updatedStatuses){
			if(status.dsfs__Envelope_Status__c == 'Completed'){
				oppIds.add(status.dsfs__Opportunity__c);
				opp2status.put(status.dsfs__Opportunity__c, status.id);
			}
		}
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([Select Id,Signed_Contract_Uploaded__c, StageName from Opportunity where id in :oppIds]);
		List<Opportunity> updateOps = new List<Opportunity>();
		for(Opportunity op : oppMap.values()){
			if(op.StageName != 'Closed Won'){
				op.Signed_Contract_Uploaded__c = true;
				op.StageName = 'Closed Won';
				updateOps.add(op);
		}
		}
		update updateOps;
	}
}