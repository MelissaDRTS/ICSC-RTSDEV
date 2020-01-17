/*
	Author: Mendel Guillaume	
	Description: iMIS booth sales record returned by the REST API
*/
public with sharing class ImisBoothSalesHistory 
{
	public String id {get;set;}
	public String code{get;set;}
	public String salestype{get;set;}
	public String description{get;set;}
	public Decimal quantity{get;set;}
	public Decimal cost {get;set;}
	public String boothcontact{get;set;}
	public String boothcontactemail{get;set;}
	public String boothnumber{get;set;}
	public Date orderdate {get;set;} //begin new table rows here
	public String ordernumber {get;set;}
	public Date entereddatetime {get;set;}
	public Date updateddatetime {get;set;}
	public String linenumber;

	public ImisBoothSalesHistory()
	{ 	}
	
	public static List<String> processDataFromImis()
	{
		ImisServiceConfiguration__c boothHistoryConfig = ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
		String year = String.valueOf(DateTime.now().year());
		
		if(boothHistoryConfig.Year__c != null && boothHistoryConfig.Year__c != '')
		{
			year = boothHistoryConfig.Year__c;
		}	
		
		return processDataFromImis(year);	
	}
	
	public static List<String> processDataFromImis(String year)
	{
		List<String> logLines = new List<String>();

		Integer start = 1;
		Integer numberOfRecords = 200;
		List<ImisBoothSalesHistory> boothSales = null;
		List<iMIS_Booth__c> sfBoothSales = null;
		Map<String, iMIS_Booth__c> sfServiceKeyToBoothMap = new Map<String, iMIS_Booth__c>();
		List<Show_Publications__c> sfShows = null;
		Map<String, Show_Publications__c> sfCodeToShowMap = new Map<String, Show_Publications__c>();
		Set<String> imisIds = new Set<String>();	
		Set<String> showCodes = new Set<String>();		
		ImisServiceConfiguration__c boothHistoryConfig = ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
		List<Account> sfAccounts = null;
		Map<String, Account> sfAccountByImisIdMap = new Map<String, Account>();
		Map<String, iMIS_Booth__c> sfBoothSalesToSave = new Map<String, iMIS_Booth__c>();
		Show_Publications__c defaultShow = null;
		
		if(boothHistoryConfig != null)
		{	
			if(boothHistoryConfig.StartingRow__c != null && boothHistoryConfig.StartingRow__c >= 0)
			{
				start = (Integer)boothHistoryConfig.StartingRow__c;
			}
			logLines.add('****** Processing data from iMis -- starting row '+start);
            logLines.add('****** Using request endpoint: '+ImisService.getRequestUrl(boothHistoryConfig.EndPoint__c, year, start, boothHistoryConfig.ClientToken__c));
			System.debug('before call');
			boothSales = getRecordsFromImis(boothHistoryConfig.EndPoint__c, year, start, boothHistoryConfig.ClientToken__c);
			System.debug('after call');
			logLines.add(boothSales.size()+' records returned from iMis');
			if(boothSales != null && boothSales.size() > 0)
			{
				for(ImisBoothSalesHistory ibsh : boothSales)
				{
					imisIds.add(ibsh.Id);
					showCodes.add(ibsh.code);
				}
				
				sfBoothSales = [SELECT Id, Primary_Key__c, Service_Mapping_Key__c, Booth_Contact__c, Booth_Contact_Email__c, Booth_No__c, Cost__c, 
										Quantity__c, Transaction_Date__c, Type_of_Booth_Purchased__c 
										FROM iMIS_Booth__c 
										WHERE Account_Name__r.iMIS_ID__c in: imisIds AND Year__c =: year];
				
				for(iMIS_Booth__c b : sfBoothSales)
				{
					//sfServiceKeyToBoothMap.put(b.Service_Mapping_Key__c.toLowerCase(), b);
					sfServiceKeyToBoothMap.put(b.Primary_Key__c, b);
				}
				
				sfAccounts = [SELECT Id, iMIS_ID__c FROM Account WHERE iMIS_ID__c in: imisIds];
				
				for(Account a : sfAccounts)
				{
					sfAccountByImisIdMap.put(a.iMIS_ID__c, a);
				}
				
				sfShows = [SELECT Id, iMIS_Meeting_Code_Booth__c FROM Show_Publications__c WHERE iMIS_Meeting_Code_Booth__c in: showCodes];
				
				for(Show_Publications__c s : sfShows)
				{
					sfCodeToShowMap.put(s.iMIS_Meeting_Code_Booth__c, s);
				}
				
				for(ImisBoothSalesHistory ibsh : boothSales)
				{
					logLines.add('*** Processing IBSH '+ibsh.Id);
					Account a = sfAccountByImisIdMap.get(ibsh.Id);
					if (a == null){
						String warningText = 'WARNING: Account with iMis ID '+ibsh.Id+' not found!';
						System.debug(warningText);
						logLines.add(warningText);
					}
					else if(a != null)
					{
						logLines.add('Account '+a.Id+' found for iMis ID '+ibsh.Id);
						Show_Publications__c show = sfCodeToShowMap.get(ibsh.code);
						
						if(show == null)
						{
							String warningText = 'WARNING: No SF show found for Show Code '+ibsh.code;
							System.debug(warningText);
							logLines.add(warningText);

						}
						else if(show != null)
						{
							logLines.add('Show '+show.Id+' found for Show Code '+ibsh.code);
							String key = (ibsh.code + '_' + ibsh.salestype + '_' + ibsh.id + '_' + year).toLowerCase();
							String primary = (ibsh.id +'-'+ibsh.ordernumber + '-' + ibsh.linenumber);
							logLines.add('SF service key: '+key);
							//iMIS_Booth__c booth = sfServiceKeyToBoothMap.get(key);
							iMIS_Booth__c booth = sfServiceKeyToBoothMap.get(primary);
							//in case multiple records from imis point to the same key
							if (booth != null){
								//logLines.add('Existing booth sales record found for service key '+key);
								logLines.add('Existing booth sales record found for service key '+primary);
							}
							if(booth == null)
							{
								booth = sfBoothSalesToSave.get(primary); //sfBoothSalesToSave.get(key);
							}
							
							if(booth == null)
							{
								//logLines.add('No booth sales record found for service key '+key+', Creating one now');
								logLines.add('No booth sales record found for service key '+primary+', Creating one now');
								booth = new iMIS_Booth__c();
								booth.Account_Name__c = a.Id;
								booth.Show__c = show.Id;
								booth.Year__c = year;
								booth.Sale_Type__c = ibsh.salestype;
								booth.Order_Date__c = ibsh.orderdate;
								booth.Order_Number__c = ibsh.ordernumber;
								booth.Entered_Date__c = ibsh.entereddatetime;
								booth.Last_Updated_Date__c = ibsh.updateddatetime;
								booth.Line_Number__c = ibsh.linenumber;
								booth.Primary_Key__c = primary;
							}
							
							//update records only if data was updated
							if(booth.Booth_Contact__c != ibsh.boothcontact ||
								booth.Booth_Contact_Email__c != ibsh.boothcontactemail ||
								booth.Booth_No__c != ibsh.boothnumber ||
								booth.Cost__c != ibsh.cost ||
								booth.Quantity__c != ibsh.quantity ||
								booth.Transaction_Date__c != ibsh.orderdate ||
								booth.Primary_Key__c == null ||
								booth.Type_of_Booth_Purchased__c != ibsh.description)
							{
								booth.Booth_Contact__c = ibsh.boothcontact;
								booth.Booth_Contact_Email__c = ibsh.boothcontactemail == null ? ibsh.boothcontactemail : ibsh.boothcontactemail.replace('@@', '@');
								booth.Booth_No__c = ibsh.boothnumber;
								booth.Cost__c = ibsh.cost;
								booth.Quantity__c = ibsh.quantity;
								booth.Transaction_Date__c = ibsh.orderdate;
								booth.Type_of_Booth_Purchased__c = ibsh.description;
								booth.Primary_Key__c = primary;								
								//sfBoothSalesToSave.put(key, booth);
								sfBoothSalesToSave.put(primary, booth);
							}
						}
					}
				}
				
				if(!sfBoothSalesToSave.isEmpty())
				{
					// set savepoint so we can roll back if we need to
					System.Savepoint sp = Database.setSavepoint();
					// using allornone false so that it doesn't throw an exception
					List<Database.UpsertResult> results = Database.upsert(sfBoothSalesToSave.values(), false);
					// error tracker so we can rollback if need be
					//Boolean errors = false;
					List<String> errors = new List<String>();
					for(Integer i = 0; i < results.size(); i++)
					{
						if(!results[i].isSuccess())
						{
							for(Database.Error error : results[i].getErrors())
							{
								errors.add('Something went wrong with the iMIS record ID ' +
										sfBoothSalesToSave.values()[i].Primary_Key__c + ' : ' +
										error.getStatusCode() + ' - ' + error.getMessage());
							}
							List<String> recordInfo = new List<String>{'iMIS Record information: ',
									'--id: ' + sfBoothSalesToSave.values()[i].Primary_Key__c,
									'--salestype: ' + sfBoothSalesToSave.values()[i].Sale_Type__c,
									'--description: ' + sfBoothSalesToSave.values()[i].Type_of_Booth_Purchased__c,
									'--quantity: ' + sfBoothSalesToSave.values()[i].Quantity__c,
									'--cost: ' + sfBoothSalesToSave.values()[i].Cost__c,
									'--boothcontact: ' + sfBoothSalesToSave.values()[i].Booth_Contact__c,
									'--boothcontactemail: ' + sfBoothSalesToSave.values()[i].Booth_Contact_Email__c,
									'--boothnumber: ' + sfBoothSalesToSave.values()[i].Booth_No__c,
									'--orderdate: ' + sfBoothSalesToSave.values()[i].Transaction_Date__c};
							errors.addAll(recordInfo);
						}
					}
					if (errors.size() > 0) // rollback if we hit any errors
					{
						Database.rollback(sp);
						throw new ImisServiceException(String.join(errors, '\r\n'));
					}
				}
				//If number of returned accounts is less than the number of records per call, update the settings for the next call
				if(boothSales.size() < numberOfRecords)
				{
                    if(boothHistoryConfig != null)
						boothHistoryConfig.StartingRow__c = 1;
				}
				else
				{
					boothHistoryConfig.StartingRow__c += numberOfRecords - (start == 1 ? 1 : 0);
				}
				update boothHistoryConfig;
			}
		}
		System.debug(logLines);
		return logLines;
	} 
	
	public static List<ImisBoothSalesHistory> getRecordsFromImis(String endPoint, String year, Integer start, String token)
	{
		List<ImisBoothSalesHistory> booths = new List<ImisBoothSalesHistory>();
		booths = convertFromJson(ImisService.getBoothSalesHistory(endPoint, year, start, token));
		return booths;
	}
	
	private static List<ImisBoothSalesHistory> convertFromJson(string boothData)
	{
		List<ImisBoothSalesHistory> booths = new List<ImisBoothSalesHistory>();
		JSONParser parser = null;
            
        if(boothData != null && boothData != '')
        {
        	parser = JSON.createParser(boothData);
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
			                       	ImisBoothSalesHistory b = (ImisBoothSalesHistory)parser.readValueAs(ImisBoothSalesHistory.class);
			                       				                       	
			                       	booths.add(b);
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
        return booths;
	}

//Only for use in anonymous apex to test the endpoint is functioning correctly
	public static void anonymousImisCall(){
		String endpoint = 'http://imisapi.icsc.org/salesforce/booth/2016';
		HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = null;
        String body = null;
        
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Client-Token', '9F565F0D-D1AD-4BF6-8C0B-08209CBBD1B2');
		req.setTimeout(20000);
        res = http.send(req);
        system.debug(res.getBody());

	}

}