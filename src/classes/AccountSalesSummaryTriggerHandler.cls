public with sharing class AccountSalesSummaryTriggerHandler 
{
    @TestVisible private static boolean run = true;
    
    public static void onBeforeInsert(List<Account_Sales_Summary__c> newRecords)
    {
        Map<String, Set<ID>> yearToAccountIdsMap = new Map<String, Set<ID>>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Account_Sales_Summary__c a : newRecords)
        {
            Set<ID> yearAccountIds = new Set<ID>();
                
            if(yearToAccountIdsMap.containsKey(a.Year__c))
            {
                yearAccountIds = yearToAccountIdsMap.get(a.Year__c);
            }
            
            yearAccountIds.add(a.Account_Name__c);
            
            yearToAccountIdsMap.put(a.Year__c, yearAccountIds);       
            
            accountIds.add(a.Account_Name__c);  
        }
        
        if(!yearToAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.validate(newRecords, yearToAccountIdsMap);
        }
        
        AccountSalesSummaryUtility.setNames(newRecords, accountIds);
    }
    
    public static void onBeforeUpdate(Map<Id, Account_Sales_Summary__c> newRecordMap, Map<Id, Account_Sales_Summary__c> oldRecordMap)
    {
        List<Account_Sales_Summary__c> records = newRecordMap.values();
        Map<String, Set<ID>> yearToAccountIdsMap = new Map<String, Set<ID>>();
        
        for(Account_Sales_Summary__c a : records)
        { 
            Account_Sales_Summary__c old = oldRecordMap.get(a.Id);
            
            if(a.Year__c != old.Year__c)
            {
                Set<ID> accountIds = new Set<ID>();
                    
                if(yearToAccountIdsMap.containsKey(a.Year__c))
                {
                    accountIds = yearToAccountIdsMap.get(a.Year__c);
                }
                
                accountIds.add(a.Account_Name__c);
                
                yearToAccountIdsMap.put(a.Year__c, accountIds); 
            }       
        }
        
        if(!yearToAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.validate(records, yearToAccountIdsMap);
        }
    }
    
    public static void onAfterInsert(Map<Id, Account_Sales_Summary__c> newRecordMap) 
    {
        List<Account_Sales_Summary__c> records = newRecordMap.values();
        Map<String, Set<ID>> yearToParentAccountIdsMap = new Map<String, Set<ID>>();
        Map<String, Set<ID>> yearToAccountIdsMap = new Map<String, Set<ID>>();
        
        for(Account_Sales_Summary__c a : records)
        {           
            //Calculate total if parent account is not null and a value other then 0 was entered
            if(a.Parent_Account__c != null && (a.Advertising__c != 0 || a.Booth__c != 0 || a.Certification_Fees__c != 0 || a.Foundation_Fees__c != 0
                || a.Fundraising__c != 0 || a.Membership_Dues__c != 0 || a.PAC_Contributions__c != 0 || a.Refunds__c != 0 || a.Registration_Fees__c != 0 || a.Sponsorship__c != 0))
            {
                Set<ID> parentAccountIds = new Set<ID>();
                
                if(yearToParentAccountIdsMap.containsKey(a.Year__c))
                {
                    parentAccountIds = yearToParentAccountIdsMap.get(a.Year__c);
                }
                
                if(a.Parent_Account__c != null)
                {
                    parentAccountIds.add(a.Parent_Account__c);
                }
                                
                yearToParentAccountIdsMap.put(a.Year__c, parentAccountIds);
            }
        }
                
        if(!yearToParentAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.calculateParentTotals(yearToParentAccountIdsMap);
        }
    }
    
    public static void onAfterUpdate(Map<Id, Account_Sales_Summary__c> newRecordMap, Map<Id, Account_Sales_Summary__c> oldRecordMap)
    {
        List<Account_Sales_Summary__c> records = newRecordMap.values();
        Map<String, Set<ID>> yearToParentAccountIdsMap = new Map<String, Set<ID>>();
        
        for(Account_Sales_Summary__c a : records)
        {
            Account_Sales_Summary__c old = oldRecordMap.get(a.Id);
            
            if(a.Parent_Account__c == null && old.Parent_Account__c == null)
            {
            	continue;
            }
            
            //Calculate total if parent account is not null and a value was changed
            if(a.Year__c != old.Year__c || a.Parent_Account__c != old.Parent_Account__c || a.Advertising__c != old.Advertising__c || a.Booth__c != old.Booth__c || 
                    a.Certification_Fees__c != old.Certification_Fees__c || a.Foundation_Fees__c != old.Foundation_Fees__c || a.Fundraising__c != old.Fundraising__c || 
                    a.Membership_Dues__c != old.Membership_Dues__c || a.PAC_Contributions__c != old.PAC_Contributions__c || a.Refunds__c != old.Refunds__c || 
                    a.Registration_Fees__c != old.Registration_Fees__c || a.Sponsorship__c != old.Sponsorship__c)
            {
                Set<ID> parentAccountIds = new Set<ID>(); 
                
                if(yearToParentAccountIdsMap.containsKey(a.Year__c))
                {
                    parentAccountIds = yearToParentAccountIdsMap.get(a.Year__c);
                }
                
                if(a.Parent_Account__c != null)
                {
                    parentAccountIds.add(a.Parent_Account__c);
                }
                                
                if(old.Parent_Account__c != null && old.Parent_Account__c != a.Parent_Account__c)
                {
                    parentAccountIds.add(old.Parent_Account__c);
                }
                
                yearToParentAccountIdsMap.put(a.Year__c, parentAccountIds);
                
                if(old.Year__c != a.Year__c)
                {
                    Set<ID> pIds = new Set<ID>();
                    System.debug('New Year');
                    
                    if(yearToParentAccountIdsMap.containsKey(old.Year__c))
                    {
                        pIds = yearToParentAccountIdsMap.get(old.Year__c);
                    }
                    
                    if(a.Parent_Account__c != null)
                    {
                        pIds.add(a.Parent_Account__c);
                        System.debug('Added Account For Old Year');
                    }
                                            
                    if(old.Parent_Account__c != null && old.Parent_Account__c != a.Parent_Account__c)
                    {
                        pIds.add(old.Parent_Account__c);
                    }
                    
                    yearToParentAccountIdsMap.put(old.Year__c, pIds);
                }
            }
        }
                
        if(!yearToParentAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.calculateParentTotals(yearToParentAccountIdsMap);
        }       
    }
    
    public static void onAfterDelete(Map<Id, Account_Sales_Summary__c> oldRecordMap)
    {
        List<Account_Sales_Summary__c> records = oldRecordMap.values();
        Map<String, Set<ID>> yearToParentAccountIdsMap = new Map<String, Set<ID>>();
        
        for(Account_Sales_Summary__c a : records)
        {
            //Calculate total if parent account is not null and a value other then 0 was entered
            if(a.Parent_Account__c != null && (a.Advertising__c != 0 || a.Booth__c != 0 || a.Certification_Fees__c != 0 || a.Foundation_Fees__c != 0
                || a.Fundraising__c != 0 || a.Membership_Dues__c != 0 || a.PAC_Contributions__c != 0 || a.Refunds__c != 0 || a.Registration_Fees__c != 0 || a.Sponsorship__c != 0))
            {
                Set<ID> parentAccountIds = new Set<ID>();
                
                if(yearToParentAccountIdsMap.containsKey(a.Year__c))
                {
                    parentAccountIds = yearToParentAccountIdsMap.get(a.Year__c);
                }
                
                if(a.Parent_Account__c != null)
                {
                    parentAccountIds.add(a.Parent_Account__c);
                }
                
                yearToParentAccountIdsMap.put(a.Year__c, parentAccountIds);
            }
        }
                
        if(!yearToParentAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.calculateParentTotals(yearToParentAccountIdsMap);
        }       
    }
    
    public static void onAfterUndelete(Map<Id, Account_Sales_Summary__c> newRecordMap)
    {
        List<Account_Sales_Summary__c> records = newRecordMap.values();
        Map<String, Set<ID>> yearToParentAccountIdsMap = new Map<String, Set<ID>>();
        
        for(Account_Sales_Summary__c a : records)
        {
            //Calculate total if parent account is not null and a value other then 0 was entered
            if(a.Parent_Account__c != null && (a.Advertising__c != 0 || a.Booth__c != 0 || a.Certification_Fees__c != 0 || a.Foundation_Fees__c != 0
                || a.Fundraising__c != 0 || a.Membership_Dues__c != 0 || a.PAC_Contributions__c != 0 || a.Refunds__c != 0 || a.Registration_Fees__c != 0 || a.Sponsorship__c != 0))
            {
                Set<ID> parentAccountIds = new Set<ID>();
                
                if(yearToParentAccountIdsMap.containsKey(a.Year__c))
                {
                    parentAccountIds = yearToParentAccountIdsMap.get(a.Year__c);
                }
                
                if(a.Parent_Account__c != null)
                {
                    parentAccountIds.add(a.Parent_Account__c);
                }
                
                yearToParentAccountIdsMap.put(a.Year__c, parentAccountIds);
            }
        }
                
        if(!yearToParentAccountIdsMap.isEmpty())
        {
            AccountSalesSummaryUtility.calculateParentTotals(yearToParentAccountIdsMap);
        }               
    }
        
    /*public static boolean runOnce()
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
    }*/
}