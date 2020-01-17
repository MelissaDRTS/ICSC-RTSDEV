public with sharing class AccountSalesSummaryUtility 
{
	public static ID getParentRecordTypeId()
	{
		return Schema.SObjectType.Account_Sales_Summary__c.getRecordTypeInfosByName().get('Parent Sales Summary').getRecordTypeId();
	}
	
	public static ID getChildRecordTypeId()
	{
		return Schema.SObjectType.Account_Sales_Summary__c.getRecordTypeInfosByName().get('Child Sales Summary').getRecordTypeId();
	}
	
	public static void calculateParentTotals(Map<String, Set<ID>> yearToParentAccountIdsMap)
	{
		Map<String, Account_Sales_Summary__c> parentYearToAccountSalesSummaryMapToUpdate = new Map<String, Account_Sales_Summary__c>();
		Map<String, Account_Sales_Summary__c> parentYearToAccountSalesSummaryMap = new Map<String, Account_Sales_Summary__c>();
		AggregateResult[] childrenTotals = null;
		Set<ID> allParentAccountIds = new Set<ID>();
		List<Account_Sales_Summary__c> parentAccountSalesSummaries = null;
		
		String query = 'SELECT Year__c, Account_Name__r.ParentId parentId, SUM(Advertising__c) ads, SUM(Booth__c) booths, SUM(Certification_Fees__c) certs, SUM(Foundation_Fees__c) foundations, SUM(Fundraising__c) funds, ' +
				'SUM(Membership_Dues__c) memberships, SUM(PAC_Contributions__c) pacs, SUM(Refunds__c) refunds, SUM(Registration_Fees__c) registrations, SUM(Sponsorship__c) sponsors ' +
				'FROM Account_Sales_Summary__c WHERE Account_Name__r.ParentId != null AND (';
		String criteria = '';
		String criteriaParentRecord = '';
		ID parentRecordTypeId = getParentRecordTypeId();
								
		for(String year : yearToParentAccountIdsMap.keySet())
		{
			Set<ID> accountIds = yearToParentAccountIdsMap.get(year);
			
			if(!accountIds.isEmpty())
			{				
				criteria += '( Year__c = \'' + year + '\' AND Account_Name__r.ParentId in (' + converToQueryList(accountIds) + ')  ) OR ';
				criteriaParentRecord += '( Year__c = \'' + year + '\' AND Account_Name__c in (' + converToQueryList(accountIds) + ')  ) OR ';
			}
		}
		
		criteria = criteria.removeEnd(' OR ');		
		query += criteria + ') GROUP BY Year__c, Account_Name__r.ParentId';
		
		childrenTotals = Database.query(query);
		
		
		query = 'SELECT Id, Account_Name__c, Year__c FROM Account_Sales_Summary__c WHERE ';
		query += criteriaParentRecord.removeEnd(' OR ');
		
		parentAccountSalesSummaries = Database.query(query);
		
		//transform to map with key = year + account id
		for(Account_Sales_Summary__c a : parentAccountSalesSummaries)
		{
			parentYearToAccountSalesSummaryMap.put(a.Year__c + '_' + a.Account_Name__c, a);
		}
		
		for(AggregateResult ar : childrenTotals)
		{
			ID parentAccountId = (ID)ar.get('parentId');
			String year = (String)ar.get('Year__c');
			String key = year + '_' + parentAccountId;
			Account_Sales_Summary__c a = null;
			
			if(parentYearToAccountSalesSummaryMap.containsKey(key))
			{
				a = parentYearToAccountSalesSummaryMap.get(key);
			}
			else
			{
				a = new Account_Sales_Summary__c();
				a.Account_Name__c = parentAccountId;
				a.Year__c = year;
			}
			
			a.RecordTypeId = parentRecordTypeId;
			a.Children_Advertising__c = (Decimal)ar.get('ads');
			a.Children_Booth__c = (Decimal)ar.get('booths');
			a.Children_Certification_Fees__c = (Decimal)ar.get('certs');
			a.Children_Foundation_Fees__c = (Decimal)ar.get('foundations');
			a.Children_Fundraising__c = (Decimal)ar.get('funds');
			a.Children_Membership_Dues__c = (Decimal)ar.get('memberships');
			a.Children_PAC_Contributions__c = (Decimal)ar.get('pacs');
			a.Children_Refunds__c = (Decimal)ar.get('refunds');
			a.Children_Registration_Fees__c = (Decimal)ar.get('registrations');
			a.Children_Sponsorship__c = (Decimal)ar.get('sponsors');
			
			parentYearToAccountSalesSummaryMapToUpdate.put(key, a);
		}
		
		//set totals to zero for records with no children
		for(String key: parentYearToAccountSalesSummaryMap.keySet())
		{
			if(!parentYearToAccountSalesSummaryMapToUpdate.containsKey(key))
			{
				Account_Sales_Summary__c a = parentYearToAccountSalesSummaryMap.get(key);
				
				if(a != null)
				{
					a.RecordTypeId = parentRecordTypeId;
					a.Children_Advertising__c = a.Children_Booth__c = a.Children_Certification_Fees__c = a.Children_Foundation_Fees__c = a.Children_Fundraising__c = 
					a.Children_Membership_Dues__c = a.Children_PAC_Contributions__c = a.Children_Refunds__c = a.Children_Registration_Fees__c = a.Children_Sponsorship__c = 0;
					
					parentYearToAccountSalesSummaryMapToUpdate.put(key, a);
				}
			}
		}
		
		if(!parentYearToAccountSalesSummaryMapToUpdate.isEmpty())
		{
			upsert parentYearToAccountSalesSummaryMapToUpdate.values();
		}
	}
	
	public static Boolean validate(List<Account_Sales_Summary__c> newRecords, Map<String, Set<ID>> yearToAccountIdsMap)
	{
		List<Account_Sales_Summary__c> existingRecords = null;
		Set<String> keys = new Set<String>();
		String query = 'SELECT Account_Name__c, Year__c FROM Account_Sales_Summary__c WHERE ID != null AND (';
		Boolean valid = true;
		
		for(String year : yearToAccountIdsMap.keySet())
		{
			Set<ID> accountIds = yearToAccountIdsMap.get(year);
			
			if(!accountIds.isEmpty())
			{
				query += '( Year__c = \'' + year + '\' AND Account_Name__c in (' + converToQueryList(accountIds) + ')  ) OR ';
			}
		}
		
		query = query.removeEnd(' OR ') + ')';
		
		existingRecords = Database.query(query);
		
		for(Account_Sales_Summary__c a : existingRecords)
		{
			keys.add(a.Year__c + '_' + a.Account_Name__c);
		}
		
		for(Account_Sales_Summary__c a : newRecords)
		{
			if(keys.contains(a.Year__c + '_' + a.Account_Name__c))
			{
				a.addError('A record already exists for the selected account and year.');
				valid = false;
			}
		}
		
		return valid;
	}
	
	public static void setNames(List<Account_Sales_Summary__c> records, Set<Id> accountIds)
	{
		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id in: accountIds]);
		
		if(!accountMap.isEmpty())
		{
			for(Account_Sales_Summary__c r : records)
			{
				Account a = accountMap.get(r.Account_Name__c);
				
				if(a != null)
				{
					r.Name = r.Year__c + ' - ' + a.Name;
				}
			}
		}
	}
	
	private static String converToQueryList(Set<Id> ids)
	{
		string queryList = '';
		
		for(ID i : ids)
		{
			queryList += '\'' + i + '\' , ';
		}
		
		return queryList.removeEnd(' , ');
	}
	
}