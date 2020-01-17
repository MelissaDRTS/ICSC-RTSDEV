trigger ImisBoothSalesHistoryTrigger on iMIS_Booth__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	if(Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        { 
            ImisBoothSalesHistoryTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isDelete)
        {
        	ImisBoothSalesHistoryTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
        	ImisBoothSalesHistoryTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
        else if(Trigger.isInsert)
        {
           	ImisBoothSalesHistoryTriggerHandler.onAfterInsert(Trigger.newMap); 
        }
    }
}