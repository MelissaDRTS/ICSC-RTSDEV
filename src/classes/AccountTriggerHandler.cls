public with sharing class AccountTriggerHandler 
{ 
	@TestVisible private static boolean run = true;
	
	public static void onAfterInsert(Map<Id, Account> newRecordMap)
	{
		List<Account> records = newRecordMap.values();
		Set<ID> parentAccountIds = new Set<ID>();
		
		for(Account a : records)
		{
			if(a.ParentId != null)
			{
				parentAccountIds.add(a.ParentId);
			}
		}
				
		if(!parentAccountIds.isEmpty())
		{
			AccountUtility.setParentCustomerRecordType(parentAccountIds);
		}
	}
	
	public static void onAfterUpdate(Map<Id, Account> newRecordMap, Map<Id, Account> oldRecordMap)
	{
		List<Account> newRecords = newRecordMap.values();
		Set<ID> parentAccountIds = new Set<ID>();
		Set<ID> oldParentAccountIds = new Set<ID>();
		
		for(Account a : newRecords)
		{
			Account old = oldRecordMap.get(a.Id);
			
			if(a.ParentId != old.ParentId)
			{
				if(a.ParentId != null)
				{
					parentAccountIds.add(a.ParentId);
				}
				
				if(old.ParentId != null)
				{
					oldParentAccountIds.add(old.ParentId);
				}
			}
			
			//Update top1000 in iMIS
			if(a.iMIS_ID__c != null && a.ICSC_Top_Account__c != old.ICSC_Top_Account__c)
			{
				AccountUtility.UpdateTop1000(a.iMIS_ID__c, a.ICSC_Top_Account__c);
			}
		}
				
		if(!parentAccountIds.isEmpty())
		{
			AccountUtility.setParentCustomerRecordType(parentAccountIds);
		}
		
		if(!oldParentAccountIds.isEmpty())
		{
			AccountUtility.setCustomerRecordType(oldParentAccountIds);
		}
	}
	
	public static void onAfterDelete(Map<Id, Account> oldRecordMap)
	{
		List<Account> records = oldRecordMap.values();
		Set<ID> parentAccountIds = new Set<ID>();
		
		for(Account a : records)
		{
			if(a.ParentId != null)
			{
				parentAccountIds.add(a.ParentId);
			}
		}
				
		if(!parentAccountIds.isEmpty())
		{
			AccountUtility.setCustomerRecordType(parentAccountIds);
		}
		
	}
	
	public static void onAfterUndelete(Map<Id, Account> newRecordMap)
	{
		List<Account> records = newRecordMap.values();
		Set<ID> parentAccountIds = new Set<ID>();
		
		for(Account a : records)
		{
			if(a.ParentId != null)
			{
				parentAccountIds.add(a.ParentId);
			}
		}
				
		if(!parentAccountIds.isEmpty())
		{
			AccountUtility.setParentCustomerRecordType(parentAccountIds);
		}
				
	}
		
	public static boolean runOnce()
    {
        if(run)
        {
             run=false;
             return true;
        }
        else
        {
            return run;
        }
    }   
}