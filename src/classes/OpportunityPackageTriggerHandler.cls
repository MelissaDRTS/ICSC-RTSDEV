public with sharing class OpportunityPackageTriggerHandler 
{    
    public static void onAfterInsert(Map<Id, Opportunity_Package__c> recordMap)
    {
        List<Opportunity_Package__c> newOppPackages = recordMap.values();
        Set<ID> sponsorPackageIds = new Set<ID>();
        
        for(Opportunity_Package__c op : newOppPackages)
        {
        	sponsorPackageIds.add(op.Sponsorship_Package__c);
        }   
        
        if(!sponsorPackageIds.isEmpty())  
        {
        	calculateSoldAndPendingPackages(sponsorPackageIds);
        }   
    }
        
    public static void onAfterDelete(Map<Id, Opportunity_Package__c> recordMap)
    {
        List<Opportunity_Package__c> newOppPackages = recordMap.values();
        
        Set<ID> sponsorPackageIds = new Set<ID>();
        
        for(Opportunity_Package__c op : newOppPackages)
        {
        	sponsorPackageIds.add(op.Sponsorship_Package__c);
        }   
        
        if(!sponsorPackageIds.isEmpty())  
        {
        	calculateSoldAndPendingPackages(sponsorPackageIds);
        }  
    }
    
    public static void onAfterUndelete(Map<Id, Opportunity_Package__c> recordMap)
    {
        List<Opportunity_Package__c> newOppPackages = recordMap.values();
        
        Set<ID> sponsorPackageIds = new Set<ID>();
        
        for(Opportunity_Package__c op : newOppPackages)
        {
        	sponsorPackageIds.add(op.Sponsorship_Package__c);
        }   
        
        if(!sponsorPackageIds.isEmpty())  
        {
        	calculateSoldAndPendingPackages(sponsorPackageIds);
        }  
    }

	public static void calculateSoldAndPendingPackages(Set<ID> sponsorPackageIds)
	{
		Map<Id, Sponsorship_Package__c> sponsorPackageMap = new Map<Id, Sponsorship_Package__c>();
		AggregateResult[] soldPackages = [SELECT Sponsorship_Package__c, sum(Quantity__c) sold 
											FROM Opportunity_Package__c
											WHERE Sponsorship_Package__c in: sponsorPackageIds AND Opportunity__r.IsClosed = true AND Opportunity__r.IsWon = true
											GROUP BY Sponsorship_Package__c];
		AggregateResult[] pendingPackages = [SELECT Sponsorship_Package__c, sum(Quantity__c) pending 
											FROM Opportunity_Package__c
											WHERE Sponsorship_Package__c in: sponsorPackageIds AND Opportunity__r.IsClosed = false
											GROUP BY Sponsorship_Package__c];
		
		for(AggregateResult ar : soldPackages)
		{
			ID spId = (ID)ar.get('Sponsorship_Package__c');
			Decimal sold = (Decimal)ar.get('sold');
			
			sponsorPackageMap.put(spId, new Sponsorship_Package__c(ID = spId, Units_Sold__c = sold, Units_Pending__c = 0)); //set pending to zero. if there are pending items, it will be updated below
		}
		
		for(AggregateResult ar : pendingPackages)
		{
			ID spId = (ID)ar.get('Sponsorship_Package__c');
			Decimal pending = (Decimal)ar.get('pending');
			Sponsorship_Package__c sp = sponsorPackageMap.get(spId);
			
			//If there are sold items, update the pending field. Otherwise add to map and set sold to zero.
			if(sp != null)
			{
				sp.Units_Pending__c = pending;				
				sponsorPackageMap.put(spId, sp);
			}
			else
			{
				sponsorPackageMap.put(spId, new Sponsorship_Package__c(ID = spId, Units_Sold__c = 0, Units_Pending__c = pending));
			}
		}
		
		//if no pending nor sold items were found, set sold and pending to zero
		for(Id spId : sponsorPackageIds)
		{
			if(!sponsorPackageMap.containsKey(spId))
			{
				sponsorPackageMap.put(spId, new Sponsorship_Package__c(ID = spId, Units_Sold__c = 0, Units_Pending__c = 0));
			}
		}
		
		if(!sponsorPackageMap.isEmpty())
		{
			SharingOverride.UpsertRecords(sponsorPackageMap.values());
		}
	}
}