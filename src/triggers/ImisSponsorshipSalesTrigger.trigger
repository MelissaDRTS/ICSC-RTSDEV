trigger ImisSponsorshipSalesTrigger on iMIS_Sponsorship_Sales__c (after delete, after insert, after undelete,after update, before delete, before insert, before update) 
{
	if(Trigger.isAfter)
	{
        if(Trigger.isUpdate)
        {
            ImisSponsorshipSalesTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isDelete)
        {
        	ImisSponsorshipSalesTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        else if(Trigger.isUndelete)
        {
        	ImisSponsorshipSalesTriggerHandler.onAfterUndelete(Trigger.newMap);
        }
        else if(Trigger.isInsert)
        {
           	ImisSponsorshipSalesTriggerHandler.onAfterInsert(Trigger.newMap); 
        }
    }
}