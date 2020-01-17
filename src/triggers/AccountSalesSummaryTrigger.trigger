trigger AccountSalesSummaryTrigger on Account_Sales_Summary__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert) 
		{
			AccountSalesSummaryTriggerHandler.onBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate)
        {
            AccountSalesSummaryTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
	}
	else if(Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        {
        	//if(AccountSalesSummaryTriggerHandler.runOnce())
        	//{
            	AccountSalesSummaryTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        	//}
        }
        else if(Trigger.isDelete)
        {
        	AccountSalesSummaryTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
        	AccountSalesSummaryTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
        else if(Trigger.isInsert)
        {
           	AccountSalesSummaryTriggerHandler.onAfterInsert(Trigger.newMap);
        }
    }
}