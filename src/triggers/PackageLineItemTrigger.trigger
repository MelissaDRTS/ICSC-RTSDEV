trigger PackageLineItemTrigger on Package_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            PackageLineItemTriggerHandler.onBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            PackageLineItemTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}