trigger OpportunityTrigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	if(Trigger.isBefore)
	{
		if(Trigger.isDelete)
		{
			OpportunityTriggerHandler.onBeforeDelete(Trigger.oldMap);
		}
		else if(Trigger.isUpdate)
		{
			 OpportunityTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
	else if(Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        {
            OpportunityTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isDelete)
        {
        	OpportunityTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
        	OpportunityTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
       /* else if(Trigger.isInsert)
        {
           	OpportunityTriggerHandler.onAfterInsert(Trigger.newMap);
        }*/
    }
}