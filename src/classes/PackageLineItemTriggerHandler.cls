public with sharing class PackageLineItemTriggerHandler 
{
    public static void onBeforeInsert(List<Package_Line_Item__c> records)
    {
        Set<ID> productIds = new Set<ID>();
        
        for(Package_Line_Item__c pli : records)
        {
            if(pli.Product__c != null)
            {
                productIds.add(pli.Product__c);
            }
        }
        
        if(!productIds.isEmpty())
        {
            setListPrice(records, productIds);
        }
    }
    
    public static void onBeforeUpdate(Map<Id, Package_Line_Item__c> recordMap, Map<Id, Package_Line_Item__c> oldRecordMap)
    {
        List<Package_Line_Item__c> newLineItems = recordMap.values();
        Set<ID> productIds = new Set<ID>();
        
        for(Package_Line_Item__c pli : newLineItems)
        {
            Package_Line_Item__c oldPli = oldRecordMap.get(pli.Id);
            
            //Only update if product was chnaged
            if(pli.Product__c != oldPli.Product__c)
            {
                if(pli.Product__c == null)
                {
                    pli.List_Price__c = 0; //if product is removed, set list price to 0
                }
                else
                {
                    productIds.add(pli.Product__c);
                }
            }
        }
        
        if(!productIds.isEmpty())
        {
            setListPrice(newLineItems, productIds);
        }
    }
    
    private static void setListPrice(List<Package_Line_Item__c> records, Set<ID> productIds)
    {
        List<PricebookEntry> pricebookEntries = [SELECT p.UnitPrice, p.Product2Id, p.Id 
                                                    FROM PricebookEntry p
                                                    WHERE p.Product2Id in: productIds AND  p.Pricebook2.IsStandard = true AND p.Pricebook2.IsActive = true AND  p.IsActive = true
                                                ];
        Map<Id, PricebookEntry> productToPricebookEntryMap = new Map<Id, PricebookEntry>();
        
        for(PricebookEntry pbe : pricebookEntries)
        {
            productToPricebookEntryMap.put(pbe.Product2Id, pbe);
        }
        
        for(Package_Line_Item__c pli : records)
        {
            PricebookEntry pbe = productToPricebookEntryMap.get(pli.Product__c);
            
            if(pbe != null)
            {
                pli.List_Price__c = pbe.UnitPrice;
            }
        }
    }
}