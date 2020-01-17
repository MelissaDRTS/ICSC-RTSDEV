public with sharing class OpportunityLineItemTriggerHandler 
{

    public static void onBeforeInsert(List<OpportunityLineItem> newRecords){
        setGlCodes(newRecords);
    }
    
    public static void onBeforeUpdate(List<OpportunityLineItem> newRecords){
        setGlCodes(newRecords);
    }
    
    //After inserting a new opportunity line item to the database
    public static void onAfterInsert(Map<Id, OpportunityLineItem> newRecordMap)
    {
     	List<OpportunityLineItem> newLineItems = newRecordMap.values();  
        
     	Set<ID> showPubIds = new Set<ID>(); 
     	
     	//Look through the new oli, check to see which ones have shows/publications
     	//get the ids
     	for(OpportunityLineItem oli : newLineItems)
        {
        	if(oli.Show_Event_Publication__c != null)
        	{
        		showPubIds.add(oli.Show_Event_Publication__c);  //add its show/publication ID to the set of Ids
        	}  	
        } 
        if(!showPubIds.isEmpty()) 
    	{
    		ShowLineItemsTotalRollUp(showPubIds);
    	}
    }
    
    public static void onAfterUpdate(Map<Id, OpportunityLineItem> newRecordMap, Map<Id, OpportunityLineItem> oldRecordMap)
	{
		List<OpportunityLineItem> newLineItems = newRecordMap.values();  
        
     	Set<ID> showPubIds = new Set<ID>();  
     	Set<ID> oppIds = new Set<ID>();
     	Set<ID> oppAccountIds = new Set<ID>();
     									
		for(OpportunityLineItem oli : newLineItems)  			//Loop through the newLineItems (newMap)
		{
			if(oli.Show_Event_Publication__c != null)  //look for oli with shows
			{
				OpportunityLineItem old = oldRecordMap.get(oli.Id);  //use the id from the oppLineItem (newMap) to reference the oldRecordMap
			
				//if the total price from the oppLineItem does not equal the total price from oldMap
				//put the Show Id of the OpportunityLineItem into the set of Ids
				if(old.TotalPrice != oli.TotalPrice)					
				{
					showPubIds.add(oli.Show_Event_Publication__c);
					oppIds.add(oli.OpportunityId);
					
					if(oli.Account__c != null)
					{
						oppAccountIds.add(oli.Account__c);	
					}		
				}
			}
		}
        
        //If the set of Ids is not empty, send the ids to the ShowLineItemsTotalRollUp method
        if(!showPubIds.isEmpty())
        {
        	ShowLineItemsTotalRollUp(showPubIds);
        }
        
        //Recalculate advertising totals for won opps if total changed
        if(!oppIds.isEmpty())
        {
        	OpportunityTriggerHandler.updateShowsPublication(oppIds);
        	
        	if(!oppAccountIds.isEmpty())
        	{
        		OpportunityTriggerHandler.updateAccountSalesSummary(oppIds, oppAccountIds);
        	}
        }
	}
	
	public static void onAfterDelete(Map<Id, OpportunityLineItem> recordMap)
    {
        List<OpportunityLineItem> records = recordMap.values();
        Set<ID> oppPackageIds = new Set<ID>();
        Set<ID> showPubIds = new Set<ID>();
        
        //AfterDelete for Opportunity Line Items WITH Show/Publications
        //loop through oli and see which ones have a show/publication
        for(OpportunityLineItem oli : records)
        {
        	if(oli.Show_Event_Publication__c != null) 
        	{
        		showPubIds.add(oli.Show_Event_Publication__c);  //add its show/publication ID to the set of Ids
        	}
        }
        //If the set of Ids is not empty, sent the ids to the ShowLineItemsTotalRollUp method
        if(!showPubIds.isEmpty())
        {
        	ShowLineItemsTotalRollUp(showPubIds);
        }
        
       
         //AfterDelete for Opportunity Line Items WITH packages
        for(OpportunityLineItem oli : records)
        {
        	if(oli.Opportunity_Package__c != null)
        	{
        		oppPackageIds.add(oli.Opportunity_Package__c);
        	}
        }
        
        if(!oppPackageIds.isEmpty())
        {
        	deleteOppPackages(oppPackageIds);
        }
    }
    
    public static void setGlCodes(List<OpportunityLineItem> records){
        for (OpportunityLineItem record : records){
            record.Discount_GL_Code__c = DiscountGLCode.getGlCode(record.Discount_Code__c);
        }
    }
    
    //roll up opp Line Item totals to show/publication
     public static void ShowLineItemsTotalRollUp(Set<ID> showPubIds)
     {
     	AggregateResult[] closedWonResults = null;
		AggregateResult[] openResults = null;
		Map<ID, Show_Publications__c> showPublicationToUpdate = new Map<Id, Show_Publications__c>(); 

		//get the totals for the shows/publications that are closed won
     	closedWonResults = [SELECT Show_Event_Publication__c pubId, sum(TotalPrice) total
     							FROM OpportunityLineItem WHERE Show_Event_Publication__c in : showPubIds 
								AND Opportunity.IsWon = true AND Opportunity.IsClosed = true  
								GROUP BY Show_Event_Publication__c];	
										         
		//get the totals for the shows/publications that are open										
		openResults = [SELECT Show_Event_Publication__c pubId, sum(TotalPrice) total
     							FROM OpportunityLineItem WHERE Show_Event_Publication__c in : showPubIds 
								AND Opportunity.IsClosed = false  
								GROUP BY Show_Event_Publication__c];
								
		//loop through the closed won results						
		for (AggregateResult ar : closedWonResults)		
		{
			//define datatypes to be used in for loop
			ID showPubId = (ID) ar.get('pubId');	 
			decimal total = (decimal) ar.get('total');		//get the total that was returned in the query and call it total
			//Show_Publications__c showPublication = new Show_Publications__c(ID = showPubId, Total_Won_Opps__c = total, Total_Opps_in_Pipeline__c = 0);  
			Show_Publications__c showPublication = new Show_Publications__c(ID = showPubId, Total_Won_Opps__c = total, Total_Opps_in_Pipeline__c = 0);
			
			showPublicationToUpdate.put(showPublication.Id, showPublication);
		}	
	
		for (AggregateResult ar : openResults)
		{
			//define datatypes to be used in for loop
			ID showPubId = (ID) ar.get('pubId');	 		//get the show/pub ids from query
			decimal total = (decimal) ar.get('total');		//get the total that was returned in the query and call it total
			Show_Publications__c showPublication = null;
			
			//if the map already contains the showId, get the id from the map and set the open to the total
			if(showPublicationToUpdate.containskey(showPubId))  
			{
				showPublication = showPublicationToUpdate.get(showPubId);  
				showPublication.Total_Opps_in_Pipeline__c = total; 
			}
			
			//Otherwise, set won total to 0 and pending to the amount from select and id to the showPublicationToUpdate map
			else 
			{
				showPublication = new Show_Publications__c(ID = showPubId, Total_Won_Opps__c = 0, Total_Opps_in_Pipeline__c = total);
			}
			showPublicationToUpdate.put(showPublication.Id, showPublication); 
		}
		
		//Loop through the Show Ids that were originally selected
		//If the id is no in the set to update, 
		//set the won total to 0 and the open total to 0
		for (Id showId : showPubIds)  
		{
			Show_Publications__c showPublication = null;

			if (!showPublicationToUpdate.containskey(showId))  
			{
				showPublication = new Show_Publications__c(ID = showId, Total_Won_Opps__c = 0, Total_Opps_in_Pipeline__c = 0);
				showPublicationToUpdate.put(showPublication.Id, showPublication);
			}
		}
			
		//Finally, if the map is not empty, update all of the values in the map
		if(!showPublicationToUpdate.IsEmpty())   
		{
			update showPublicationToUpdate.values();
		}				
     }
     
     
    public static void deleteOppPackages(Set<ID> oppPackageIds)
    {
    	AggregateResult[] lineItems = [SELECT Opportunity_Package__c, Count(id) items 
    									FROM OpportunityLineItem 
    									WHERE Opportunity_Package__c in: oppPackageIds
    									GROUP BY Opportunity_Package__c];
    	Set<ID> oppPackageIdsWithLineItems = new Set<ID>();
    	List<Opportunity_Package__c> oppPackagesToDelete = new List<Opportunity_Package__c>();
    	
    	for(AggregateResult ar : lineItems)
    	{
    		oppPackageIdsWithLineItems.add((ID)ar.get('Opportunity_Package__c'));
    	} 
    	
    	for(Id opi : oppPackageIds)
    	{
    		if(!oppPackageIdsWithLineItems.contains(opi))
    		{
    			oppPackagesToDelete.add(new Opportunity_Package__c(Id = opi));
    		}
    	}
    	
    	if(!oppPackagesToDelete.isEmpty())
    	{
    		SharingOverride.deleteRecords(oppPackagesToDelete);
    	}
    }
}