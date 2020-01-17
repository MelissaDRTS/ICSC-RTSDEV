global with sharing class AccountUtility 
{
	public static ID getParentCustomerRecordTypeId()
	{
		return Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent Customer').getRecordTypeId();
	}
	
	public static ID getCustomerRecordTypeId()
	{
		return Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	}
	
	public static void setParentCustomerRecordType(Set<ID> parentAccountIds)
	{
		ID parentRecordTypeId = AccountUtility.getParentCustomerRecordTypeId();
		List<Account> parents = [SELECT Id, RecordTypeId FROM Account WHERE Id in: parentAccountIds AND RecordTypeId !=: parentRecordTypeId];
		
		if(!parents.isEmpty())
		{
			for(Account a : parents)
			{
				a.RecordTypeId = parentRecordTypeId;
			}
			
			update parents;
		}
	}
	
	//Updates record type of accounts that no longer have any children accounts 
	public static void setCustomerRecordType(Set<ID> oldParentAccountIds)
	{
		ID customerRecordTypeId = AccountUtility.getCustomerRecordTypeId();
		List<Account> accountsToUpdate = new List<Account>();
		Set<ID> accountsWithChildren = new Set<ID>();
		AggregateResult[] childrenCount = [SELECT ParentId, count(ID) children FROM Account WHERE ParentId in: oldParentAccountIds GROUP BY ParentId];
		Map<Id, Account> parentAccountMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id  in: oldParentAccountIds]); //work around for issue when merging accounts
		
		for(AggregateResult ar : childrenCount)
		{
			ID aId = (ID) ar.get('ParentId');
			Integer children = (Integer) ar.get('children');
			
			if(children > 0)
			{
				accountsWithChildren.add(aId);
			}
		}
		
		for(ID aId : oldParentAccountIds)
		{
			if(!accountsWithChildren.contains(aId) && parentAccountMap.containsKey(aId))
			{
				accountsToUpdate.add(new Account(Id = aId, RecordTypeId = customerRecordTypeId));
			}
		}
		
		if(!accountsToUpdate.isEmpty())
		{
			update accountsToUpdate;
		}
	}
	
	@Future(callout=true)
	public static void UpdateTop1000(String imisId, Boolean top1000)
	{
		ImisServiceConfiguration__c usersConfig = null;
		string jsonData = null;
		
		try
		{
			if(top1000 == null)
			{
				top1000 = false;
			}
			
			usersConfig = ImisServiceConfiguration__c.getvalues('Users Service');
			jsonData = '{ "imis": { "data": { "userdefinedtables": { "userdefinedtable": { "userdefinedtablename": "demographics", "top1000": "' + String.valueOf(top1000) + '" } } } } }';
			
			ImisService.put(usersConfig.EndPoint__c + imisId, jsonData, usersConfig.ClientToken__c);
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
		}
	}
}