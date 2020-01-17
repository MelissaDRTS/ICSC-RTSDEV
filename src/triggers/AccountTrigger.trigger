trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	if(Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        {
        	if(AccountTriggerHandler.runOnce())
        	{
            	AccountTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        	}
        }
        else if(Trigger.isDelete)
        {
        	AccountTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
        	AccountTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
        else if(Trigger.isInsert)
        {
           	AccountTriggerHandler.onAfterInsert(Trigger.newMap);
        }
    }
}