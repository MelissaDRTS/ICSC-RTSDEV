public class OpportunityTriggerHandler 
{
    private static Set<Id> sponsorshipPackageIds = null;
    private static Set<Id> showIds = null;
    
    public static void onBeforeDelete(Map<Id, Opportunity> oldRecordMap)
    {
        List<Opportunity> records = oldRecordMap.values();
        
        //Build list for on after delete
        sponsorshipPackageIds = getSponsorshipPackageIdSet(oldRecordMap.keySet());
        showIds = getShowIdsFromLineItem(oldRecordMap.keySet());  //get values from the old Record Map and store them
    }
    
    public static void onBeforeUpdate(Map<Id, Opportunity> newRecordMap, Map<Id, Opportunity> oldRecordMap)
    {
        List<Opportunity> newRecords = newRecordMap.values();
        Set<ID> closedWonOppIds = new Set<ID>();
        
        for(Opportunity o : newRecords)
        {
            Opportunity old = oldRecordMap.get(o.Id);
            
            if(o.StageName == 'Closed Won' && o.StageName != old.StageName)
            {
                closedWonOppIds.add(o.Id);
            }
        }
        
        validatePackageAvailability(newRecordMap, closedWonOppIds);
    }
    
    public static void onAfterUpdate(Map<Id, Opportunity> newRecordMap, Map<Id, Opportunity> oldRecordMap)
    {
        List<Opportunity> newRecords = newRecordMap.values();
        Set<ID> closedWonOppIds = new Set<ID>();
        Set<ID> sponsorshipOppIds = new Set<ID>();
        Set<ID> closedOppIds = new Set<ID>();  
        Set<ID> wonOppIds = new Set<ID>();
        Set<ID> wonOppAccountIds = new Set<ID>();  
        
        for(Opportunity o : newRecords)
        {
            Opportunity old = oldRecordMap.get(o.Id);
            
            if(o.IsClosed && o.IsClosed != old.IsClosed)  //if the opp has changed to closed, add its id to the set
            {
                closedOppIds.add(o.Id);
            }
            
            if(o.IsClosed != old.IsClosed && o.IsWon != old.IsWon)
            {
                sponsorshipOppIds.add(o.Id);
            }
            
            if(o.stageName == 'Closed Won' && o.StageName != old.StageName)
            {
                closedWonOppIds.add(o.Id);
            }
            
            if(o.IsWon && o.IsWon != old.IsWon)
            {
                wonOppIds.add(o.Id);
                wonOppAccountIds.add(o.AccountId);
            }
        }
        
        sponsorshipPackageIds = getSponsorshipPackageIdSet(sponsorshipOppIds);
        
        if(!sponsorshipPackageIds.isEmpty())
        {
            OpportunityPackageTriggerHandler.calculateSoldAndPendingPackages(sponsorshipPackageIds);
        }
        
        sponsorshipPackageIds = null;
        
        //Create fullfillment records for closed won opps
        if(!closedWonOppIds.isEmpty())
        {
            createFulfillmentItems(closedWonOppIds);
        }
        
        //Link account to line item for advertising history
        //Roll up adversiting totals to Account Sales Summary
        //Roll up adversiting totals to Show/Publication
        if(!wonOppIds.isEmpty())
        {
            linkAdvertisingItemsToAccount(wonOppIds);
            updateAccountSalesSummary(wonOppIds,wonOppAccountIds);
            updateShowsPublication(wonOppIds);
        }
        
        if(!closedOppIds.isEmpty())  //if the set of closed opp ids is not empty
        {
            showIds = getShowIdsFromLineItem(oldRecordMap.keySet());
            
            if(!showIds.isEmpty())
            {
                OpportunityLineItemTriggerHandler.ShowLineItemsTotalRollUp(showIds);
            }
            
            showIds = null;
        }
    }
    
    public static void onAfterDelete(Map<Id, Opportunity> oldRecordMap)
    {
        List<Opportunity> records = oldRecordMap.values();
        
        //Populated in on before delete 
        if(sponsorshipPackageIds != null && !sponsorshipPackageIds.isEmpty())
        {
            OpportunityPackageTriggerHandler.calculateSoldAndPendingPackages(sponsorshipPackageIds);
        }
        
        sponsorshipPackageIds = null;
        
        if(!showIds.isEmpty())
        {
            OpportunityLineItemTriggerHandler.ShowLineItemsTotalRollUp(showIds);
        }
    }
    
    public static void onAfterUndelete(Map<Id, Opportunity> newRecordMap)
    {
        List<Opportunity> records = newRecordMap.values();
                
        sponsorshipPackageIds = getSponsorshipPackageIdSet(newRecordMap.keySet());
        
        if(!sponsorshipPackageIds.isEmpty())
        {
            OpportunityPackageTriggerHandler.calculateSoldAndPendingPackages(sponsorshipPackageIds);
        }
        
        sponsorshipPackageIds = null;
        
        showIds = getShowIdsFromLineItem(newRecordMap.keySet());
            
        if(!showIds.isEmpty())
        {
            OpportunityLineItemTriggerHandler.ShowLineItemsTotalRollUp(showIds);
        }
        
        showIds = null;

    }
    
    public static Set<Id> getShowIdsFromLineItem(Set<ID> oppIds)
    {
        showIds = new Set<ID>();
        List<OpportunityLineItem> oliList = [SELECT Show_Event_Publication__c FROM OpportunityLineItem
                                            WHERE Opportunity.id in : oppIds AND Show_Event_Publication__c != null];
                                            
        //loop through and get the show ids
        for(OpportunityLineItem oppLineItems : oliList)
        {
            showIds.add(oppLineItems.Show_Event_Publication__c);
        }   
        
        return showIds;                         
    }   

    public static Set<ID> getSponsorshipPackageIdSet(Set<ID> oppIds)
    {
        Set<ID> spIds = new Set<ID>();
        List<Opportunity_Package__c> ops = null;
                
        if(!oppIds.isEmpty())
        {
            ops = [SELECT Sponsorship_Package__c FROM Opportunity_Package__c WHERE Opportunity__c in :oppIds];
            
            if(!ops.isEmpty())
            {
                for(Opportunity_Package__c op : ops)
                {
                    spIds.add(op.Sponsorship_Package__c);
                }
            }
        }
        
        return spIds;
    }
    
    public static void createFulfillmentItems(Set<ID> oppIds)
    {
        List<OpportunityLineItem> lineItems = [SELECT Id, Description, OpportunityId, Product2Id, Quantity, Color__c, Insertion_Date__c, Item_ID__c, Page_Count__c, Family__c,
                                                        Position__c, Show_Event_Publication__c, Sponsorship_Package__c 
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId in: oppIds AND Family__c in ('Advertising','Sponsorship','Membership')];
                                                
        List<Fulfillment_Item__c> items = new List<Fulfillment_Item__c>();
        System.debug('Creating fulfillment items: ' + lineItems.size());
        
        for(OpportunityLineItem oli : lineItems)
        {
            Fulfillment_Item__c fi = new Fulfillment_Item__c();
            
            if(oli.Family__c == 'Advertising')
            {
                fi.RecordTypeId = Schema.SObjectType.Fulfillment_Item__c.getRecordTypeInfosByName().get('Advertising').getRecordTypeId();
            }
            else if(oli.Family__c == 'Sponsorship')
            {
                fi.RecordTypeId = Schema.SObjectType.Fulfillment_Item__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
            }
            else
            {
                fi.RecordTypeId = Schema.SObjectType.Fulfillment_Item__c.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
            }
            
            fi.Color__c = oli.Color__c;
            fi.Description__c = oli.Description;
            fi.Insertion_Date__c = oli.Insertion_Date__c;
            fi.Item_ID__c = oli.Item_ID__c;
            fi.Opportunity__c = oli.OpportunityId;
            fi.Position__c = oli.Position__c;
            fi.Product__c = oli.Product2Id;
            fi.Quantity__c = oli.Quantity; 
            fi.Show_Event_Publication__c = oli.Show_Event_Publication__c;
            fi.Sponsorship_Package__c = oli.Sponsorship_Package__c;
            
            items.add(fi);
        }
        
        if(!items.isEmpty())
        {
            insert items;
        }                                       
        
    }
    
    public static void validatePackageAvailability(Map<Id, Opportunity> newRecordMap, Set<Id> closedWonOppIds)
    {
        List<Opportunity_Package__c> oppPackages = [SELECT Opportunity__c, Sponsorship_Package__r.Name, Units_Sold__c, Maximum_Units__c
                                                    FROM Opportunity_Package__c 
                                                    WHERE Opportunity__c in: closedWonOppIds];
                                                    
        for(Opportunity_Package__c op : oppPackages)
        {
            if(op.Maximum_Units__c <= op.Units_Sold__c)
            {
                Opportunity opp = newRecordMap.get(op.Opportunity__c);
                
                if(opp != null)
                {
                    opp.addError(op.Sponsorship_Package__r.Name + ' has sold out, and is no longer available to be included in this Opportunity. Remove all products associated to this package before closing the Opportunity.');
                }
            }
        }
    }
    
    //Advertising sales history
    public static void linkAdvertisingItemsToAccount(Set<ID> wonOppIds)
    {
        List<OpportunityLineItem> lineItems = [SELECT Id, Opportunity.AccountId, Insertion_Date__c FROM OpportunityLineItem WHERE OpportunityId in: wonOppIds AND Product2.Family = 'Advertising'];
        List<OpportunityLineItem> itemsToUpdate = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem oli : lineItems)
        {
            if(oli.Insertion_Date__c != null)
            {
                oli.Account__c = oli.Opportunity.AccountId;
                oli.Year__c = string.valueOf(oli.Insertion_Date__c.year());
                itemsToUpdate.add(oli);
            }
        }
        
        if(!itemsToUpdate.isEmpty())
        {
            update itemsToUpdate;
        }
    }
    
    //Roll up advertising sales when opp is won to account sales summary object. 
    public static void updateAccountSalesSummary(Set<ID> oppIds, Set<ID> oppAccountIds)
    {
        Set<String> keys = new Set<String>();
        List<OpportunityLineItem> lineItems = [SELECT Account_Sales_Summary_Key__c 
                                                FROM OpportunityLineItem 
                                                WHERE OpportunityId in: oppIds AND Product2.Family = 'Advertising' 
                                                    AND Account_Sales_Summary_Key__c != null AND Account_Sales_Summary_Key__c != ''
                                                    AND Opportunity.IsWon = true];
        AggregateResult[] salesHistoryRollUps = null;
        Map<Id, Account> accountMap = null;
        List<Account_Sales_Summary__c> salesSummaries = null;
        Map<String, Account_Sales_Summary__c> keyToSalesSummaryMap = new Map<String, Account_Sales_Summary__c>();
        Map<String, Account_Sales_Summary__c> keyToSalesSummaryToUpdateMap = new Map<String, Account_Sales_Summary__c>();
        Id parentSalesSmmaryRecordTypeId = AccountSalesSummaryUtility.getParentRecordTypeId();
        Id salesSmmaryRecordTypeId = AccountSalesSummaryUtility.getChildRecordTypeId();
        Id parentAccountRecordTypeId = AccountUtility.getParentCustomerRecordTypeId();
        
        if(!lineItems.isEmpty())
        {
            accountMap = new Map<Id, Account>([SELECT Id, RecordTypeId FROM Account WHERE Id in: oppAccountIds]);
            
            for(OpportunityLineItem oli : lineItems)
            {
                keys.add(oli.Account_Sales_Summary_Key__c);
            }
            
            salesSummaries = [SELECT Id, Account_Name__c, Year__c, Key__c FROM Account_Sales_Summary__c WHERE Key__c in :keys];
            salesHistoryRollUps = [SELECT Account__c, Year__c, SUM(Total_Billing_Price__c) total 
                                        FROM OpportunityLineItem 
                                        WHERE Account_Sales_Summary_Key__c in: keys AND Product2.Family = 'Advertising'
                                            AND Account_Sales_Summary_Key__c != null AND Account_Sales_Summary_Key__c != ''
                                        GROUP BY Account__c, Year__c];
            
            for(Account_Sales_Summary__c a : salesSummaries)
            {
                keyToSalesSummaryMap.put(a.Key__c, a);
            }
            
            for(AggregateResult ar : salesHistoryRollUps)
            {
                Id accountId = (ID) ar.get('Account__c');
                String year = (String) ar.get('Year__c');
                Decimal total = (Decimal) ar.get('total');
                String key = accountId + '_' + year;
                Account_Sales_Summary__c a = keyToSalesSummaryMap.get(key);
                Account acct = accountMap.get(accountId);
                
                if(a == null)
                {
                    a = new Account_Sales_Summary__c();
                    a.Account_Name__c = accountId;
                    a.Year__c = year;
                }   
                
                if(acct != null)
                {
                    if(acct.RecordTypeId == parentAccountRecordTypeId)
                    {
                        a.RecordTypeId = parentSalesSmmaryRecordTypeId;
                    }
                    else
                    {
                        a.RecordTypeId = salesSmmaryRecordTypeId;
                    }
                }
                
                a.Advertising__c = total;   
                        
                if(a.Account_Name__c != null)
                {       
                    keyToSalesSummaryToUpdateMap.put(key, a);   
                }   
            }
            
            //Set to zero if not found in update map
            for(String key : keys)
            {
                if(!keyToSalesSummaryToUpdateMap.containsKey(key))
                {
                    Account_Sales_Summary__c a = keyToSalesSummaryMap.get(key);
                    
                    if(a != null)
                    {
                        a.Advertising__c = 0;       
                        
                        if(a.Account_Name__c != null)
                        {       
                            keyToSalesSummaryToUpdateMap.put(key, a);   
                        }
                    }
                }
            }
                    
            if(!keyToSalesSummaryToUpdateMap.isEmpty())
            {
                upsert keyToSalesSummaryToUpdateMap.values();
            }
        }
    }
    
    //Roll up advertising sales when opp is won to account sales summary object. 
    public static void updateShowsPublication(Set<ID> oppIds)
    {
        Set<ID> sIds = new Set<Id>();
        List<OpportunityLineItem> lineItems = [SELECT Show_Event_Publication__c FROM OpportunityLineItem WHERE OpportunityId in: oppIds AND Product2.Family = 'Advertising' AND Show_Event_Publication__c != null AND Opportunity.IsWon = true];
        AggregateResult[] salesHistoryRollUps = null;
        Map<Id, Show_Publications__c> showsToUpdate = new Map<ID, Show_Publications__c>();
        
        for(OpportunityLineItem oli : lineItems)
        {
            sIds.add(oli.Show_Event_Publication__c);
        }
    
        salesHistoryRollUps = [SELECT Show_Event_Publication__c, SUM(Total_Billing_Price__c) total 
                                    FROM OpportunityLineItem 
                                    WHERE Show_Event_Publication__c in: sIds AND Product2.Family = 'Advertising'
                                        AND Opportunity.IsWon = true
                                    GROUP BY Show_Event_Publication__c];
                
        for(AggregateResult ar : salesHistoryRollUps)
        {
            Id showId = (ID) ar.get('Show_Event_Publication__c');
            Decimal total = (Decimal) ar.get('total');
            Show_Publications__c show = new Show_Publications__c(Id = showId, Salesforce_Advertising_Total__c = total);
                            
            showsToUpdate.put(show.Id, show);       
        }
        
        //Set to zero if not found in update map
        for(Id sId : sIds)
        {
            if(!showsToUpdate.containsKey(sId))
            {
                Show_Publications__c show = new Show_Publications__c(Id = sId, Salesforce_Advertising_Total__c = 0);
                showsToUpdate.put(show.Id, show);   
            }
        }
                
        if(!showsToUpdate.isEmpty())
        {
            update showsToUpdate.values();
        }
    }

}