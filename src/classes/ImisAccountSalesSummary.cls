/*
	Author: Mendel Guillaume	
	Description: iMIS sales summary record returned by the REST API
*/
public with sharing class ImisAccountSalesSummary 
{
	public String id {get;set;}
	public Decimal fundraising {get;set;}
	public Decimal dues {get;set;}
	public Decimal pac {get;set;}
	public Decimal certification{get;set;}
	public Decimal registration{get;set;}
	public Decimal foundation{get;set;}
	public Decimal refunds {get;set;} 
	
	public static void processDataFromImis()
	{
		ImisServiceConfiguration__c salesSummaryConfig = ImisServiceConfiguration__c.getvalues('Account Sales Summary Service');
		String year = String.valueOf(DateTime.now().year());
		
		if(salesSummaryConfig.Year__c != null && salesSummaryConfig.Year__c != '')
		{
			year = salesSummaryConfig.Year__c;
		}	
		
		processDataFromImis(year);
	}
	
	public static void processDataFromImis(String year)
	{
		Integer start = 1;
		Integer numberOfRecords = 200;
		List<ImisAccountSalesSummary> salesSummaries = null;
		List<Account_Sales_Summary__c> sfSalesSummary = null;
		Map<String, Account_Sales_Summary__c> sfSalesSummaryByImisIdMap = new Map<String, Account_Sales_Summary__c>();
		Set<String> imisIds = new Set<String>();
		ImisServiceConfiguration__c salesSummaryConfig = ImisServiceConfiguration__c.getvalues('Account Sales Summary Service');
		List<Account> sfAccounts = null;
		Map<String, Account> sfAccountByImisIdMap = new Map<String, Account>();
		Id parentAccountRecordTypeId = AccountUtility.getParentCustomerRecordTypeId();
		Id parentSalesSummaryRecordTypeId = AccountSalesSummaryUtility.getParentRecordTypeId();
		Id salesSummaryRecordTypeId = AccountSalesSummaryUtility.getChildRecordTypeId();
		
		if(salesSummaryConfig != null)
		{	
			if(salesSummaryConfig.StartingRow__c != null && salesSummaryConfig.StartingRow__c >= 0)
			{
				start = (Integer)salesSummaryConfig.StartingRow__c;
			}
			
			salesSummaries = getRecordsFromImis(salesSummaryConfig.EndPoint__c, year, start, salesSummaryConfig.ClientToken__c);
			
			if(salesSummaries != null && salesSummaries.size() > 0)
			{
				for(ImisAccountSalesSummary ia : salesSummaries)
				{
					imisIds.add(ia.Id);
				}
				
				sfSalesSummary = [SELECT Id, Account_Name__r.iMIS_ID__c, Account_Name__r.RecordType.Id, Certification_Fees__c, Foundation_Fees__c, Fundraising__c,
										Membership_Dues__c, PAC_Contributions__c, Refunds__c, Registration_Fees__c, RecordTypeId 
									FROM Account_Sales_Summary__c 
									WHERE Account_Name__r.iMIS_ID__c in: imisIds AND Year__c =: year];
				
				for(Account_Sales_Summary__c a : sfSalesSummary)
				{
					sfSalesSummaryByImisIdMap.put(a.Account_Name__r.iMIS_ID__c, a);
				}
				
				//Get account ids for accounts that don't have a sales summary entry for the given year
				sfAccounts = [SELECT Id, iMIS_ID__c, RecordType.Id FROM Account WHERE iMIS_ID__c in: imisIds AND iMIS_ID__c NOT in: sfSalesSummaryByImisIdMap.keySet()];
				
				for(Account a : sfAccounts)
				{
					sfAccountByImisIdMap.put(a.iMIS_ID__c, a);
				}
				
				for(ImisAccountSalesSummary iass : salesSummaries)
				{
					string accountRecordTypeId = null;
					string recordTypeId = null;
					Account_Sales_Summary__c sfss = sfSalesSummaryByImisIdMap.get(iass.id);
					
					if(sfss == null)
					{
						Account sfa = sfAccountByImisIdMap.get(iass.id);
					
						//If account exists, create a sales summary record for that year
						if(sfa != null)
						{
							sfss = new Account_Sales_Summary__c();
							sfss.Year__c = year;
							sfss.Account_Name__c = sfa.Id;
							
							accountRecordTypeId = sfa.RecordType.Id;
						}
					}
					else
					{
						accountRecordTypeId = sfss.Account_Name__r.RecordType.Id;
					}
					
					if(accountRecordTypeId == parentAccountRecordTypeId)
					{
						recordTypeId = parentSalesSummaryRecordTypeId;
					}
					else
					{
						recordTypeId = salesSummaryRecordTypeId;
					}
					
					//Update only if neccessary
					if(sfss != null && (sfss.Certification_Fees__c != iass.certification || sfss.Foundation_Fees__c != iass.foundation || sfss.Fundraising__c != iass.fundraising ||
						sfss.Membership_Dues__c != iass.dues || sfss.PAC_Contributions__c != iass.pac || sfss.Refunds__c != iass.refunds || sfss.Registration_Fees__c != iass.registration || 
						sfss.RecordTypeId != recordTypeId))
					{
						
						sfss.RecordTypeId = recordTypeId;
						sfss.Certification_Fees__c = iass.certification;
						sfss.Foundation_Fees__c = iass.foundation;
						sfss.Fundraising__c = iass.fundraising;
						sfss.Membership_Dues__c = iass.dues;
						sfss.PAC_Contributions__c = iass.pac;
						sfss.Refunds__c = iass.refunds;
						sfss.Registration_Fees__c = iass.registration;
						
						sfSalesSummaryByImisIdMap.put(iass.Id, sfss);
						
					}
				}
				
				if(!sfSalesSummaryByImisIdMap.isEmpty())
				{
					upsert sfSalesSummaryByImisIdMap.values();
				}
				
				//If number of returned accounts is less than the number of records per call, update the settings for the next call
				if(salesSummaries.size() < numberOfRecords)
				{
					salesSummaryConfig.StartingRow__c = 1;
				}
				else
				{
					salesSummaryConfig.StartingRow__c += numberOfRecords - (start == 1 ? 1 : 0);
				}
				
				update salesSummaryConfig;
			}
		}
	} 
	
	public static List<ImisAccountSalesSummary> getRecordsFromImis(String endPoint, String year, Integer start, string token)
	{
		List<ImisAccountSalesSummary> accts = new List<ImisAccountSalesSummary>();
		
		accts = convertFromJson(ImisService.getAccountSalesSummaryData(endPoint, year, start, token));
		
		return accts;
	}
	
	private static List<ImisAccountSalesSummary> convertFromJson(string accountData)
	{
		List<ImisAccountSalesSummary> accts = new List<ImisAccountSalesSummary>();
		JSONParser parser = null;
            
        if(accountData != null && accountData != '')
        {
        	parser = JSON.createParser(accountData);
	        
	        while (parser.nextToken() != null) 
	        {
	        	String fieldName = parser.getText();
	                
	            if(fieldName == 'summary')
	            {
	            	while(parser.nextToken() != null)
	            	{
			            if(parser.getCurrentToken() == JSONToken.START_ARRAY)
			            {
			                while(parser.nextToken() != null)
			                {
			                    //fieldName = parser.getText();
			                            
			                    if(parser.getCurrentToken() == JSONToken.START_OBJECT)
			                    {
			                       	ImisAccountSalesSummary a = (ImisAccountSalesSummary)parser.readValueAs(ImisAccountSalesSummary.class);
			                       				                    				                       	
			                       	accts.add(a);
			                    }
			                    else if(parser.getCurrentToken() == JSONToken.END_ARRAY)
			                    {
			                        break; 
			                    }
			                }
			            }
	            	}
	            }
	        }
        }
        
        return accts;
	}
}