trigger OpportunityPackageTrigger on Opportunity_Package__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	if(Trigger.isAfter)
	{
        if(Trigger.isInsert)
        {
            OpportunityPackageTriggerHandler.onAfterInsert(Trigger.newMap);
        }
        else if(Trigger.isDelete)
        {
            OpportunityPackageTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
            OpportunityPackageTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
    }
}