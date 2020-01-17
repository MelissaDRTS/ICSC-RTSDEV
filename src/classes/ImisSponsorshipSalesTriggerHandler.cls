public with sharing class ImisSponsorshipSalesTriggerHandler 
{
	static final boolean enableConversionToOpportunity = false;

	public static void onAfterInsert(Map<Id, iMIS_Sponsorship_Sales__c> newRecordMap)
	{
		List<iMIS_Sponsorship_Sales__c> newRecords = newRecordMap.values();
		Set<String> keys = new Set<String>();
		List<iMIS_Sponsorship_Sales__c> convertToOpportunity = new List<iMIS_Sponsorship_Sales__c>();

		for(iMIS_Sponsorship_Sales__c ash : newRecords)
		{
			if(ash.Cost__c != null && ash.Cost__c != 0)
			{
				keys.add(ash.Key__c);
			}
			if (ash.Opportunity__c == null) convertToOpportunity.add(ash);
		}
		
		if(!keys.isEmpty())
		{
			updateAccountSalesSummary(keys);
		}
		if(!convertToOpportunity.isEmpty() && enableConversionToOpportunity){
			Map<Id,String> accountIdToBillingStateMap = ImisSponsorshipSalesConverter.getAccountIdToBillingStateMap(newRecords);
			ImisSponsorshipSalesConverter.insertOpportunitiesWithLineItems(convertToOpportunity,accountIdToBillingStateMap);
		}
	}
	
	public static void onAfterUpdate(Map<Id, iMIS_Sponsorship_Sales__c> newRecordMap, Map<Id, iMIS_Sponsorship_Sales__c> oldRecordMap)
	{
		List<iMIS_Sponsorship_Sales__c> newRecords = newRecordMap.values();
		Set<String> keys = new Set<String>();
		
		for(iMIS_Sponsorship_Sales__c ash : newRecords)
		{
			iMIS_Sponsorship_Sales__c old = oldRecordMap.get(ash.Id);
			
			//Update if amount, year or account changed (key = account + year)
			if(ash.Cost__c != old.Cost__c || ash.Key__c != old.Key__c)
			{
				keys.add(ash.Key__c);
				
				if(ash.Key__c != old.Key__c)
				{
					keys.add(old.Key__c);
				}
			}
		}
		
		if(!keys.isEmpty())
		{
			updateAccountSalesSummary(keys);
		}
	}
	
	public static void onAfterDelete(Map<Id, iMIS_Sponsorship_Sales__c> oldRecordMap)
	{
		List<iMIS_Sponsorship_Sales__c> records = oldRecordMap.values();
		Set<String> keys = new Set<String>();
		
		for(iMIS_Sponsorship_Sales__c ash : records)
		{
			if(ash.Cost__c != null && ash.Cost__c != 0)
			{
				keys.add(ash.Key__c);
			}
		}
		
		if(!keys.isEmpty())
		{
			updateAccountSalesSummary(keys);
		}
	}
	
	public static void onAfterUndelete(Map<Id, iMIS_Sponsorship_Sales__c> newRecordMap)
	{
		List<iMIS_Sponsorship_Sales__c> records = newRecordMap.values();
		
		Set<String> keys = new Set<String>();
		
		for(iMIS_Sponsorship_Sales__c ash : records)
		{
			if(ash.Cost__c != null && ash.Cost__c != 0)
			{
				keys.add(ash.Key__c);
			}
		}
		
		if(!keys.isEmpty())
		{
			updateAccountSalesSummary(keys);
		}
		
	}
	
	public static void updateAccountSalesSummary(Set<String> keys)
	{
		AggregateResult[] salesHistoryRollUps = [SELECT Account_Name__c, Year__c, SUM(Cost__c) cost 
													FROM iMIS_Sponsorship_Sales__c 
													WHERE Key__c in :keys
													GROUP BY Account_Name__c, Year__c];
		List<Account_Sales_Summary__c> salesSummaries = [SELECT Id, Account_Name__c, Year__c, Key__c FROM Account_Sales_Summary__c WHERE Key__c in :keys];
		Map<String, Account_Sales_Summary__c> keyToSalesSummaryMap = new Map<String, Account_Sales_Summary__c>();
		Map<String, Account_Sales_Summary__c> keyToSalesSummaryToUpdateMap = new Map<String, Account_Sales_Summary__c>();
		
		for(Account_Sales_Summary__c a : salesSummaries)
		{
			keyToSalesSummaryMap.put(a.Key__c, a);
		}
		
		for(AggregateResult ar : salesHistoryRollUps)
		{
			Id accountId = (ID) ar.get('Account_Name__c');
			String year = (String) ar.get('Year__c');
			Decimal cost = (Decimal) ar.get('cost');
			String key = accountId + '_' + year;
			Account_Sales_Summary__c a = keyToSalesSummaryMap.get(key);
			
			if(a == null)
			{
				a = new Account_Sales_Summary__c();
				a.Account_Name__c = accountId;
				a.Year__c = year;
			}	
			
			a.Sponsorship__c = cost;			
			keyToSalesSummaryToUpdateMap.put(key, a);		
		}
		
		//Set to zero if not found in update map
		for(String key : keys)
		{
			if(!keyToSalesSummaryToUpdateMap.containsKey(key))
			{
				Account_Sales_Summary__c a = keyToSalesSummaryMap.get(key);
				
				if(a != null)
				{	
					a.Sponsorship__c = 0;				
					keyToSalesSummaryToUpdateMap.put(key, a);
				}	
			}
		}
		
		if(!keyToSalesSummaryToUpdateMap.isEmpty())
		{
			upsert keyToSalesSummaryToUpdateMap.values();
		}
	}
}