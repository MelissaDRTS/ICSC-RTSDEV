/*
    Author: Mendel Guillaume    
    Description: iMIS name record returned by the REST API
*/
public with sharing class ImisAccount 
{
    public String id {get;set;}
    public String company {get;set;}
    public String status {get;set;}
    public String memberType {get;set;}
    public String address {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String zip {get;set;}
    public String country {get;set;}
    public String phone {get;set;}
    public String fax {get;set;}
    public Date paidthru {get;set;}
    public String primaryBusinessCode {get;set;}
    public String salesforceid {get;set;}
    
    public static void processLatestUpdatesFromImis()
    {
        Integer start = 0;
        Integer numberOfRecords = 200;
        DateTime lastModified = null;
        List<ImisAccount> imisAccounts = null;
        Map<ID,Account> sfAccountsMap = null;
        List<Account> sfAccounts = null;
        Map<String, Account> sfAccountByImisIdMap = new Map<String, Account>();
        Set<String> imisIds = new Set<String>();
        Set<ID> salesforceIds = new Set<ID>();
        ImisServiceConfiguration__c accountConfig = ImisServiceConfiguration__c.getvalues('Account Service');
        Map<String, ImisValidationTable__c> primaryTableEntries = ImisValidationTable__c.getAll();
        
        
        if(accountConfig != null)
        {
            lastModified = accountConfig.LastModified__c;
            
            if(accountConfig.StartingRow__c != null && accountConfig.StartingRow__c >= 0)
            {
                start = (Integer)accountConfig.StartingRow__c;
            }
            
            if(accountConfig.NumberOfRecords__c != null && accountConfig.NumberOfRecords__c >= 0)
            {
                numberOfRecords = (Integer)accountConfig.NumberOfRecords__c;
            }       
        
            imisAccounts = getAccountsFromImis(accountConfig.EndPoint__c, lastModified, start, numberOfRecords, accountConfig.ClientToken__c);
            
            if(imisAccounts != null && imisAccounts.size() > 0)
            {
                for(ImisAccount ia : imisAccounts)
                {
                    if(ia.salesforceId != null && ia.salesforceId != '')
                    {
                        try
                        {
                            salesforceIds.add((ID)ia.salesforceId);
                        }
                        catch(Exception e){}
                    }
                    
                    imisIds.add(ia.Id);                     
                }
                
                sfAccountsMap = new Map<ID, Account>([SELECT Id, iMIS_ID__c FROM Account WHERE iMIS_ID__c in: imisIds OR Id in: salesforceIds]);
                sfAccounts = sfAccountsMap.values();
                
                for(Account a : sfAccounts)
                {               
                    if(a.iMIS_ID__c != null && a.iMIS_ID__c != '')
                    {   Set<Account> vals = new Set<Account>(sfAccountByImisIdMap.values());
                        if(!vals.contains(a))
                        	sfAccountByImisIdMap.put(a.iMIS_ID__c, a);
                    }
                }
                
                for(ImisAccount ia : imisAccounts)
                {
                    Account sfa = sfAccountByImisIdMap.get(ia.id);
                    
                    if(sfa == null && ia.salesforceId != null && ia.salesforceId != '')
                    {
                        try
                        {
                            sfa = sfAccountsMap.get((Id)ia.salesforceId);
                            sfa.iMIS_ID__c = ia.id;
                        }
                        catch(Exception ex){}
                    }
                    
                    if(sfa == null)
                    {
                        sfa = new Account();
                        sfa.iMIS_ID__c = ia.id;
                        sfa.Name = ia.company;
                        sfa.Type = 'Company';
                        sfa.BillingCity = ia.city;
                        sfa.BillingCountry = ia.country;
                        sfa.BillingPostalCode = ia.zip;
                        sfa.BillingState = ia.state;
                        sfa.BillingStreet = ia.address;
                        sfa.Phone = ia.phone;
                        sfa.Fax = ia.fax;
                        
                        if(ia.primaryBusinessCode != null)
                        {
                            ImisValidationTable__c entry = primaryTableEntries.get('primary' + '_' + ia.primaryBusinessCode);
                            
                            if(entry != null)
                            {
                                sfa.Business_Type__c = entry.Description__c;
                            }
                            else
                            {
                                sfa.Business_Type__c = ia.primaryBusinessCode;
                            }
                        }
                    }
                    
                    sfa.Membership_Status__c = ia.status;
                    sfa.Membership_Type__c = ia.memberType;
                    sfa.Membership_Paid_Thru__c = ia.paidthru;
                    Set<Account> vals = new Set<Account>(sfAccountByImisIdMap.values());
                    if(!vals.contains(sfa))
                    	sfAccountByImisIdMap.put(sfa.iMIS_ID__c, sfa);
                }
                
                if(!sfAccountByImisIdMap.isEmpty())
                {
                    upsert sfAccountByImisIdMap.values();
                }
                
                //If number of returned accounts is less than the number of records per call, update the settings for the next call
                if(imisAccounts.size() < numberOfRecords)
                {
                    accountConfig.StartingRow__c = 1;
                    accountConfig.LastModified__c = DateTime.now();
                }
                else
                {
                    accountConfig.StartingRow__c += numberOfRecords;
                }
                
                update accountConfig;
            }
        }
    } 
        
    public static List<ImisAccount> getAccountsFromImis(String endPoint, DateTime lastModifiedDate, integer start, integer numberOfRecords, string token)
    {
        List<ImisAccount> accts = new List<ImisAccount>();
        
        accts = convertFromJson(ImisService.getAccountData(endPoint, lastModifiedDate, start, numberOfRecords, token));
        
        return accts;
    }
    
    private static List<ImisAccount> convertFromJson(string accountData)
    {
        List<ImisAccount> accts = new List<ImisAccount>();
        JSONParser parser = null;
        boolean skip = true;
            
        if(accountData != null && accountData != '')
        {
            parser = JSON.createParser(accountData);
            
            while (parser.nextToken() != null) 
            {
                String fieldName = parser.getText();
                if(fieldName == 'account')
                {
                    skip = false;
                }
                
                if(skip)
                {
                    continue;
                }
                    
                if(parser.getCurrentToken() == JSONToken.START_OBJECT)
                {
                    //System.debug('Start object: ' + fieldName);
                    try
                    {
                        ImisAccount a = (ImisAccount)parser.readValueAs(ImisAccount.class);
                        if(a.Id != null)
                        {
                        	accts.add(a);
                        }
                    }
                    catch(Exception ex)
                    {
                        system.debug(ex.getMessage());
                    }
                }
                else if(parser.getCurrentToken() == JSONToken.START_ARRAY)
                {
                    while(parser.nextToken() != null)
                    {
                        fieldName = parser.getText();
                                
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT)
                        {
                            ImisAccount a = (ImisAccount)parser.readValueAs(ImisAccount.class);
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
        
        return accts;
    }
}