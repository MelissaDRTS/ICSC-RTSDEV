trigger OpportunityLineItemTrigger on OpportunityLineItem (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    if(Trigger.isBefore){
        if (Trigger.isInsert){
             OpportunityLineItemTriggerHandler.onBeforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate){
            OpportunityLineItemTriggerHandler.onBeforeUpdate(Trigger.new);
        }
    }else if (Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        {
            OpportunityLineItemTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isDelete) 
        {
        	OpportunityLineItemTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isInsert)
        {
           	OpportunityLineItemTriggerHandler.onAfterInsert(Trigger.newMap);
        }
    }
	
	/*if(Trigger.isAfter)
	{
        if(Trigger.isDelete)
        {
        	OpportunityLineItemTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
    }*/
}