/*
	Author: Mendel Guillaume	
	Description: iMIS sponsorship sales record returned by the REST API
*/
public with sharing class ImisSponsorshipSalesHistory 
{
	public String id {get;set;}
	public String code{get;set;}
	public String meetingtitle{get;set;}
	public Date meetingdate{get;set;}
	public String productcode{get;set;}
	public String functiontitle {get;set;}
	public Decimal quantity{get;set;}
	public Decimal amount {get;set;}
	public Date orderdate {get;set;}	
	
	
	public ImisSponsorshipSalesHistory()
	{
	}
	
	public static List<String> processDataFromImis()
	{
		ImisServiceConfiguration__c sponsorshipHistoryConfig = ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service');
		String year = String.valueOf(DateTime.now().year());
		
		if(sponsorshipHistoryConfig.Year__c != null && sponsorshipHistoryConfig.Year__c != '')
		{
			year = sponsorshipHistoryConfig.Year__c;
		}	
		
		return processDataFromImis(year);		
	}
	
	public static List<String> processDataFromImis(String year)
	{
		List<String> logLines = new List<String>();
		Integer start = 1;
		Integer numberOfRecords = 200;
		List<ImisSponsorshipSalesHistory> sponsorshipSales = null;
		List<iMIS_Sponsorship_Sales__c> sfSponsorshipSales = null;
		Map<String, iMIS_Sponsorship_Sales__c> sfServiceKeyToSponsorshipMap = new Map<String, iMIS_Sponsorship_Sales__c>();
		List<Show_Publications__c> sfShows = null;
		Map<String, Show_Publications__c> sfCodeToShowMap = new Map<String, Show_Publications__c>();
		Set<String> imisIds = new Set<String>();	
		Set<String> showCodes = new Set<String>();		
		ImisServiceConfiguration__c sponsorshipHistoryConfig = ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service');
		logLines.add('Sponsorship sales history configuration retrieved: '+sponsorshipHistoryConfig);
		List<Account> sfAccounts = null;
		Map<String, Account> sfAccountByImisIdMap = new Map<String, Account>();
		Map<String, iMIS_Sponsorship_Sales__c> sfSponsorshipSalesToSave = new Map<String, iMIS_Sponsorship_Sales__c>();
		Show_Publications__c defaultShow = null;
		
		if(sponsorshipHistoryConfig != null)
		{	
			if(sponsorshipHistoryConfig.StartingRow__c != null && sponsorshipHistoryConfig.StartingRow__c >= 0)
			{
				start = (Integer)sponsorshipHistoryConfig.StartingRow__c;
			}
			logLines.add('****** ImisSponsorshipSalesHistory.processDataFromImis() initialized with starting row: '+start);
			logLines.add('****** Using request endpoint: '+ImisService.getRequestUrl(sponsorshipHistoryConfig.EndPoint__c, year, start, sponsorshipHistoryConfig.ClientToken__c));
			String rawResponse = ImisService.getSponsorshipSalesHistory(sponsorshipHistoryConfig.EndPoint__c, year, start, sponsorshipHistoryConfig.ClientToken__c);
			/*logLines.add('****** Raw response: '+rawResponse);*/
			sponsorshipSales = convertFromJson(rawResponse);
			if(sponsorshipSales != null && sponsorshipSales.size() > 0)
			{
				logLines.add(sponsorshipSales.size()+' sponsorship sales records retrieved from iMis.');
				 
				for(ImisSponsorshipSalesHistory issh : sponsorshipSales)
				{
					imisIds.add(issh.Id);
					showCodes.add(issh.code);					
				}
				
				sfSponsorshipSales = [SELECT Id, Name, Service_Mapping_Key__c, Meeting_Title__c, Meeting_Date__c, Cost__c, Quantity__c, Transaction_Date__c, Type_of_Sponsorship_Purchased__c
				 						FROM iMIS_Sponsorship_Sales__c 
				 						WHERE Account_Name__r.iMIS_ID__c in: imisIds AND Year__c =: year];
				
				for(iMIS_Sponsorship_Sales__c b : sfSponsorshipSales)
				{
					sfServiceKeyToSponsorshipMap.put(b.Service_Mapping_Key__c.toLowerCase(), b);
				}
				
				sfAccounts = [SELECT Id, iMIS_ID__c FROM Account WHERE iMIS_ID__c in: imisIds];
				
				for(Account a : sfAccounts)
				{
					sfAccountByImisIdMap.put(a.iMIS_ID__c, a);
				}
				
				sfShows = [SELECT Id, iMIS_Meeting_Code_Sponsorship__c FROM Show_Publications__c WHERE iMIS_Meeting_Code_Sponsorship__c in: showCodes];
				
				for(Show_Publications__c s : sfShows)
				{
					sfCodeToShowMap.put(s.iMIS_Meeting_Code_Sponsorship__c, s);
				}
				
				for(ImisSponsorshipSalesHistory issh : sponsorshipSales)
				{
                    logLines.add('*** Processing ISSH ' + issh.Id);
					Account a = sfAccountByImisIdMap.get(issh.Id);
					if (a == null){
						logLines.add(' \t WARNING: No SF account found for iMis ID '+issh.Id);
					}
					if(a != null)
					{
						Show_Publications__c show = sfCodeToShowMap.get(issh.code);
						if(show == null)
						{
							logLines.add(' \t WARNING: No show found with SF code '+issh.code);
						}
						
						if(show != null)
						{
							logLines.add(' \t Show/publication '+show.Id+' found for sf code '+issh.code);	
							String key = (issh.productcode + '_' + issh.id + '_' + year).toLowerCase();
							iMIS_Sponsorship_Sales__c sponsorship = sfServiceKeyToSponsorshipMap.get(key);
							
							if(sponsorship == null)
							{
								logLines.add(' \t Sponsorship sale with service key '+key+' not found; creating it.');
								sponsorship = new iMIS_Sponsorship_Sales__c();
								sponsorship.Account_Name__c = a.Id;
								sponsorship.Show__c = show.Id;
								sponsorship.Year__c = year;
								sponsorship.Product_Code__c = issh.productcode;
							}else{
								logLines.add(' \t Sponsorship sale with service key '+key+' found: '+sponsorship.Name);
							}
							
							//Update only if neccessary
							if(sponsorship.Meeting_Title__c != issh.meetingtitle ||
								sponsorship.Meeting_Date__c != issh.meetingdate || 
								sponsorship.Cost__c != issh.amount || 
								sponsorship.Quantity__c != issh.quantity ||
								sponsorship.Transaction_Date__c != issh.orderdate ||
								sponsorship.Type_of_Sponsorship_Purchased__c != issh.functiontitle)
							{
								sponsorship.Meeting_Title__c = issh.meetingtitle;
								sponsorship.Meeting_Date__c = issh.meetingdate;
								sponsorship.Cost__c = issh.amount;
								sponsorship.Quantity__c = issh.quantity;
								sponsorship.Transaction_Date__c = issh.orderdate;
								sponsorship.Type_of_Sponsorship_Purchased__c = issh.functiontitle;
																
								sfSponsorshipSalesToSave.put(key, sponsorship);
							}
						}
					}
				}
				
				if(!sfSponsorshipSalesToSave.isEmpty())
				{
					upsert sfSponsorshipSalesToSave.values();
				}
				
				//If number of returned accounts is less than the number of records per call, update the settings for the next call
				if(sponsorshipSales.size() < numberOfRecords)
				{
					sponsorshipHistoryConfig.StartingRow__c = 1;
				}
				else
				{
					sponsorshipHistoryConfig.StartingRow__c += numberOfRecords - (start == 1 ? 1 : 0);
				}
				
				update sponsorshipHistoryConfig;
			}
		}
		return logLines;
	} 
		
	public static List<ImisSponsorshipSalesHistory> getRecordsFromImis(String endPoint, String year, Integer start, String token)
	{
		List<ImisSponsorshipSalesHistory> sponsorships = new List<ImisSponsorshipSalesHistory>();
		
		sponsorships = convertFromJson(ImisService.getSponsorshipSalesHistory(endPoint, year, start, token));
		
		return sponsorships;
	}
	
	private static List<ImisSponsorshipSalesHistory> convertFromJson(string sponsorshipData)
	{
		List<ImisSponsorshipSalesHistory> sponsorships = new List<ImisSponsorshipSalesHistory>();
		JSONParser parser = null;
            
        if(sponsorshipData != null && sponsorshipData != '')
        {
        	parser = JSON.createParser(sponsorshipData);
	        
	        while (parser.nextToken() != null) 
	        {
	        	String fieldName = parser.getText();
	                 
	            if(fieldName == 'meetings')
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
			                       	ImisSponsorshipSalesHistory b = (ImisSponsorshipSalesHistory)parser.readValueAs(ImisSponsorshipSalesHistory.class);
			                       				                       	
			                       	sponsorships.add(b);
			                    }
			                    else if(parser.getCurrentToken() == JSONToken.END_ARRAY)
			                    {
			                        break; 
			                    }
			                }
			            }
	            	}
	            	
	            	break;
	            }
	        }
        }
        
        return sponsorships;
	}
}